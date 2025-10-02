import 'package:flutter/foundation.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/get_all_customers.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/delete_customer.dart';

class CustomerProvider with ChangeNotifier {
  final CreateCustomer _createCustomer;
  final GetAllCustomers _getAllCustomers;
  final UpdateCustomer _updateCustomer;
  final DeleteCustomer _deleteCustomer;

  CustomerProvider({
    required CreateCustomer createCustomer,
    required GetAllCustomers getAllCustomers,
    required UpdateCustomer updateCustomer,
    required DeleteCustomer deleteCustomer,
  })  : _createCustomer = createCustomer,
        _getAllCustomers = getAllCustomers,
        _updateCustomer = updateCustomer,
        _deleteCustomer = deleteCustomer;

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  CustomerStatus? _statusFilter;

  List<Customer> get customers => _filteredCustomers;
  List<Customer> get allCustomers => _customers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  CustomerStatus? get statusFilter => _statusFilter;

  List<Customer> get activeCustomers =>
      _customers.where((c) => c.status.isActive).toList();

  List<Customer> get inactiveCustomers =>
      _customers.where((c) => !c.status.isActive).toList();

  Future<void> loadCustomers() async {
    debugPrint('🔄 CustomerProvider: Starting to load customers...');
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📡 CustomerProvider: Calling _getAllCustomers()...');
      _customers = await _getAllCustomers();
      debugPrint('✅ CustomerProvider: Loaded ${_customers.length} customers');
      _applyFilters();
      debugPrint('🔍 CustomerProvider: Applied filters, showing ${_filteredCustomers.length} customers');
    } catch (e) {
      debugPrint('💥 CustomerProvider: Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('🏁 CustomerProvider: Loading completed');
    }
  }

  Future<void> createCustomer({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? address,
    CustomerStatus status = CustomerStatus.active,
  }) async {
    try {
      final customer = await _createCustomer(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        address: address,
        status: status,
      );
      _customers.add(customer);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final updatedCustomer = await _updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _deleteCustomer(customerId);
      _customers.removeWhere((c) => c.id == customerId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      rethrow;
    }
  }

  void searchCustomers(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByStatus(CustomerStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCustomers = _customers.where((customer) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            customer.firstName.toLowerCase().contains(query) ||
                customer.lastName.toLowerCase().contains(query) ||
                (customer.phone?.toLowerCase().contains(query) ?? false) ||
                (customer.email?.toLowerCase().contains(query) ?? false);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_statusFilter != null) {
        if (customer.status != _statusFilter) return false;
      }

      return true;
    }).toList();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
