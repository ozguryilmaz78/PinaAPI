import '../repositories/payment_repository.dart';

class DeletePayment {
  final PaymentRepository _repository;

  DeletePayment(this._repository);

  Future<void> call(String id) async {
    await _repository.deletePayment(id);
  }
}

