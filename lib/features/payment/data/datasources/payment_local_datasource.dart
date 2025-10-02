import '../models/payment_model.dart';
import '../../../../core/services/jsonbin_service.dart';

abstract class PaymentLocalDataSource {
  Future<List<PaymentModel>> getAllPayments();
  Future<PaymentModel?> getPaymentById(String id);
  Future<List<PaymentModel>> getPaymentsByCustomerId(String customerId);
  Future<List<PaymentModel>> getPaymentsByDateRange(
      DateTime startDate, DateTime endDate);
  Future<List<PaymentModel>> getPaymentsByMethod(String method);
  Future<List<PaymentModel>> getPaymentsByStatus(String status);
  Future<void> createPayment(PaymentModel payment);
  Future<void> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String id);
  Future<List<PaymentModel>> searchPayments(String query);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final JsonBinService _jsonBinService;

  PaymentLocalDataSourceImpl(this._jsonBinService);

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    // JSONBin'den ödeme verilerini çek
    final paymentsData = await _jsonBinService.getPayments();
    return paymentsData.map((data) => PaymentModel.fromJson(data)).toList();
  }

  @override
  Future<PaymentModel?> getPaymentById(String id) async {
    final payments = await getAllPayments();
    try {
      return payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByCustomerId(String customerId) async {
    final payments = await getAllPayments();
    return payments
        .where((payment) => payment.customerId == customerId)
        .toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final payments = await getAllPayments();
    return payments.where((payment) {
      return payment.paymentDate
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          payment.paymentDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByMethod(String method) async {
    final payments = await getAllPayments();
    return payments.where((payment) => payment.method.name == method).toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    final payments = await getAllPayments();
    return payments.where((payment) => payment.status.name == status).toList();
  }

  @override
  Future<void> createPayment(PaymentModel payment) async {
    // JSONBin'e ödeme ekle
    final paymentData = payment.toJson();
    final success = await _jsonBinService.addPayment(paymentData);
    if (!success) {
      throw Exception('Ödeme eklenirken hata oluştu');
    }
  }

  @override
  Future<void> updatePayment(PaymentModel payment) async {
    // JSONBin'de ödeme güncelle
    final paymentData = payment.toJson();
    final success = await _jsonBinService.updatePayment(paymentData);
    if (!success) {
      throw Exception('Ödeme güncellenirken hata oluştu');
    }
  }

  @override
  Future<void> deletePayment(String id) async {
    // JSONBin'den ödeme sil
    final success = await _jsonBinService.deletePayment(id);
    if (!success) {
      throw Exception('Ödeme silinirken hata oluştu');
    }
  }

  @override
  Future<List<PaymentModel>> searchPayments(String query) async {
    final payments = await getAllPayments();
    final lowercaseQuery = query.toLowerCase();
    return payments.where((payment) {
      return payment.customerName.toLowerCase().contains(lowercaseQuery) ||
          payment.notes?.toLowerCase().contains(lowercaseQuery) == true ||
          payment.referenceNumber?.toLowerCase().contains(lowercaseQuery) ==
              true ||
          payment.amount.toString().contains(query);
    }).toList();
  }
}
