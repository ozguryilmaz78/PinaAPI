import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class SearchPayments {
  final PaymentRepository _repository;

  SearchPayments(this._repository);

  Future<List<Payment>> call(String query) async {
    return await _repository.searchPayments(query);
  }
}

