import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JsonBinConfig {
  static const String _configFileName = 'jsonbin_config.json';

  // Varsayılan değerler
  static const String _defaultMasterKey =
      r'$2a$10$qnHfHGVfBcI5TohYD0jPI.gPjM6cj2bbYhadYgWtYt8LV2Cp28ZkO';
  static const String _defaultApiUrl = 'https://api.jsonbin.io/v3/b';
  static const String _defaultCustomerBinId = '68dd4fa243b1c97be956e2ba';
  static const String _defaultPaymentBinId = '68dd4fcad0ea881f4091d53a';
  static const String _defaultDueBinId = '68dd4fdfd0ea881f4091d552';

  // Konfigürasyon değerleri
  String _masterKey = _defaultMasterKey;
  String _apiUrl = _defaultApiUrl;
  String _customerBinId = _defaultCustomerBinId;
  String _paymentBinId = _defaultPaymentBinId;
  String _dueBinId = _defaultDueBinId;

  // Getters
  String get masterKey => _masterKey;
  String get apiUrl => _apiUrl;
  String get customerBinId => _customerBinId;
  String get paymentBinId => _paymentBinId;
  String get dueBinId => _dueBinId;

  // Konfigürasyon dosyasından yükle
  Future<void> loadConfig() async {
    try {
      if (kIsWeb) {
        // Web platformunda localStorage kullan
        await _loadFromLocalStorage();
      } else {
        // Mobil platformlarda dosya sistemi kullan
        final file = await _getConfigFile();
        if (await file.exists()) {
          final jsonString = await file.readAsString();
          final config = json.decode(jsonString);

          _masterKey = config['masterKey'] ?? _defaultMasterKey;
          _apiUrl = config['apiUrl'] ?? _defaultApiUrl;
          _customerBinId = config['customerBinId'] ?? _defaultCustomerBinId;
          _paymentBinId = config['paymentBinId'] ?? _defaultPaymentBinId;
          _dueBinId = config['dueBinId'] ?? _defaultDueBinId;
        }
      }
    } catch (e) {
      print('JSONBin config yüklenirken hata: $e');
      // Varsayılan değerleri kullan
    }
  }

  // Konfigürasyonu kaydet
  Future<void> saveConfig({
    String? masterKey,
    String? apiUrl,
    String? customerBinId,
    String? paymentBinId,
    String? dueBinId,
  }) async {
    try {
      if (masterKey != null) _masterKey = masterKey;
      if (apiUrl != null) _apiUrl = apiUrl;
      if (customerBinId != null) _customerBinId = customerBinId;
      if (paymentBinId != null) _paymentBinId = paymentBinId;
      if (dueBinId != null) _dueBinId = dueBinId;

      final config = {
        'masterKey': _masterKey,
        'apiUrl': _apiUrl,
        'customerBinId': _customerBinId,
        'paymentBinId': _paymentBinId,
        'dueBinId': _dueBinId,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      if (kIsWeb) {
        // Web platformunda localStorage kullan
        await _saveToLocalStorage(config);
      } else {
        // Mobil platformlarda dosya sistemi kullan
        final file = await _getConfigFile();
        await file.writeAsString(json.encode(config));
      }
    } catch (e) {
      print('JSONBin config kaydedilirken hata: $e');
      throw Exception('Konfigürasyon kaydedilemedi');
    }
  }

  // Web platformunda localStorage'dan yükle
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('jsonbin_config');
      if (configJson != null) {
        final config = json.decode(configJson);
        _masterKey = config['masterKey'] ?? _defaultMasterKey;
        _apiUrl = config['apiUrl'] ?? _defaultApiUrl;
        _customerBinId = config['customerBinId'] ?? _defaultCustomerBinId;
        _paymentBinId = config['paymentBinId'] ?? _defaultPaymentBinId;
        _dueBinId = config['dueBinId'] ?? _defaultDueBinId;
      }
    } catch (e) {
      print('SharedPreferences yüklenirken hata: $e');
    }
  }

  // Web platformunda localStorage'a kaydet
  Future<void> _saveToLocalStorage(Map<String, dynamic> config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jsonbin_config', json.encode(config));
    } catch (e) {
      print('SharedPreferences kaydedilirken hata: $e');
      throw Exception('Konfigürasyon kaydedilemedi');
    }
  }

  // Konfigürasyon dosyasını al
  Future<File> _getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_configFileName');
  }

  // Konfigürasyonu sıfırla
  Future<void> resetToDefaults() async {
    await saveConfig(
      masterKey: _defaultMasterKey,
      apiUrl: _defaultApiUrl,
      customerBinId: _defaultCustomerBinId,
      paymentBinId: _defaultPaymentBinId,
      dueBinId: _defaultDueBinId,
    );
  }

  // Konfigürasyon bilgilerini al
  Map<String, dynamic> getConfigInfo() {
    return {
      'masterKey': _masterKey,
      'apiUrl': _apiUrl,
      'customerBinId': _customerBinId,
      'paymentBinId': _paymentBinId,
      'dueBinId': _dueBinId,
    };
  }

  // Konfigürasyon geçerli mi kontrol et
  bool isConfigValid() {
    return _masterKey.isNotEmpty &&
        _apiUrl.isNotEmpty &&
        _customerBinId.isNotEmpty &&
        _paymentBinId.isNotEmpty &&
        _dueBinId.isNotEmpty;
  }
}
