import '../../domain/entities/due.dart';
import '../../domain/repositories/due_repository.dart';
import '../datasources/due_local_datasource.dart';
import '../models/due_model.dart';
import '../../../customer/domain/repositories/customer_repository.dart';

class DueRepositoryImpl implements DueRepository {
  final DueLocalDataSource _localDataSource;
  final CustomerRepository _customerRepository;

  DueRepositoryImpl(this._localDataSource, this._customerRepository);

  @override
  Future<List<Due>> getAllDues() async {
    return await _localDataSource.getAllDues();
  }

  @override
  Future<Due?> getDueById(String id) async {
    return await _localDataSource.getDueById(id);
  }

  @override
  Future<List<Due>> getDuesByCustomer(String customerId) async {
    return await _localDataSource.getDuesByCustomer(customerId);
  }

  @override
  Future<List<Due>> getDuesByPeriod(String period) async {
    return await _localDataSource.getDuesByPeriod(period);
  }

  @override
  Future<List<Due>> getPendingDues() async {
    return await _localDataSource.getPendingDues();
  }

  @override
  Future<List<Due>> getOverdueDues() async {
    return await _localDataSource.getOverdueDues();
  }

  @override
  Future<void> createDue(Due due) async {
    await _localDataSource.createDue(DueModel.fromEntity(due));
  }

  @override
  Future<void> updateDue(Due due) async {
    await _localDataSource.updateDue(DueModel.fromEntity(due));
  }

  @override
  Future<void> deleteDue(String id) async {
    await _localDataSource.deleteDue(id);
  }

  @override
  Future<List<Due>> searchDues(String query) async {
    return await _localDataSource.searchDues(query);
  }

  @override
  Future<double> getTotalDueAmount() async {
    return await _localDataSource.getTotalDueAmount();
  }

  @override
  Future<double> getTotalPaidAmount() async {
    return await _localDataSource.getTotalPaidAmount();
  }

  @override
  Future<void> markAsPaid(String dueId, String paymentId) async {
    await _localDataSource.markAsPaid(dueId, paymentId);
  }

  @override
  Future<void> createMonthlyDuesForActiveCustomers(
      double amount, String period, int dueDay) async {
    print('Aktif müşteriler alınıyor...');
    // Aktif müşterileri al
    final activeCustomers = await _customerRepository.getActiveCustomers();
    print('${activeCustomers.length} aktif müşteri bulundu');

    // Dönemden yıl ve ayı çıkar
    final parts = period.split('-');
    if (parts.length != 2) {
      throw Exception('Geçersiz dönem formatı. YYYY-MM formatında olmalı.');
    }

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Vade tarihini hesapla
    DateTime dueDate;
    try {
      dueDate = DateTime(year, month, dueDay);
    } catch (e) {
      // Geçersiz tarih (örn: 31 Şubat), ayın son gününü kullan
      dueDate = DateTime(year, month + 1, 0); // Ayın son günü
      print(
          'Geçersiz vade günü ($dueDay), ayın son günü kullanılıyor: ${dueDate.day}');
    }

    print(
        'Vade tarihi: ${dueDate.day.toString().padLeft(2, '0')}.${dueDate.month.toString().padLeft(2, '0')}.${dueDate.year}');

    // Her aktif müşteri için aidat oluştur
    for (final customer in activeCustomers) {
      print(
          'Müşteri kontrol ediliyor: ${customer.firstName} ${customer.lastName}');
      // Bu dönem için zaten aidat var mı kontrol et
      final existingDues =
          await _localDataSource.getDuesByCustomer(customer.id);
      final hasDueForPeriod = existingDues.any((due) => due.period == period);

      if (!hasDueForPeriod) {
        print(
            'Yeni aidat oluşturuluyor: ${customer.firstName} ${customer.lastName}');
        // Yeni aidat oluştur
        final due = Due(
          id: '', // UUID otomatik oluşturulacak
          customerId: customer.id,
          customerName: '${customer.firstName} ${customer.lastName}',
          amount: amount,
          dueDate: dueDate,
          createdAt: DateTime.now(),
          status: DueStatus.pending,
          period: period,
          notes: 'Aylık aidat tahakkuku',
        );

        await _localDataSource.createDue(due);
        print(
            'Aidat oluşturuldu: ${customer.firstName} ${customer.lastName} - $amount ₺ - Vade: ${dueDate.day.toString().padLeft(2, '0')}.${dueDate.month.toString().padLeft(2, '0')}.${dueDate.year}');
      } else {
        print(
            'Bu dönem için zaten aidat var: ${customer.firstName} ${customer.lastName}');
      }
    }
    print('Aylık tahakkuk işlemi tamamlandı');
  }
}
