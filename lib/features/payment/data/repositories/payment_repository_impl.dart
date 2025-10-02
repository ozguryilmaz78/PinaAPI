import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _localDataSource;

  PaymentRepositoryImpl(this._localDataSource);

  @override
  Future<List<Payment>> getAllPayments() async {
    final paymentModels = await _localDataSource.getAllPayments();
    return paymentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    final paymentModel = await _localDataSource.getPaymentById(id);
    return paymentModel?.toEntity();
  }

  @override
  Future<List<Payment>> getPaymentsByCustomerId(String customerId) async {
    final paymentModels =
        await _localDataSource.getPaymentsByCustomerId(customerId);
    return paymentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final paymentModels =
        await _localDataSource.getPaymentsByDateRange(startDate, endDate);
    return paymentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByMethod(PaymentMethod method) async {
    final paymentModels =
        await _localDataSource.getPaymentsByMethod(method.name);
    return paymentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByStatus(PaymentStatus status) async {
    final paymentModels =
        await _localDataSource.getPaymentsByStatus(status.name);
    return paymentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createPayment(Payment payment) async {
    final paymentModel = PaymentModel.fromEntity(payment);
    await _localDataSource.createPayment(paymentModel);
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    final paymentModel = PaymentModel.fromEntity(payment);
    await _localDataSource.updatePayment(paymentModel);
  }

  @override
  Future<void> deletePayment(String id) async {
    await _localDataSource.deletePayment(id);
  }

  @override
  Future<List<Payment>> searchPayments(String query) async {
    final paymentModels = await _localDataSource.searchPayments(query);
    return paymentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<double> getTotalAmount() async {
    final payments = await getAllPayments();
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  @override
  Future<double> getTotalAmountByCustomer(String customerId) async {
    final payments = await getPaymentsByCustomerId(customerId);
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  @override
  Future<double> getTotalAmountByDateRange(
      DateTime startDate, DateTime endDate) async {
    final payments = await getPaymentsByDateRange(startDate, endDate);
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }
}
