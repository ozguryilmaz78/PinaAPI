import 'package:flutter/material.dart';
import '../../domain/entities/due.dart';
import '../../domain/usecases/create_due.dart';
import '../../domain/usecases/get_all_dues.dart';
import '../../domain/usecases/update_due.dart';
import '../../domain/usecases/delete_due.dart';
import '../../domain/usecases/search_dues.dart';
import '../../domain/usecases/get_dues_by_customer.dart';
import '../../domain/usecases/get_total_due_amount.dart';
import '../../domain/usecases/get_total_paid_amount.dart';
import '../../domain/usecases/create_monthly_dues.dart';

class DueProvider with ChangeNotifier {
  final CreateDue _createDue;
  final GetAllDues _getAllDues;
  final UpdateDue _updateDue;
  final DeleteDue _deleteDue;
  final SearchDues _searchDues;
  final GetDuesByCustomer _getDuesByCustomer;
  final GetTotalDueAmount _getTotalDueAmount;
  final GetTotalPaidAmount _getTotalPaidAmount;
  final CreateMonthlyDues _createMonthlyDues;

  DueProvider({
    required CreateDue createDue,
    required GetAllDues getAllDues,
    required UpdateDue updateDue,
    required DeleteDue deleteDue,
    required SearchDues searchDues,
    required GetDuesByCustomer getDuesByCustomer,
    required GetTotalDueAmount getTotalDueAmount,
    required GetTotalPaidAmount getTotalPaidAmount,
    required CreateMonthlyDues createMonthlyDues,
  })  : _createDue = createDue,
        _getAllDues = getAllDues,
        _updateDue = updateDue,
        _deleteDue = deleteDue,
        _searchDues = searchDues,
        _getDuesByCustomer = getDuesByCustomer,
        _getTotalDueAmount = getTotalDueAmount,
        _getTotalPaidAmount = getTotalPaidAmount,
        _createMonthlyDues = createMonthlyDues;

  List<Due> _dues = [];
  List<Due> _filteredDues = [];
  bool _isLoading = false;
  String _searchQuery = '';
  double _totalDueAmount = 0.0;
  double _totalPaidAmount = 0.0;

  List<Due> get allDues => _dues;
  List<Due> get filteredDues => _filteredDues;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  double get totalDueAmount => _totalDueAmount;
  double get totalPaidAmount => _totalPaidAmount;

  Future<void> loadDues() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dues = await _getAllDues.call();
      _filteredDues = List.from(_dues);
      _totalDueAmount = await _getTotalDueAmount.call();
      _totalPaidAmount = await _getTotalPaidAmount.call();
    } catch (e) {
      // Hata durumunda boş liste
      _dues = [];
      _filteredDues = [];
      _totalDueAmount = 0.0;
      _totalPaidAmount = 0.0;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createDue(Due due) async {
    await _createDue.call(due);
    await loadDues();
  }

  Future<void> updateDue(Due due) async {
    await _updateDue.call(due);
    await loadDues();
  }

  Future<void> deleteDue(String id) async {
    await _deleteDue.call(id);
    await loadDues();
  }

  Future<void> searchDues(String query) async {
    _searchQuery = query;
    _filteredDues = await _searchDues.call(query);
    notifyListeners();
  }

  Future<List<Due>> getDuesForCustomer(String customerId) async {
    return await _getDuesByCustomer.call(customerId);
  }

  Future<void> createMonthlyDues(
      double amount, String period, int dueDay) async {
    print(
        'Aylık tahakkuk oluşumu başlatılıyor: $amount ₺, Dönem: $period, Vade Günü: $dueDay');
    await _createMonthlyDues.call(amount, period, dueDay);
    print('Aylık tahakkuk tamamlandı, bilgiler yeniden yükleniyor...');
    await loadDues();
    print('Tahakkuklar yüklendi. Toplam tahakkuk sayısı: ${_dues.length}');
  }

  // Yardımcı metodlar
  List<Due> get pendingDues {
    return _dues.where((due) => due.status == DueStatus.pending).toList();
  }

  List<Due> get overdueDues {
    return _dues.where((due) => due.isOverdue).toList();
  }

  List<Due> get paidDues {
    return _dues.where((due) => due.status == DueStatus.paid).toList();
  }

  Map<String, List<Due>> get duesByPeriod {
    Map<String, List<Due>> grouped = {};
    for (var due in _dues) {
      if (!grouped.containsKey(due.period)) {
        grouped[due.period] = [];
      }
      grouped[due.period]!.add(due);
    }
    return grouped;
  }

  String getCurrentPeriod() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String getNextPeriod() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    return '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}';
  }
}
