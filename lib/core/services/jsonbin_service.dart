import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/jsonbin_config.dart';

class JsonBinService {
  final JsonBinConfig _config = JsonBinConfig();

  // HTTP headers for GET requests
  Map<String, String> get _headers => {
        'X-Master-Key': _config.masterKey,
      };

  // HTTP headers for POST/PUT requests
  Map<String, String> get _headersWithContentType => {
        'Content-Type': 'application/json',
        'X-Master-Key': _config.masterKey,
      };

  // Konfigürasyonu yükle
  Future<void> initialize() async {
    print('🚀 JsonBinService: Initializing...');
    try {
      await _config.loadConfig();
      print('✅ JsonBinService: Config loaded successfully');
      print('🔗 API URL: ${_config.apiUrl}');
      print('🆔 Customer Bin ID: ${_config.customerBinId}');
      print('🔑 Master Key: ${_config.masterKey.substring(0, 10)}...');
    } catch (e) {
      print('💥 JsonBinService: Error loading config: $e');
      rethrow;
    }
  }

  // Müşteri verilerini getir
  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final url = '${_config.apiUrl}/${_config.customerBinId}';
      print('🔍 JSONBin GET Request: $url');
      print('🔑 Using Master Key: ${_config.masterKey.substring(0, 10)}...');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headersWithContentType,
          )
          .timeout(const Duration(seconds: 30));

      print('📡 JSONBin Response Status: ${response.statusCode}');
      print('📄 JSONBin Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['record'] != null) {
          final customers = List<Map<String, dynamic>>.from(data['record']);
          print('✅ Found ${customers.length} customers from JSONBin.io');
          return customers.map(_convertToCustomerFormat).toList();
        }
        print('⚠️ No customers found in JSONBin.io');
        return [];
      } else {
        print('❌ JSONBin API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'JSONBin API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 JSONBin getCustomers hatası: $e');
      throw Exception('Müşteri verileri alınamadı: $e');
    }
  }

  // Müşteri verilerini kaydet
  Future<bool> saveCustomers(List<Map<String, dynamic>> customers) async {
    try {
      final url = '${_config.apiUrl}/${_config.customerBinId}';
      final jsonBinCustomers =
          customers.map(_convertFromCustomerFormat).toList();
      final body = json.encode(jsonBinCustomers);

      print('💾 JSONBin PUT Request: $url');
      print('📝 Saving ${customers.length} customers to JSONBin.io');
      print('🔑 Using Master Key: ${_config.masterKey.substring(0, 10)}...');

      final response = await http
          .put(
            Uri.parse(url),
            headers: _headersWithContentType,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('📡 JSONBin PUT Response Status: ${response.statusCode}');
      print('📄 JSONBin PUT Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Successfully saved customers to JSONBin.io');
        return true;
      } else {
        print('❌ Failed to save customers to JSONBin.io');
        return false;
      }
    } catch (e) {
      print('💥 JSONBin saveCustomers hatası: $e');
      return false;
    }
  }

  // Ödeme verilerini getir
  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final url = '${_config.apiUrl}/${_config.paymentBinId}';
      print('JSONBin GET Request: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headersWithContentType,
          )
          .timeout(const Duration(seconds: 30));

      print('JSONBin Response Status: ${response.statusCode}');
      print('JSONBin Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['record'] != null) {
          final payments = List<Map<String, dynamic>>.from(data['record']);
          return payments.map(_convertToPaymentFormat).toList();
        }
        return [];
      } else {
        throw Exception(
            'JSONBin API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('JSONBin getPayments hatası: $e');
      throw Exception('Ödeme verileri alınamadı: $e');
    }
  }

  // Ödeme verilerini kaydet
  Future<bool> savePayments(List<Map<String, dynamic>> payments) async {
    try {
      final url = '${_config.apiUrl}/${_config.paymentBinId}';
      final jsonBinPayments = payments.map(_convertFromPaymentFormat).toList();
      final body = json.encode(jsonBinPayments);

      print('JSONBin PUT Request: $url');
      print('JSONBin PUT Body: $body');

      final response = await http
          .put(
            Uri.parse(url),
            headers: _headersWithContentType,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('JSONBin PUT Response Status: ${response.statusCode}');
      print('JSONBin PUT Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('JSONBin savePayments hatası: $e');
      return false;
    }
  }

  // Tahakkuk verilerini getir
  Future<List<Map<String, dynamic>>> getDues() async {
    try {
      final url = '${_config.apiUrl}/${_config.dueBinId}';
      print('JSONBin GET Request: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headersWithContentType,
          )
          .timeout(const Duration(seconds: 30));

      print('JSONBin Response Status: ${response.statusCode}');
      print('JSONBin Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['record'] != null) {
          final dues = List<Map<String, dynamic>>.from(data['record']);
          return dues.map(_convertToDueFormat).toList();
        }
        return [];
      } else {
        throw Exception(
            'JSONBin API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('JSONBin getDues hatası: $e');
      throw Exception('Tahakkuk verileri alınamadı: $e');
    }
  }

  // Tahakkuk verilerini kaydet
  Future<bool> saveDues(List<Map<String, dynamic>> dues) async {
    try {
      final url = '${_config.apiUrl}/${_config.dueBinId}';
      final jsonBinDues = dues.map(_convertFromDueFormat).toList();
      final body = json.encode(jsonBinDues);

      print('JSONBin PUT Request: $url');
      print('JSONBin PUT Body: $body');

      final response = await http
          .put(
            Uri.parse(url),
            headers: _headersWithContentType,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('JSONBin PUT Response Status: ${response.statusCode}');
      print('JSONBin PUT Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('JSONBin saveDues hatası: $e');
      return false;
    }
  }

  // Müşteri ekle
  Future<bool> addCustomer(Map<String, dynamic> newCustomer) async {
    try {
      print(
          '➕ Adding new customer to JSONBin.io: ${newCustomer['firstName']} ${newCustomer['lastName']}');
      print('📝 Customer data before cleaning: $newCustomer');

      // Boş alanları null'a çevir
      final cleanedCustomer = Map<String, dynamic>.from(newCustomer);
      cleanedCustomer['email'] =
          _convertEmptyStringToNull(newCustomer['email']);
      cleanedCustomer['phone'] =
          _convertEmptyStringToNull(newCustomer['phone']);
      cleanedCustomer['address'] =
          _convertEmptyStringToNull(newCustomer['address']);

      print('🧹 Customer data after cleaning: $cleanedCustomer');

      final customers = await getCustomers();
      customers.add(cleanedCustomer);
      return await saveCustomers(customers);
    } catch (e) {
      print('💥 JSONBin addCustomer hatası: $e');
      return false;
    }
  }

  // Müşteri güncelle
  Future<bool> updateCustomer(Map<String, dynamic> updatedCustomer) async {
    try {
      print(
          '🔄 Updating customer in JSONBin.io: ${updatedCustomer['firstName']} ${updatedCustomer['lastName']}');
      print('📝 Customer data before cleaning: $updatedCustomer');

      // Boş alanları null'a çevir
      final cleanedCustomer = Map<String, dynamic>.from(updatedCustomer);
      cleanedCustomer['email'] =
          _convertEmptyStringToNull(updatedCustomer['email']);
      cleanedCustomer['phone'] =
          _convertEmptyStringToNull(updatedCustomer['phone']);
      cleanedCustomer['address'] =
          _convertEmptyStringToNull(updatedCustomer['address']);

      print('🧹 Customer data after cleaning: $cleanedCustomer');

      final customers = await getCustomers();
      final index =
          customers.indexWhere((c) => c['id'] == cleanedCustomer['id']);
      if (index != -1) {
        customers[index] = cleanedCustomer;
        final success = await saveCustomers(customers);

        // Cascade update: İlgili ödeme ve tahakkuk kayıtlarını güncelle
        if (success) {
          final customerId = cleanedCustomer['id'];
          final newCustomerName =
              '${cleanedCustomer['firstName']} ${cleanedCustomer['lastName']}';
          await updatePaymentsByCustomerId(customerId, newCustomerName);
          await updateDuesByCustomerId(customerId, newCustomerName);
        }

        return success;
      }
      print('⚠️ Customer not found for update');
      return false;
    } catch (e) {
      print('💥 JSONBin updateCustomer hatası: $e');
      return false;
    }
  }

  // Müşteri sil
  Future<bool> deleteCustomer(String customerId) async {
    try {
      print('🗑️ Deleting customer from JSONBin.io: $customerId');
      final customers = await getCustomers();
      customers.removeWhere((c) => c['id'] == customerId);
      return await saveCustomers(customers);
    } catch (e) {
      print('💥 JSONBin deleteCustomer hatası: $e');
      return false;
    }
  }

  // Ödeme ekle
  Future<bool> addPayment(Map<String, dynamic> newPayment) async {
    try {
      final payments = await getPayments();
      payments.add(newPayment);
      return await savePayments(payments);
    } catch (e) {
      print('JSONBin addPayment hatası: $e');
      return false;
    }
  }

  // Ödeme güncelle
  Future<bool> updatePayment(Map<String, dynamic> updatedPayment) async {
    try {
      final payments = await getPayments();
      final index = payments.indexWhere((p) => p['id'] == updatedPayment['id']);
      if (index != -1) {
        payments[index] = updatedPayment;
        return await savePayments(payments);
      }
      return false;
    } catch (e) {
      print('JSONBin updatePayment hatası: $e');
      return false;
    }
  }

  // Ödeme sil
  Future<bool> deletePayment(String paymentId) async {
    try {
      final payments = await getPayments();
      payments.removeWhere((p) => p['id'] == paymentId);
      return await savePayments(payments);
    } catch (e) {
      print('JSONBin deletePayment hatası: $e');
      return false;
    }
  }

  // Tahakkuk ekle
  Future<bool> addDue(Map<String, dynamic> newDue) async {
    try {
      final dues = await getDues();
      dues.add(newDue);
      return await saveDues(dues);
    } catch (e) {
      print('JSONBin addDue hatası: $e');
      return false;
    }
  }

  // Tahakkuk güncelle
  Future<bool> updateDue(Map<String, dynamic> updatedDue) async {
    try {
      final dues = await getDues();
      final index = dues.indexWhere((d) => d['id'] == updatedDue['id']);
      if (index != -1) {
        dues[index] = updatedDue;
        return await saveDues(dues);
      }
      return false;
    } catch (e) {
      print('JSONBin updateDue hatası: $e');
      return false;
    }
  }

  // Tahakkuk sil
  Future<bool> deleteDue(String dueId) async {
    try {
      final dues = await getDues();
      dues.removeWhere((d) => d['id'] == dueId);
      return await saveDues(dues);
    } catch (e) {
      print('JSONBin deleteDue hatası: $e');
      return false;
    }
  }

  // Bağlantı testi
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = '${_config.apiUrl}/${_config.customerBinId}';
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headersWithContentType,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': response.statusCode,
          'data': data,
          'message': 'Bağlantı başarılı',
        };
      } else {
        return {
          'success': false,
          'status': response.statusCode,
          'message': 'API Hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'status': 0,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // Tüm bağlantıları test et
  Future<Map<String, dynamic>> testAllConnections() async {
    try {
      final customerResult =
          await _testConnection('customers', _config.customerBinId);
      final paymentResult =
          await _testConnection('payments', _config.paymentBinId);
      final dueResult = await _testConnection('dues', _config.dueBinId);

      return {
        'customers': customerResult,
        'payments': paymentResult,
        'dues': dueResult,
      };
    } catch (e) {
      return {
        'error': 'Test hatası: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _testConnection(
      String type, String binId) async {
    try {
      final url = '${_config.apiUrl}/$binId';
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headersWithContentType,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': response.statusCode,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'status': response.statusCode,
          'message': 'API Hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'status': 0,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // Konfigürasyon bilgilerini al
  Map<String, dynamic> getConfigInfo() {
    return _config.getConfigInfo();
  }

  // Konfigürasyonu güncelle
  Future<void> updateConfig({
    String? masterKey,
    String? apiUrl,
    String? customerBinId,
    String? paymentBinId,
    String? dueBinId,
  }) async {
    await _config.saveConfig(
      masterKey: masterKey,
      apiUrl: apiUrl,
      customerBinId: customerBinId,
      paymentBinId: paymentBinId,
      dueBinId: dueBinId,
    );
  }

  // Müşteri formatını JSONBin'den uygulama formatına çevir
  Map<String, dynamic> _convertToCustomerFormat(
      Map<String, dynamic> jsonBinCustomer) {
    return {
      'id': jsonBinCustomer['id'],
      'firstName': jsonBinCustomer['firstName'],
      'lastName': jsonBinCustomer['lastName'],
      'email': jsonBinCustomer['email'],
      'phone': jsonBinCustomer['phone'],
      'address': jsonBinCustomer['address'],
      'status': jsonBinCustomer['status'],
      'createdAt': jsonBinCustomer['createdAt'],
      'updatedAt': jsonBinCustomer['updatedAt'] ?? jsonBinCustomer['createdAt'],
    };
  }

  // Müşteri formatını uygulama formatından JSONBin formatına çevir
  Map<String, dynamic> _convertFromCustomerFormat(
      Map<String, dynamic> customer) {
    return {
      'id': customer['id'],
      'firstName': customer['firstName'],
      'lastName': customer['lastName'],
      'email': _convertEmptyStringToNull(customer['email']),
      'phone': _convertEmptyStringToNull(customer['phone']),
      'address': _convertEmptyStringToNull(customer['address']),
      'status': customer['status'],
      'createdAt': customer['createdAt'],
      'updatedAt': customer['updatedAt'] ?? DateTime.now().toIso8601String(),
    };
  }

  // Boş string'leri null'a çevir
  String? _convertEmptyStringToNull(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value.toString();
  }

  // Ödeme formatını JSONBin'den uygulama formatına çevir
  Map<String, dynamic> _convertToPaymentFormat(
      Map<String, dynamic> jsonBinPayment) {
    return {
      'id': jsonBinPayment['id'],
      'customerId': jsonBinPayment['customerId'],
      'customerName': jsonBinPayment['customerName'],
      'amount': jsonBinPayment['amount'],
      'method': jsonBinPayment['method'],
      'status': jsonBinPayment['status'],
      'paymentDate': jsonBinPayment['paymentDate'],
      'createdAt': jsonBinPayment['createdAt'],
      'notes': jsonBinPayment['notes'],
      'referenceNumber': jsonBinPayment['referenceNumber'],
    };
  }

  // Ödeme formatını uygulama formatından JSONBin formatına çevir
  Map<String, dynamic> _convertFromPaymentFormat(Map<String, dynamic> payment) {
    return {
      'id': payment['id'],
      'customerId': payment['customerId'],
      'customerName': payment['customerName'],
      'amount': payment['amount'],
      'method': payment['method'],
      'status': payment['status'],
      'paymentDate': payment['paymentDate'],
      'createdAt': payment['createdAt'],
      'notes': payment['notes'],
      'referenceNumber': payment['referenceNumber'],
    };
  }

  // Tahakkuk formatını JSONBin'den uygulama formatına çevir
  Map<String, dynamic> _convertToDueFormat(Map<String, dynamic> jsonBinDue) {
    return {
      'id': jsonBinDue['id'],
      'customerId': jsonBinDue['customerId'],
      'customerName': jsonBinDue['customerName'],
      'amount': jsonBinDue['amount'],
      'dueDate': jsonBinDue['dueDate'],
      'createdAt': jsonBinDue['createdAt'],
      'status': jsonBinDue['status'],
      'period': jsonBinDue['period'],
      'notes': jsonBinDue['notes'],
      'paymentId': jsonBinDue['paymentId'],
    };
  }

  // Tahakkuk formatını uygulama formatından JSONBin formatına çevir
  Map<String, dynamic> _convertFromDueFormat(Map<String, dynamic> due) {
    return {
      'id': due['id'],
      'customerId': due['customerId'],
      'customerName': due['customerName'],
      'amount': due['amount'],
      'dueDate': due['dueDate'],
      'createdAt': due['createdAt'],
      'status': due['status'],
      'period': due['period'],
      'notes': due['notes'],
      'paymentId': due['paymentId'],
    };
  }

  // Cascade Update: Müşteri ID'sine göre ödeme kayıtlarındaki müşteri ismini güncelle
  Future<bool> updatePaymentsByCustomerId(
      String customerId, String newCustomerName) async {
    try {
      print(
          '🔄 Cascade Update: Updating customer name in payments for customer ID: $customerId');
      final payments = await getPayments();
      bool hasUpdates = false;

      for (int i = 0; i < payments.length; i++) {
        if (payments[i]['customerId'] == customerId) {
          payments[i]['customerName'] = newCustomerName;
          hasUpdates = true;
          print(
              '✅ Updated payment ${payments[i]['id']} customer name to: $newCustomerName');
        }
      }

      if (hasUpdates) {
        final success = await savePayments(payments);
        print(
            '📊 Cascade Update: Updated ${payments.where((p) => p['customerId'] == customerId).length} payment records');
        return success;
      } else {
        print(
            'ℹ️ Cascade Update: No payment records found for customer ID: $customerId');
        return true;
      }
    } catch (e) {
      print(
          '💥 Cascade Update: Error updating payments for customer $customerId: $e');
      return false;
    }
  }

  // Cascade Update: Müşteri ID'sine göre tahakkuk kayıtlarındaki müşteri ismini güncelle
  Future<bool> updateDuesByCustomerId(
      String customerId, String newCustomerName) async {
    try {
      print(
          '🔄 Cascade Update: Updating customer name in dues for customer ID: $customerId');
      final dues = await getDues();
      bool hasUpdates = false;

      for (int i = 0; i < dues.length; i++) {
        if (dues[i]['customerId'] == customerId) {
          dues[i]['customerName'] = newCustomerName;
          hasUpdates = true;
          print(
              '✅ Updated due ${dues[i]['id']} customer name to: $newCustomerName');
        }
      }

      if (hasUpdates) {
        final success = await saveDues(dues);
        print(
            '📊 Cascade Update: Updated ${dues.where((d) => d['customerId'] == customerId).length} due records');
        return success;
      } else {
        print(
            'ℹ️ Cascade Update: No due records found for customer ID: $customerId');
        return true;
      }
    } catch (e) {
      print(
          '💥 Cascade Update: Error updating dues for customer $customerId: $e');
      return false;
    }
  }
}
