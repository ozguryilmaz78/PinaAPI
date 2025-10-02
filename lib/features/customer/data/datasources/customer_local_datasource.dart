import '../../../../core/services/api_service.dart';
import '../models/customer_model.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getAllCustomers();
  Future<CustomerModel?> getCustomerById(String id);
  Future<List<CustomerModel>> getActiveCustomers();
  Future<List<CustomerModel>> getInactiveCustomers();
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerModel>> searchCustomers(String query);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final ApiService _apiService;

  CustomerLocalDataSourceImpl(this._apiService);

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    print('🔍 CustomerDataSource: Getting all customers from API...');
    try {
      // API'den müşteri verilerini çek
      final customersData = await _apiService.getCustomers();
      print(
          '📊 CustomerDataSource: Received ${customersData.length} customers from API');

      if (customersData.isNotEmpty) {
        print('📄 First customer data: ${customersData.first}');
      }

      final models = <CustomerModel>[];
      for (int i = 0; i < customersData.length; i++) {
        try {
          final model = CustomerModel.fromJson(customersData[i]);
          models.add(model);
          print(
              '✅ CustomerDataSource: Converted customer ${i + 1}: ${model.firstName} ${model.lastName}');
        } catch (e) {
          print(
              '💥 CustomerDataSource: Error converting customer ${i + 1}: $e');
          print('📄 Customer data: ${customersData[i]}');
        }
      }

      print(
          '✅ CustomerDataSource: Successfully converted ${models.length} CustomerModel objects');
      return models;
    } catch (e) {
      print('💥 CustomerDataSource: Error getting customers: $e');
      rethrow;
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final customers = await getAllCustomers();
      return customers.where((customer) => customer.id == id).firstOrNull;
    } catch (e) {
      print('💥 CustomerDataSource: Error getting customer by ID: $e');
      return null;
    }
  }

  @override
  Future<List<CustomerModel>> getActiveCustomers() async {
    try {
      final customers = await getAllCustomers();
      return customers
          .where((customer) => customer.status == CustomerStatus.active)
          .toList();
    } catch (e) {
      print('💥 CustomerDataSource: Error getting active customers: $e');
      return [];
    }
  }

  @override
  Future<List<CustomerModel>> getInactiveCustomers() async {
    try {
      final customers = await getAllCustomers();
      return customers
          .where((customer) => customer.status == CustomerStatus.inactive)
          .toList();
    } catch (e) {
      print('💥 CustomerDataSource: Error getting inactive customers: $e');
      return [];
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      print(
          '➕ CustomerDataSource: Creating customer: ${customer.firstName} ${customer.lastName}');

      // API'ye müşteri ekle
      final customerData = customer.toJson();
      final success = await _apiService.addCustomer(customerData);

      if (success) {
        print('✅ CustomerDataSource: Customer created successfully');
        return customer;
      } else {
        throw Exception('Failed to create customer via API');
      }
    } catch (e) {
      print('💥 CustomerDataSource: Error creating customer: $e');
      rethrow;
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      print(
          '🔄 CustomerDataSource: Updating customer: ${customer.firstName} ${customer.lastName}');

      // API'de müşteri güncelle
      final customerData = customer.toJson();
      final success = await _apiService.updateCustomer(customerData);

      if (success) {
        print('✅ CustomerDataSource: Customer updated successfully');
        return customer;
      } else {
        throw Exception('Failed to update customer in PostgreSQL');
      }
    } catch (e) {
      print('💥 CustomerDataSource: Error updating customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      print('🗑️ CustomerDataSource: Deleting customer: $id');

      // API'den müşteri sil
      final success = await _apiService.deleteCustomer(id);

      if (success) {
        print('✅ CustomerDataSource: Customer deleted successfully');
      } else {
        throw Exception('Failed to delete customer via API');
      }
    } catch (e) {
      print('💥 CustomerDataSource: Error deleting customer: $e');
      rethrow;
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final customers = await getAllCustomers();
      final lowercaseQuery = query.toLowerCase();

      return customers.where((customer) {
        return customer.firstName.toLowerCase().contains(lowercaseQuery) ||
            customer.lastName.toLowerCase().contains(lowercaseQuery) ||
            (customer.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (customer.phone?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (customer.address?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      print('💥 CustomerDataSource: Error searching customers: $e');
      return [];
    }
  }
}
