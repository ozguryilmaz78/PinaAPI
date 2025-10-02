import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetAllPayments {
  final PaymentRepository _repository;

  GetAllPayments(this._repository);

  Future<List<Payment>> call() async {
    return await _repository.getAllPayments();
  }
}

