import '../repositories/customer_repository.dart';

class DeleteCustomer {
  final CustomerRepository _repository;

  DeleteCustomer(this._repository);

  Future<void> call(String customerId) async {
    await _repository.deleteCustomer(customerId);
  }
}
