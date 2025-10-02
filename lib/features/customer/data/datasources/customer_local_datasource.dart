import '../../../../core/services/jsonbin_service.dart';
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
  final JsonBinService _jsonBinService;

  CustomerLocalDataSourceImpl(this._jsonBinService);

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    print('🔍 CustomerDataSource: Getting all customers from JSONBin...');
    try {
      // JSONBin'den müşteri verilerini çek
      final customersData = await _jsonBinService.getCustomers();
      print(
          '📊 CustomerDataSource: Received ${customersData.length} customers from JSONBin');

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
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CustomerModel>> getActiveCustomers() async {
    final customers = await getAllCustomers();
    return customers
        .where((customer) => customer.status == CustomerStatus.active)
        .toList();
  }

  @override
  Future<List<CustomerModel>> getInactiveCustomers() async {
    final customers = await getAllCustomers();
    return customers
        .where((customer) => customer.status == CustomerStatus.inactive)
        .toList();
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    // JSONBin'e müşteri ekle
    final customerData = customer.toJson();
    final success = await _jsonBinService.addCustomer(customerData);
    if (!success) {
      throw Exception('Müşteri eklenirken hata oluştu');
    }
    return customer;
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    // JSONBin'de müşteri güncelle
    final customerData = customer.toJson();
    final success = await _jsonBinService.updateCustomer(customerData);
    if (!success) {
      throw Exception('Müşteri güncellenirken hata oluştu');
    }
    return customer;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    // JSONBin'den müşteri sil
    final success = await _jsonBinService.deleteCustomer(id);
    if (!success) {
      throw Exception('Müşteri silinirken hata oluştu');
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final customers = await getAllCustomers();
    final lowercaseQuery = query.toLowerCase();
    return customers.where((customer) {
      return customer.firstName.toLowerCase().contains(lowercaseQuery) ||
          customer.lastName.toLowerCase().contains(lowercaseQuery) ||
          (customer.phone?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (customer.email?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
}
