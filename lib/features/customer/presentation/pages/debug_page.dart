import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/config/api_config.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final ApiService _apiService = ApiService();
  final ApiConfig _apiConfig = ApiConfig();
  String _debugInfo = '';
  String _connectionInfo = '';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      // API konfigürasyonunu yükle
      await _apiConfig.loadConfig();
      final config = _apiConfig.getConfigInfo();

      _connectionInfo = '''
Base URL: ${config['baseUrl']}
API Version: ${config['apiVersion']}
Timeout: ${config['timeoutSeconds']}s
Health URL: ${config['healthUrl']}
Customers URL: ${config['customersUrl']}
Payments URL: ${config['paymentsUrl']}
Dues URL: ${config['duesUrl']}
      ''';

      // API'den müşteri verilerini yükle
      final customers = await _apiService.getCustomers();

      setState(() {
        _debugInfo = '''
📊 API Bağlantı Bilgileri:
$_connectionInfo

📊 Müşteri Sayısı: ${customers.length}

📋 Müşteri Verileri:
${customers.map((c) => '• ${c['first_name']} ${c['last_name']} (${c['status']})').join('\n')}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = '''
❌ Hata oluştu:
$e

📊 API Bağlantı Bilgileri:
$_connectionInfo
        ''';
      });
    }
  }

  Future<void> _testApiConnection() async {
    try {
      setState(() {
        _debugInfo = '🔄 API bağlantısı test ediliyor...';
      });

      final result = await _apiConfig.checkHealth();

      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          _debugInfo = '''
✅ API Bağlantısı Başarılı!

📊 API Health Check:
• Status: ${data['success'] ? 'Healthy' : 'Unhealthy'}
• Message: ${data['message']}
• Version: ${data['version'] ?? 'N/A'}
• Environment: ${data['environment'] ?? 'N/A'}
• Timestamp: ${data['timestamp'] ?? 'N/A'}

📊 API Bağlantı Bilgileri:
$_connectionInfo
          ''';
        });
      } else {
        setState(() {
          _debugInfo = '''
❌ API Bağlantısı Başarısız!

📊 Hata Detayı:
${result['message']}

📊 API Bağlantı Bilgileri:
$_connectionInfo
          ''';
        });
      }
    } catch (e) {
      setState(() {
        _debugInfo = '''
❌ API Test Hatası:
$e

📊 API Bağlantı Bilgileri:
$_connectionInfo
        ''';
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _debugInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debug bilgileri panoya kopyalandı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Bilgileri'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Panoya Kopyala',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadDebugInfo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yenile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testApiConnection,
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('API Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Debug bilgileri
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _debugInfo.isEmpty
                        ? 'Debug bilgileri yükleniyor...'
                        : _debugInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bilgi kartı
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Debug Bilgileri',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Yenile: API bağlantısını ve müşteri verilerini yükler\n'
                      '• API Test: API health check yapar\n'
                      '• Kopyala: Debug bilgilerini panoya kopyalar',
                      style: TextStyle(fontSize: 12),
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
