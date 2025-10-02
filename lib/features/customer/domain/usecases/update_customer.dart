import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomer {
  final CustomerRepository _repository;

  UpdateCustomer(this._repository);

  Future<Customer> call(Customer customer) async {
    final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
    return await _repository.updateCustomer(updatedCustomer);
  }
}
