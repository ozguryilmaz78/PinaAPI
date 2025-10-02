import '../repositories/payment_repository.dart';

class GetTotalAmount {
  final PaymentRepository _repository;

  GetTotalAmount(this._repository);

  Future<double> call() async {
    return await _repository.getTotalAmount();
  }
}

