import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  final ApiConfig _config = ApiConfig();

  // Konfigürasyonu yükle
  Future<void> initialize() async {
    print('🚀 ApiService: Initializing...');
    try {
      await _config.loadConfig();
      print('✅ ApiService: Config loaded successfully');
    } catch (e) {
      print('💥 ApiService: Error loading config: $e');
      rethrow;
    }
  }

  // API bağlantısını test et
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing API connection...');

      final result = await _config.checkHealth();

      if (result['success'] == true) {
        print('✅ API connection successful');
        return true;
      } else {
        print('❌ API connection failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('❌ API connection failed: $e');
      return false;
    }
  }

  // Müşteri verilerini getir
  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      print('📊 Fetching customers from API...');

      final response = await http.get(
        Uri.parse(_config.customersUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          List<dynamic> customers = jsonResponse['data'];
          print('✅ Found ${customers.length} customers from API');

          // API'den gelen veriyi Flutter formatına çevir
          return customers.map<Map<String, dynamic>>((customer) {
            return {
              'id': customer['id']?.toString() ?? '',
              'first_name': customer['first_name'] ?? '',
              'last_name': customer['last_name'] ?? '',
              'email': customer['email'],
              'phone': customer['phone'],
              'address': customer['address'],
              'status': customer['status'] ?? 'active',
              'created_at':
                  customer['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at':
                  customer['updated_at'] ?? DateTime.now().toIso8601String(),
            };
          }).toList();
        } else {
          print('⚠️ No customers found in API response');
          return [];
        }
      } else {
        print('❌ API request failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 PostgresHttpService getCustomers hatası: $e');
      throw Exception('Müşteri verileri alınamadı: $e');
    }
  }

  // Müşteri ekle
  Future<bool> addCustomer(Map<String, dynamic> newCustomer) async {
    try {
      print('➕ Adding new customer via API...');
      print('📄 Received customer data: $newCustomer');

      // CustomerModel.toJson() artık snake_case üretiyor, direkt kullanabiliriz
      final apiData = Map<String, dynamic>.from(newCustomer);
      // ID'yi çıkar çünkü sunucu tarafında otomatik oluşturuluyor
      apiData.remove('id');
      // Timestamp'leri çıkar çünkü sunucu tarafında otomatik oluşturuluyor
      apiData.remove('created_at');
      apiData.remove('updated_at');

      print('📤 Sending API data: $apiData');

      final response = await http
          .post(
            Uri.parse(_config.customersUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Customer added successfully via API');
          return true;
        }
      }

      print('❌ Failed to add customer: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService addCustomer hatası: $e');
      return false;
    }
  }

  // Müşteri güncelle
  Future<bool> updateCustomer(Map<String, dynamic> updatedCustomer) async {
    try {
      print('🔄 Updating customer via API...');
      print('📄 Received customer data: $updatedCustomer');

      // CustomerModel.toJson() artık snake_case üretiyor, direkt kullanabiliriz
      final apiData = Map<String, dynamic>.from(updatedCustomer);
      // ID'yi çıkar çünkü URL'de gönderiliyor
      apiData.remove('id');
      // Timestamp'leri çıkar çünkü sunucu tarafında otomatik güncelleniyor
      apiData.remove('created_at');
      apiData.remove('updated_at');

      print('📤 Sending API data: $apiData');

      final response = await http
          .put(
            Uri.parse('${_config.customersUrl}/${updatedCustomer['id']}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Customer updated successfully via API');
          return true;
        }
      }

      print('❌ Failed to update customer: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService updateCustomer hatası: $e');
      return false;
    }
  }

  // Müşteri sil
  Future<bool> deleteCustomer(String customerId) async {
    try {
      print('🗑️ Deleting customer via API: $customerId');

      final response = await http.delete(
        Uri.parse('${_config.customersUrl}/$customerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Customer deleted successfully via API');
          return true;
        }
      }

      print('❌ Failed to delete customer: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService deleteCustomer hatası: $e');
      return false;
    }
  }

  // Ödeme verilerini getir
  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      print('📊 Fetching payments from API...');

      final response = await http.get(
        Uri.parse(_config.paymentsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          List<dynamic> payments = jsonResponse['data'];
          print('✅ Found ${payments.length} payments from API');

          // API'den gelen veriyi Flutter formatına çevir
          return payments.map<Map<String, dynamic>>((payment) {
            // Amount'u güvenli şekilde double'a çevir
            double amount = 0.0;
            if (payment['amount'] != null) {
              if (payment['amount'] is String) {
                amount = double.tryParse(payment['amount']) ?? 0.0;
              } else if (payment['amount'] is num) {
                amount = payment['amount'].toDouble();
              }
            }

            return {
              'id': payment['id']?.toString() ?? '',
              'customer_id':
                  payment['customer_id']?.toString() ?? '', // snake_case
              'customer_name': payment['customer_name'] ?? '',
              'amount': amount,
              'method': payment['method'] ?? 'cash',
              'status': payment['status'] ?? 'completed',
              'payment_date':
                  payment['payment_date'] ?? DateTime.now().toIso8601String(),
              'created_at':
                  DateTime.now().toIso8601String(), // PaymentModel için gerekli
              'notes': payment['notes'],
              'reference_number': payment['reference_number'],
            };
          }).toList();
        } else {
          print('⚠️ No payments found in API response');
          return [];
        }
      } else {
        print('❌ API request failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 PostgresHttpService getPayments hatası: $e');
      throw Exception('Ödeme verileri alınamadı: $e');
    }
  }

  // Ödeme ekle
  Future<bool> addPayment(Map<String, dynamic> newPayment) async {
    try {
      print('➕ Adding new payment via API');
      print('📄 Received payment data: $newPayment');

      // PaymentModel.toJson() artık snake_case üretiyor, direkt kullanabiliriz
      final apiData = Map<String, dynamic>.from(newPayment);
      // ID'yi çıkar çünkü sunucu tarafında otomatik oluşturuluyor
      apiData.remove('id');
      // created_at'i çıkar çünkü API'de bu alan yok
      apiData.remove('created_at');

      print('📤 Sending API data: $apiData');

      final response = await http
          .post(
            Uri.parse(_config.paymentsUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Payment added successfully via API');
          return true;
        }
      }

      print('❌ Failed to add payment: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService addPayment hatası: $e');
      return false;
    }
  }

  // Ödeme güncelle
  Future<bool> updatePayment(Map<String, dynamic> updatedPayment) async {
    try {
      print('🔄 Updating payment via API');
      print('📄 Received payment data: $updatedPayment');

      // PaymentModel.toJson() artık snake_case üretiyor, direkt kullanabiliriz
      final apiData = Map<String, dynamic>.from(updatedPayment);
      // ID'yi çıkar çünkü URL'de gönderiliyor
      apiData.remove('id');
      // created_at'i çıkar çünkü API'de bu alan yok
      apiData.remove('created_at');

      print('📤 Sending API data: $apiData');

      final response = await http
          .put(
            Uri.parse('${_config.paymentsUrl}/${updatedPayment['id']}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Payment updated successfully via API');
          return true;
        }
      }

      print('❌ Failed to update payment: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService updatePayment hatası: $e');
      return false;
    }
  }

  // Ödeme sil
  Future<bool> deletePayment(String paymentId) async {
    try {
      print('🗑️ Deleting payment via API: $paymentId');

      final response = await http.delete(
        Uri.parse('${_config.paymentsUrl}/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Payment deleted successfully via API');
          return true;
        }
      }

      print('❌ Failed to delete payment: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService deletePayment hatası: $e');
      return false;
    }
  }

  // Tahakkuk verilerini getir
  Future<List<Map<String, dynamic>>> getDues() async {
    try {
      print('📊 Fetching dues from API...');

      final response = await http.get(
        Uri.parse(_config.duesUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          List<dynamic> dues = jsonResponse['data'];
          print('✅ Found ${dues.length} dues from API');

          // API'den gelen veriyi Flutter formatına çevir
          return dues.map<Map<String, dynamic>>((due) {
            // Amount'u güvenli şekilde double'a çevir
            double amount = 0.0;
            if (due['amount'] != null) {
              if (due['amount'] is String) {
                amount = double.tryParse(due['amount']) ?? 0.0;
              } else if (due['amount'] is num) {
                amount = due['amount'].toDouble();
              }
            }

            return {
              'id': due['id']?.toString() ?? '',
              'customer_id': due['customer_id']?.toString() ?? '', // snake_case
              'customer_name': due['customer_name'] ?? '',
              'amount': amount,
              'due_date': due['due_date'] ?? DateTime.now().toIso8601String(),
              'created_at':
                  DateTime.now().toIso8601String(), // DueModel için gerekli
              'status': due['status'] ?? 'pending',
              'period': due['period'] ?? '',
              'notes': due['notes'],
              'payment_id': due['payment_id']?.toString(),
            };
          }).toList();
        } else {
          print('⚠️ No dues found in API response');
          return [];
        }
      } else {
        print('❌ API request failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 PostgresHttpService getDues hatası: $e');
      throw Exception('Tahakkuk verileri alınamadı: $e');
    }
  }

  // Tahakkuk ekle
  Future<bool> addDue(Map<String, dynamic> newDue) async {
    try {
      print('➕ Adding new due via API');
      print('📄 Received due data: $newDue');

      // DueModel.toJson() artık snake_case üretiyor, direkt kullanabiliriz
      final apiData = Map<String, dynamic>.from(newDue);
      // ID'yi çıkar çünkü sunucu tarafında otomatik oluşturuluyor
      apiData.remove('id');
      // created_at'i çıkar çünkü API'de bu alan yok
      apiData.remove('created_at');

      print('📤 Sending API data: $apiData');

      final response = await http
          .post(
            Uri.parse(_config.duesUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Due added successfully via API');
          return true;
        }
      }

      print('❌ Failed to add due: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService addDue hatası: $e');
      return false;
    }
  }

  // Tahakkuk güncelle
  Future<bool> updateDue(Map<String, dynamic> updatedDue) async {
    try {
      print('🔄 Updating due via API');
      print('📄 Received due data: $updatedDue');

      // DueModel.toJson() artık snake_case üretiyor, direkt kullanabiliriz
      final apiData = Map<String, dynamic>.from(updatedDue);
      // ID'yi çıkar çünkü URL'de gönderiliyor
      apiData.remove('id');
      // created_at'i çıkar çünkü API'de bu alan yok
      apiData.remove('created_at');

      print('📤 Sending API data: $apiData');

      final response = await http
          .put(
            Uri.parse('${_config.duesUrl}/${updatedDue['id']}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Due updated successfully via API');
          return true;
        }
      }

      print('❌ Failed to update due: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService updateDue hatası: $e');
      return false;
    }
  }

  // Tahakkuk sil
  Future<bool> deleteDue(String dueId) async {
    try {
      print('🗑️ Deleting due via API: $dueId');

      final response = await http.delete(
        Uri.parse('${_config.duesUrl}/$dueId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Due deleted successfully via API');
          return true;
        }
      }

      print('❌ Failed to delete due: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService deleteDue hatası: $e');
      return false;
    }
  }

  // Konfigürasyon bilgilerini al
  Map<String, dynamic> getConfigInfo() {
    return _config.getConfigInfo();
  }

  // API konfigürasyonunu güncelle
  Future<void> updateConfig({
    String? baseUrl,
    String? apiVersion,
    int? timeoutSeconds,
  }) async {
    await _config.saveConfig(
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      timeoutSeconds: timeoutSeconds,
    );
  }

  // Tahakkuku ödendi olarak işaretle
  Future<bool> markAsPaid(String dueId, String paymentId) async {
    try {
      print('💰 Marking due as paid via API: $dueId -> $paymentId');

      final apiData = {
        'status': 'paid',
        'payment_id': paymentId,
      };

      final response = await http
          .patch(
            Uri.parse('${_config.duesUrl}/$dueId/mark-paid'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(apiData),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ Due marked as paid successfully via API');
          return true;
        }
      }

      print('❌ Failed to mark due as paid: ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 PostgresHttpService markAsPaid hatası: $e');
      return false;
    }
  }

  // Dispose
  Future<void> dispose() async {
    // HTTP servisi için dispose gerekmez
  }
}
