import 'package:uuid/uuid.dart';
import '../../../../core/services/api_service.dart';
import '../models/due_model.dart';
import '../../domain/entities/due.dart';

abstract class DueLocalDataSource {
  Future<List<DueModel>> getAllDues();
  Future<DueModel?> getDueById(String id);
  Future<List<DueModel>> getDuesByCustomer(String customerId);
  Future<List<DueModel>> getDuesByPeriod(String period);
  Future<List<DueModel>> getPendingDues();
  Future<List<DueModel>> getOverdueDues();
  Future<void> createDue(Due due);
  Future<void> updateDue(Due due);
  Future<void> deleteDue(String id);
  Future<List<DueModel>> searchDues(String query);
  Future<double> getTotalDueAmount();
  Future<double> getTotalPaidAmount();
  Future<void> markAsPaid(String dueId, String paymentId);
}

class DueLocalDataSourceImpl implements DueLocalDataSource {
  final ApiService _apiService;
  static const _uuid = Uuid();

  DueLocalDataSourceImpl(this._apiService);

  @override
  Future<List<DueModel>> getAllDues() async {
    // PostgreSQL'den tahakkuk verilerini çek
    final data = await _apiService.getDues();
    return data.map((json) => DueModel.fromJson(json)).toList();
  }

  @override
  Future<DueModel?> getDueById(String id) async {
    final dues = await getAllDues();
    try {
      return dues.firstWhere((due) => due.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DueModel>> getDuesByCustomer(String customerId) async {
    final dues = await getAllDues();
    return dues.where((due) => due.customerId == customerId).toList();
  }

  @override
  Future<List<DueModel>> getDuesByPeriod(String period) async {
    final dues = await getAllDues();
    return dues.where((due) => due.period == period).toList();
  }

  @override
  Future<List<DueModel>> getPendingDues() async {
    final dues = await getAllDues();
    return dues.where((due) => due.status == DueStatus.pending).toList();
  }

  @override
  Future<List<DueModel>> getOverdueDues() async {
    final dues = await getAllDues();
    return dues.where((due) => due.isOverdue).toList();
  }

  @override
  Future<void> createDue(Due due) async {
    // PostgreSQL'e tahakkuk ekle
    final newDue = DueModel.fromEntity(due).copyWith(id: _uuid.v4());
    final dueData = newDue.toJson();
    final success = await _apiService.addDue(dueData);
    if (!success) {
      throw Exception('Tahakkuk eklenirken hata oluştu');
    }
  }

  @override
  Future<void> updateDue(Due due) async {
    // PostgreSQL'de tahakkuk güncelle
    final dueModel = DueModel.fromEntity(due);
    final dueData = dueModel.toJson();
    final success = await _apiService.updateDue(dueData);
    if (!success) {
      throw Exception('Tahakkuk güncellenirken hata oluştu');
    }
  }

  @override
  Future<void> deleteDue(String id) async {
    // PostgreSQL'den tahakkuk sil
    final success = await _apiService.deleteDue(id);
    if (!success) {
      throw Exception('Tahakkuk silinirken hata oluştu');
    }
  }

  @override
  Future<List<DueModel>> searchDues(String query) async {
    final dues = await getAllDues();
    if (query.isEmpty) {
      return dues;
    }
    final lowerCaseQuery = query.toLowerCase();
    return dues.where((due) {
      return due.customerName.toLowerCase().contains(lowerCaseQuery) ||
          due.period.toLowerCase().contains(lowerCaseQuery) ||
          due.amount.toString().contains(lowerCaseQuery) ||
          (due.notes?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();
  }

  @override
  Future<double> getTotalDueAmount() async {
    final dues = await getAllDues();
    return dues.fold<double>(0.0, (sum, due) => sum + due.amount);
  }

  @override
  Future<double> getTotalPaidAmount() async {
    final dues = await getAllDues();
    return dues
        .where((due) => due.status == DueStatus.paid)
        .fold<double>(0.0, (sum, due) => sum + due.amount);
  }

  @override
  Future<void> markAsPaid(String dueId, String paymentId) async {
    final dues = await getAllDues();
    final index = dues.indexWhere((d) => d.id == dueId);
    if (index != -1) {
      final updatedDue = dues[index].copyWith(
        status: DueStatus.paid,
        paymentId: paymentId,
      );
      // PostgreSQL'de tahakkuk güncelle
      final dueData = updatedDue.toJson();
      final success = await _apiService.updateDue(dueData);
      if (!success) {
        throw Exception('Tahakkuk ödeme olarak işaretlenirken hata oluştu');
      }
    }
  }
}
