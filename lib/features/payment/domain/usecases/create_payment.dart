import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class CreatePayment {
  final PaymentRepository _repository;

  CreatePayment(this._repository);

  Future<void> call(Payment payment) async {
    await _repository.createPayment(payment);
  }
}
