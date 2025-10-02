import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConfig {
  // Varsayılan değerler
  static const String _defaultBaseUrl = 'https://pinaapi.onrender.com';
  static const String _defaultApiVersion = 'v1';
  static const int _defaultTimeoutSeconds = 30;

  // Konfigürasyon değerleri
  String _baseUrl = _defaultBaseUrl;
  String _apiVersion = _defaultApiVersion;
  int _timeoutSeconds = _defaultTimeoutSeconds;

  // Getters
  String get baseUrl => _baseUrl;
  String get apiVersion => _apiVersion;
  int get timeoutSeconds => _timeoutSeconds;

  // API URL'leri
  String get healthUrl => '$_baseUrl/health';
  String get customersUrl => '$_baseUrl/api/$_apiVersion/musteriler';
  String get paymentsUrl => '$_baseUrl/api/$_apiVersion/odemeler';
  String get duesUrl => '$_baseUrl/api/$_apiVersion/tahakkuklar';

  // Konfigürasyonu yükle
  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('api_base_url') ?? _defaultBaseUrl;
      _apiVersion = prefs.getString('api_version') ?? _defaultApiVersion;
      _timeoutSeconds =
          prefs.getInt('api_timeout_seconds') ?? _defaultTimeoutSeconds;

      print('🔧 API Config loaded:');
      print('   Base URL: $_baseUrl');
      print('   API Version: $_apiVersion');
      print('   Timeout: ${_timeoutSeconds}s');
    } catch (e) {
      print('💥 API Config load error: $e');
      rethrow;
    }
  }

  // Konfigürasyonu kaydet
  Future<void> saveConfig({
    String? baseUrl,
    String? apiVersion,
    int? timeoutSeconds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (baseUrl != null) {
        _baseUrl =
            baseUrl.replaceAll(RegExp(r'/$'), ''); // Sondaki slash'i kaldır
        await prefs.setString('api_base_url', _baseUrl);
      }

      if (apiVersion != null) {
        _apiVersion = apiVersion;
        await prefs.setString('api_version', apiVersion);
      }

      if (timeoutSeconds != null) {
        _timeoutSeconds = timeoutSeconds;
        await prefs.setInt('api_timeout_seconds', timeoutSeconds);
      }

      print('💾 API Config saved successfully');
    } catch (e) {
      print('💥 API Config save error: $e');
      rethrow;
    }
  }

  // Health check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      print('🏥 Checking API health: $healthUrl');

      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Health Check successful');
        return {
          'success': true,
          'data': data,
          'message': 'API bağlantısı başarılı',
        };
      } else {
        print('❌ API Health Check failed: ${response.statusCode}');
        return {
          'success': false,
          'message': 'API bağlantısı başarısız (${response.statusCode})',
          'error': response.body,
        };
      }
    } catch (e) {
      print('💥 API Health Check error: $e');
      return {
        'success': false,
        'message': 'API bağlantı hatası: $e',
        'error': e.toString(),
      };
    }
  }

  // Konfigürasyon bilgilerini al
  Map<String, dynamic> getConfigInfo() {
    return {
      'baseUrl': _baseUrl,
      'apiVersion': _apiVersion,
      'timeoutSeconds': _timeoutSeconds,
      'healthUrl': healthUrl,
      'customersUrl': customersUrl,
      'paymentsUrl': paymentsUrl,
      'duesUrl': duesUrl,
    };
  }

  // Konfigürasyonu sıfırla
  Future<void> resetToDefaults() async {
    await saveConfig(
      baseUrl: _defaultBaseUrl,
      apiVersion: _defaultApiVersion,
      timeoutSeconds: _defaultTimeoutSeconds,
    );
  }

  // Konfigürasyon geçerli mi kontrol et
  bool isConfigValid() {
    return _baseUrl.isNotEmpty &&
        _apiVersion.isNotEmpty &&
        _timeoutSeconds > 0 &&
        Uri.tryParse(_baseUrl) != null;
  }

  // URL'i temizle (sondaki slash'leri kaldır)
  String _cleanUrl(String url) {
    return url.replaceAll(RegExp(r'/+$'), '');
  }
}


