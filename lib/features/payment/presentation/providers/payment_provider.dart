import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/create_payment.dart';
import '../../domain/usecases/get_all_payments.dart';
import '../../domain/usecases/update_payment.dart';
import '../../domain/usecases/delete_payment.dart';
import '../../domain/usecases/search_payments.dart';
import '../../domain/usecases/get_payments_by_customer.dart';
import '../../domain/usecases/get_total_amount.dart';

class PaymentProvider with ChangeNotifier {
  final CreatePayment _createPayment;
  final GetAllPayments _getAllPayments;
  final UpdatePayment _updatePayment;
  final DeletePayment _deletePayment;
  final SearchPayments _searchPayments;
  final GetPaymentsByCustomer _getPaymentsByCustomer;
  final GetTotalAmount _getTotalAmount;

  PaymentProvider({
    required CreatePayment createPayment,
    required GetAllPayments getAllPayments,
    required UpdatePayment updatePayment,
    required DeletePayment deletePayment,
    required SearchPayments searchPayments,
    required GetPaymentsByCustomer getPaymentsByCustomer,
    required GetTotalAmount getTotalAmount,
  })  : _createPayment = createPayment,
        _getAllPayments = getAllPayments,
        _updatePayment = updatePayment,
        _deletePayment = deletePayment,
        _searchPayments = searchPayments,
        _getPaymentsByCustomer = getPaymentsByCustomer,
        _getTotalAmount = getTotalAmount;

  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  bool _isLoading = false;
  String _searchQuery = '';
  double _totalAmount = 0.0;

  // Getters
  List<Payment> get allPayments => _payments;
  List<Payment> get filteredPayments => _filteredPayments;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  double get totalAmount => _totalAmount;

  // Load all payments
  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _payments = await _getAllPayments();
      _filteredPayments = _payments;
      _totalAmount = await _getTotalAmount();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create payment
  Future<void> createPayment(Payment payment) async {
    try {
      await _createPayment(payment);
      await loadPayments(); // Reload to get updated data
    } catch (e) {
      // Handle error
    }
  }

  // Update payment
  Future<void> updatePayment(Payment payment) async {
    try {
      await _updatePayment(payment);
      await loadPayments(); // Reload to get updated data
    } catch (e) {
      // Handle error
    }
  }

  // Delete payment
  Future<void> deletePayment(String id) async {
    try {
      await _deletePayment(id);
      await loadPayments(); // Reload to get updated data
    } catch (e) {
      // Handle error
    }
  }

  // Search payments
  Future<void> searchPayments(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPayments = _payments;
    } else {
      try {
        _filteredPayments = await _searchPayments(query);
      } catch (e) {
        _filteredPayments = [];
      }
    }

    notifyListeners();
  }

  // Get payments by customer
  Future<List<Payment>> getPaymentsByCustomer(String customerId) async {
    try {
      return await _getPaymentsByCustomer(customerId);
    } catch (e) {
      return [];
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredPayments = _payments;
    notifyListeners();
  }
}

