import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class UpdatePayment {
  final PaymentRepository _repository;

  UpdatePayment(this._repository);

  Future<void> call(Payment payment) async {
    await _repository.updatePayment(payment);
  }
}

