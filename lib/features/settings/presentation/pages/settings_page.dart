import 'package:flutter/material.dart';
import '../../../../core/services/jsonbin_service.dart';
import '../../../../core/config/jsonbin_config.dart';
import '../../../../core/services/service_locator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final JsonBinService _jsonBinService = JsonBinService();
  final JsonBinConfig _jsonBinConfig = JsonBinConfig();

  bool _isLoading = false;

  // JSONBin ayarları için controller'lar
  final TextEditingController _masterKeyController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _customerBinIdController =
      TextEditingController();
  final TextEditingController _paymentBinIdController = TextEditingController();
  final TextEditingController _dueBinIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndLoadConfig();
  }

  @override
  void dispose() {
    _masterKeyController.dispose();
    _apiUrlController.dispose();
    _customerBinIdController.dispose();
    _paymentBinIdController.dispose();
    _dueBinIdController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadConfig() async {
    setState(() => _isLoading = true);
    try {
      // Service locator'dan JSONBin servisini başlat
      await ServiceLocator().initializeJsonBin();

      // Konfigürasyonu yükle
      await _jsonBinConfig.loadConfig();
      final config = _jsonBinConfig.getConfigInfo();

      _masterKeyController.text = config['masterKey'] ?? '';
      _apiUrlController.text = config['apiUrl'] ?? '';
      _customerBinIdController.text = config['customerBinId'] ?? '';
      _paymentBinIdController.text = config['paymentBinId'] ?? '';
      _dueBinIdController.text = config['dueBinId'] ?? '';
    } catch (e) {
      _showErrorDialog('JSONBin konfigürasyonu yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeAndLoadConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('JSONBin.io Konfigürasyonu'),
                  const SizedBox(height: 16),
                  _buildJsonBinConfigSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('JSONBin.io Test'),
                  const SizedBox(height: 16),
                  _buildJsonBinTestButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Başarılı'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonBinConfigSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JSONBin.io API Ayarları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildConfigField(
              controller: _masterKeyController,
              label: 'X-Master-Key',
              hint: 'API anahtarınızı girin',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            _buildConfigField(
              controller: _apiUrlController,
              label: 'API URL',
              hint: 'https://api.jsonbin.io/v3/b',
            ),
            const SizedBox(height: 16),
            Text(
              'Bin ID\'ler',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildConfigField(
              controller: _customerBinIdController,
              label: 'Müşteri Bin ID',
              hint: 'Müşteri verileri için bin ID',
            ),
            const SizedBox(height: 12),
            _buildConfigField(
              controller: _paymentBinIdController,
              label: 'Ödeme Bin ID',
              hint: 'Ödeme verileri için bin ID',
            ),
            const SizedBox(height: 12),
            _buildConfigField(
              controller: _dueBinIdController,
              label: 'Tahakkuk Bin ID',
              hint: 'Tahakkuk verileri için bin ID',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveJsonBinConfig,
                    icon: const Icon(Icons.save),
                    label: const Text('Kaydet'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetJsonBinConfig,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Sıfırla'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildJsonBinTestButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JSONBin.io Bağlantı Testi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testJsonBinConnections,
                icon: const Icon(Icons.wifi),
                label: const Text('JSONBin Bağlantılarını Test Et'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveJsonBinConfig() async {
    try {
      setState(() => _isLoading = true);

      await _jsonBinConfig.saveConfig(
        masterKey: _masterKeyController.text.trim(),
        apiUrl: _apiUrlController.text.trim(),
        customerBinId: _customerBinIdController.text.trim(),
        paymentBinId: _paymentBinIdController.text.trim(),
        dueBinId: _dueBinIdController.text.trim(),
      );

      // JSONBin servisini yeniden başlat
      await _jsonBinService.initialize();

      _showSuccessDialog('JSONBin konfigürasyonu başarıyla kaydedildi');
    } catch (e) {
      _showErrorDialog('Konfigürasyon kaydedilemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetJsonBinConfig() async {
    try {
      setState(() => _isLoading = true);

      await _jsonBinConfig.resetToDefaults();
      await _initializeAndLoadConfig();

      _showSuccessDialog(
          'JSONBin konfigürasyonu varsayılan değerlere sıfırlandı');
    } catch (e) {
      _showErrorDialog('Konfigürasyon sıfırlanamadı: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testJsonBinConnections() async {
    try {
      setState(() => _isLoading = true);

      // Önce konfigürasyonu güncelle
      await _jsonBinService.updateConfig(
        masterKey: _masterKeyController.text.trim(),
        apiUrl: _apiUrlController.text.trim(),
        customerBinId: _customerBinIdController.text.trim(),
        paymentBinId: _paymentBinIdController.text.trim(),
        dueBinId: _dueBinIdController.text.trim(),
      );

      // Servisi yeniden başlat
      await _jsonBinService.initialize();

      // Bağlantıları test et
      final results = await _jsonBinService.testAllConnections();

      if (results.containsKey('error')) {
        _showErrorDialog('JSONBin bağlantı testi hatası: ${results['error']}');
        return;
      }

      final customerResult = results['customers'] as Map<String, dynamic>;
      final paymentResult = results['payments'] as Map<String, dynamic>;
      final dueResult = results['dues'] as Map<String, dynamic>;

      final customerCount = customerResult['success']
          ? (customerResult['data']['record'] as List).length
          : 0;
      final paymentCount = paymentResult['success']
          ? (paymentResult['data']['record'] as List).length
          : 0;
      final dueCount = dueResult['success']
          ? (dueResult['data']['record'] as List).length
          : 0;

      String message = 'JSONBin.io bağlantı testi sonuçları:\n\n';
      message +=
          '📊 Müşteri verileri: $customerCount kayıt (Status: ${customerResult['status']})\n';
      message +=
          '📊 Ödeme verileri: $paymentCount kayıt (Status: ${paymentResult['status']})\n';
      message +=
          '📊 Tahakkuk verileri: $dueCount kayıt (Status: ${dueResult['status']})\n\n';

      if (customerResult['success'] &&
          paymentResult['success'] &&
          dueResult['success']) {
        message += '✅ Tüm bağlantılar başarılı!';
      } else {
        message += '⚠️ Bazı bağlantılarda sorun var.';
      }

      _showSuccessDialog(message);
    } catch (e) {
      _showErrorDialog('JSONBin bağlantı testi hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
