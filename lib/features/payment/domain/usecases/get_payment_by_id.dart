import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentById {
  final PaymentRepository _repository;

  GetPaymentById(this._repository);

  Future<Payment?> call(String id) async {
    return await _repository.getPaymentById(id);
  }
}

