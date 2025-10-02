import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAllPayments();
  Future<Payment?> getPaymentById(String id);
  Future<List<Payment>> getPaymentsByCustomerId(String customerId);
  Future<List<Payment>> getPaymentsByDateRange(
      DateTime startDate, DateTime endDate);
  Future<List<Payment>> getPaymentsByMethod(PaymentMethod method);
  Future<List<Payment>> getPaymentsByStatus(PaymentStatus status);
  Future<void> createPayment(Payment payment);
  Future<void> updatePayment(Payment payment);
  Future<void> deletePayment(String id);
  Future<List<Payment>> searchPayments(String query);
  Future<double> getTotalAmount();
  Future<double> getTotalAmountByCustomer(String customerId);
  Future<double> getTotalAmountByDateRange(
      DateTime startDate, DateTime endDate);
}

