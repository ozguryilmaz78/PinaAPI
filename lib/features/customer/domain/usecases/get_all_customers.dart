import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetAllCustomers {
  final CustomerRepository _repository;

  GetAllCustomers(this._repository);

  Future<List<Customer>> call() async {
    return await _repository.getAllCustomers();
  }
}
