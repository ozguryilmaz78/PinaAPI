import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsByCustomer {
  final PaymentRepository _repository;

  GetPaymentsByCustomer(this._repository);

  Future<List<Payment>> call(String customerId) async {
    return await _repository.getPaymentsByCustomerId(customerId);
  }
}

