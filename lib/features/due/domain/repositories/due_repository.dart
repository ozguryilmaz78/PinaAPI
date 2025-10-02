import '../entities/due.dart';

abstract class DueRepository {
  Future<List<Due>> getAllDues();
  Future<Due?> getDueById(String id);
  Future<List<Due>> getDuesByCustomer(String customerId);
  Future<List<Due>> getDuesByPeriod(String period);
  Future<List<Due>> getPendingDues();
  Future<List<Due>> getOverdueDues();
  Future<void> createDue(Due due);
  Future<void> updateDue(Due due);
  Future<void> deleteDue(String id);
  Future<List<Due>> searchDues(String query);
  Future<double> getTotalDueAmount();
  Future<double> getTotalPaidAmount();
  Future<void> markAsPaid(String dueId, String paymentId);
  Future<void> createMonthlyDuesForActiveCustomers(
      double amount, String period, int dueDay);
}
