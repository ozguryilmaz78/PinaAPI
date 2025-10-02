import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class SearchCustomers {
  final CustomerRepository _repository;

  SearchCustomers(this._repository);

  Future<List<Customer>> call(String query) async {
    if (query.isEmpty) {
      return await _repository.getAllCustomers();
    }
    return await _repository.searchCustomers(query);
  }
}
