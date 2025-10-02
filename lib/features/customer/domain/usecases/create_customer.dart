import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CreateCustomer {
  final CustomerRepository _repository;

  CreateCustomer(this._repository);

  Future<Customer> call({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? address,
    CustomerStatus status = CustomerStatus.active,
  }) async {
    final customer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      address: address,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createCustomer(customer);
  }
}
