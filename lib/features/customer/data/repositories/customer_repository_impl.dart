import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource _localDataSource;

  CustomerRepositoryImpl(this._localDataSource);

  @override
  Future<List<Customer>> getAllCustomers() async {
    final customerModels = await _localDataSource.getAllCustomers();
    return customerModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final customerModel = await _localDataSource.getCustomerById(id);
    return customerModel?.toEntity();
  }

  @override
  Future<List<Customer>> getActiveCustomers() async {
    final customerModels = await _localDataSource.getActiveCustomers();
    return customerModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Customer>> getInactiveCustomers() async {
    final customerModels = await _localDataSource.getInactiveCustomers();
    return customerModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final customerModel = CustomerModel.fromEntity(customer);
    final createdModel = await _localDataSource.createCustomer(customerModel);
    return createdModel.toEntity();
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final customerModel = CustomerModel.fromEntity(customer);
    final updatedModel = await _localDataSource.updateCustomer(customerModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _localDataSource.deleteCustomer(id);
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final customerModels = await _localDataSource.searchCustomers(query);
    return customerModels.map((model) => model.toEntity()).toList();
  }
}
