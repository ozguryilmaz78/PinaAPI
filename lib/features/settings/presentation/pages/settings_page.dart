import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ApiConfig _apiConfig = ApiConfig();

  bool _isLoading = false;
  bool _isTestingConnection = false;

  // API ayarları için controller'lar
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _apiVersionController = TextEditingController();
  final TextEditingController _timeoutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndLoadConfig();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiVersionController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadConfig() async {
    setState(() => _isLoading = true);
    try {
      // Konfigürasyonu yükle
      await _apiConfig.loadConfig();
      final config = _apiConfig.getConfigInfo();

      _baseUrlController.text = config['baseUrl'] ?? '';
      _apiVersionController.text = config['apiVersion'] ?? '';
      _timeoutController.text = config['timeoutSeconds']?.toString() ?? '';

      print('✅ API Config loaded successfully');
    } catch (e) {
      print('💥 Error loading API config: $e');
      _showErrorSnackBar('Ayarlar yüklenirken hata oluştu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);
    try {
      await _apiConfig.saveConfig(
        baseUrl: _baseUrlController.text.trim(),
        apiVersion: _apiVersionController.text.trim(),
        timeoutSeconds: int.parse(_timeoutController.text.trim()),
      );

      _showSuccessSnackBar('API ayarları başarıyla kaydedildi');
      print('✅ API Config saved successfully');
    } catch (e) {
      print('💥 Error saving API config: $e');
      _showErrorSnackBar('Ayarlar kaydedilirken hata oluştu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    if (!_validateInputs()) return;

    setState(() => _isTestingConnection = true);
    try {
      // Önce ayarları kaydet
      await _apiConfig.saveConfig(
        baseUrl: _baseUrlController.text.trim(),
        apiVersion: _apiVersionController.text.trim(),
        timeoutSeconds: int.parse(_timeoutController.text.trim()),
      );

      // Health check yap
      final result = await _apiConfig.checkHealth();

      if (result['success'] == true) {
        final data = result['data'];
        _showSuccessDialog(
          'API Bağlantısı Başarılı!',
          'API sağlıklı çalışıyor.\n\n'
              'Versiyon: ${data['version'] ?? 'Bilinmiyor'}\n'
              'Ortam: ${data['environment'] ?? 'Bilinmiyor'}\n'
              'Zaman: ${data['timestamp'] ?? 'Bilinmiyor'}',
        );
      } else {
        _showErrorDialog(
          'API Bağlantısı Başarısız!',
          result['message'] ?? 'Bilinmeyen hata',
        );
      }
    } catch (e) {
      print('💥 Error testing API connection: $e');
      _showErrorDialog(
          'Bağlantı Testi Hatası', 'Bağlantı test edilirken hata oluştu: $e');
    } finally {
      setState(() => _isTestingConnection = false);
    }
  }

  bool _validateInputs() {
    if (_baseUrlController.text.trim().isEmpty) {
      _showErrorSnackBar('API Base URL boş olamaz');
      return false;
    }

    if (_apiVersionController.text.trim().isEmpty) {
      _showErrorSnackBar('API Version boş olamaz');
      return false;
    }

    final timeout = int.tryParse(_timeoutController.text.trim());
    if (timeout == null || timeout <= 0) {
      _showErrorSnackBar('Timeout geçerli bir sayı olmalıdır (>0)');
      return false;
    }

    final uri = Uri.tryParse(_baseUrlController.text.trim());
    if (uri == null || !uri.hasScheme) {
      _showErrorSnackBar('Geçerli bir URL giriniz (https://... ile başlamalı)');
      return false;
    }

    return true;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Ayarları'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // API Bilgileri Kartı
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.api, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'API Bağlantı Ayarları',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Base URL
                          TextFormField(
                            controller: _baseUrlController,
                            decoration: const InputDecoration(
                              labelText: 'API Base URL',
                              hintText: 'https://pinaapi.onrender.com',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.link),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 16),

                          // API Version
                          TextFormField(
                            controller: _apiVersionController,
                            decoration: const InputDecoration(
                              labelText: 'API Version',
                              hintText: 'v1',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Timeout
                          TextFormField(
                            controller: _timeoutController,
                            decoration: const InputDecoration(
                              labelText: 'Timeout (saniye)',
                              hintText: '30',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Butonlar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isTestingConnection ? null : _testConnection,
                          icon: _isTestingConnection
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.health_and_safety),
                          label: Text(_isTestingConnection
                              ? 'Test Ediliyor...'
                              : 'Bağlantıyı Test Et'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveConfig,
                          icon: const Icon(Icons.save),
                          label: const Text('Kaydet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sıfırla Butonu
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Ayarları Sıfırla'),
                                content: const Text(
                                    'Tüm API ayarları varsayılan değerlere sıfırlanacak. Emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Sıfırla',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await _apiConfig.resetToDefaults();
                              await _initializeAndLoadConfig();
                              _showSuccessSnackBar(
                                  'Ayarlar varsayılan değerlere sıfırlandı');
                            }
                          },
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: const Text('Varsayılan Değerlere Sıfırla',
                        style: TextStyle(color: Colors.red)),
                  ),

                  const SizedBox(height: 24),

                  // Bilgi Kartı
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Bilgi',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• API Base URL: Ana API sunucu adresi\n'
                            '• API Version: Kullanılacak API versiyonu\n'
                            '• Timeout: İstek zaman aşımı süresi\n'
                            '• Health Check: API durumunu kontrol eder',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
