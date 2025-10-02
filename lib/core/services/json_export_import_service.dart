import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'jsonbin_service.dart';

class JsonExportImportService {
  static final JsonExportImportService _instance =
      JsonExportImportService._internal();
  factory JsonExportImportService() => _instance;
  JsonExportImportService._internal();

  final JsonBinService _jsonBinService = JsonBinService();

  // JSON dosyalarını export etme
  Future<void> exportJsonFiles() async {
    try {
      print('📤 Export işlemi başlatılıyor...');

      // JSONBin.io'dan verileri çek
      print('📡 JSONBin.io\'dan veriler çekiliyor...');
      final customers = await _jsonBinService.getCustomers();
      final payments = await _jsonBinService.getPayments();
      final dues = await _jsonBinService.getDues();

      print('📊 Veriler çekildi:');
      print('  - Müşteri: ${customers.length} kayıt');
      print('  - Ödeme: ${payments.length} kayıt');
      print('  - Tahakkuk: ${dues.length} kayıt');

      // Geçici dosyalar oluştur
      Directory directory = await getApplicationDocumentsDirectory();
      final filesToShare = <XFile>[];

      // Müşteri dosyası
      if (customers.isNotEmpty) {
        final customerFile = File('${directory.path}/musteri.json');
        await customerFile.writeAsString(jsonEncode(customers));
        filesToShare.add(XFile(customerFile.path));
        print('✅ musteri.json oluşturuldu');
      }

      // Ödeme dosyası
      if (payments.isNotEmpty) {
        final paymentFile = File('${directory.path}/odeme.json');
        await paymentFile.writeAsString(jsonEncode(payments));
        filesToShare.add(XFile(paymentFile.path));
        print('✅ odeme.json oluşturuldu');
      }

      // Tahakkuk dosyası
      if (dues.isNotEmpty) {
        final dueFile = File('${directory.path}/tahakkuk.json');
        await dueFile.writeAsString(jsonEncode(dues));
        filesToShare.add(XFile(dueFile.path));
        print('✅ tahakkuk.json oluşturuldu');
      }

      print('📤 Paylaşılacak dosya sayısı: ${filesToShare.length}');

      if (filesToShare.isNotEmpty) {
        await Share.shareXFiles(
          filesToShare,
          text: 'Pina Aidat - Veri Dosyaları (JSONBin.io\'dan export)',
          subject: 'Pina Aidat Veri Export',
        );
        print('✅ Share işlemi başlatıldı');
      } else {
        throw Exception('Export edilecek veri bulunamadı');
      }
    } catch (e) {
      print('💥 Export hatası: $e');
      throw Exception('Export işlemi başarısız: $e');
    }
  }

  // JSON dosyalarını tek tek export etme
  Future<void> exportCustomers() async {
    try {
      print('📤 Müşteri export işlemi başlatılıyor...');

      // JSONBin.io'dan müşteri verilerini çek
      final customers = await _jsonBinService.getCustomers();

      if (customers.isNotEmpty) {
        // Geçici dosya oluştur
        Directory directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/musteri.json');
        await file.writeAsString(jsonEncode(customers));

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Pina Aidat - Müşteri Verileri (JSONBin.io\'dan export)',
          subject: 'Müşteri Listesi Export',
        );
        print('✅ Müşteri export tamamlandı: ${customers.length} kayıt');
      } else {
        throw Exception('Müşteri verisi bulunamadı');
      }
    } catch (e) {
      print('💥 Müşteri export hatası: $e');
      throw Exception('Müşteri export işlemi başarısız: $e');
    }
  }

  Future<void> exportPayments() async {
    try {
      print('📤 Ödeme export işlemi başlatılıyor...');

      // JSONBin.io'dan ödeme verilerini çek
      final payments = await _jsonBinService.getPayments();

      if (payments.isNotEmpty) {
        // Geçici dosya oluştur
        Directory directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/odeme.json');
        await file.writeAsString(jsonEncode(payments));

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Pina Aidat - Ödeme Verileri (JSONBin.io\'dan export)',
          subject: 'Ödeme Listesi Export',
        );
        print('✅ Ödeme export tamamlandı: ${payments.length} kayıt');
      } else {
        throw Exception('Ödeme verisi bulunamadı');
      }
    } catch (e) {
      print('💥 Ödeme export hatası: $e');
      throw Exception('Ödeme export işlemi başarısız: $e');
    }
  }

  Future<void> exportDues() async {
    try {
      print('📤 Tahakkuk export işlemi başlatılıyor...');

      // JSONBin.io'dan tahakkuk verilerini çek
      final dues = await _jsonBinService.getDues();

      if (dues.isNotEmpty) {
        // Geçici dosya oluştur
        Directory directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/tahakkuk.json');
        await file.writeAsString(jsonEncode(dues));

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Pina Aidat - Tahakkuk Verileri (JSONBin.io\'dan export)',
          subject: 'Tahakkuk Listesi Export',
        );
        print('✅ Tahakkuk export tamamlandı: ${dues.length} kayıt');
      } else {
        throw Exception('Tahakkuk verisi bulunamadı');
      }
    } catch (e) {
      print('💥 Tahakkuk export hatası: $e');
      throw Exception('Tahakkuk export işlemi başarısız: $e');
    }
  }

  // JSON dosyalarını import etme
  Future<void> importJsonFile(String filePath, String fileType) async {
    try {
      print('Import başlatılıyor: $filePath, tip: $fileType');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Dosya bulunamadı: $filePath');
      }

      final content = await file.readAsString();
      print('Dosya içeriği okundu, boyut: ${content.length} karakter');

      final jsonData = jsonDecode(content);

      if (jsonData is! List) {
        throw Exception('Geçersiz JSON formatı - Liste bekleniyor');
      }

      print('JSON geçerli, ${jsonData.length} kayıt bulundu');

      // Android için external storage kullan, diğer platformlar için documents directory
      Directory directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String targetFileName;

      switch (fileType) {
        case 'customers':
          targetFileName = 'musteri.json';
          break;
        case 'payments':
          targetFileName = 'odeme.json';
          break;
        case 'dues':
          targetFileName = 'tahakkuk.json';
          break;
        default:
          throw Exception('Geçersiz dosya tipi: $fileType');
      }

      final targetFile = File('${directory.path}/$targetFileName');
      print('Hedef dosya: ${targetFile.path}');

      await targetFile.writeAsString(content);
      print('Dosya başarıyla kaydedildi');
    } catch (e) {
      print('Import hatası: $e');
      throw Exception('Import işlemi başarısız: $e');
    }
  }

  // Dosya bilgilerini alma
  Future<Map<String, dynamic>> getFileInfo() async {
    try {
      // Android için external storage kullan, diğer platformlar için documents directory
      Directory directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Debug: Dizin yolunu yazdır
      print('Dosya dizini: ${directory.path}');

      final customerFile = File('${directory.path}/musteri.json');
      final paymentFile = File('${directory.path}/odeme.json');
      final dueFile = File('${directory.path}/tahakkuk.json');

      // Eski aidat.json dosyasını tahakkuk.json olarak yeniden adlandır
      final oldDueFile = File('${directory.path}/aidat.json');
      if (await oldDueFile.exists() && !await dueFile.exists()) {
        print(
            'aidat.json bulundu, tahakkuk.json olarak yeniden adlandırılıyor');
        await oldDueFile.rename(dueFile.path);
      }

      // Debug: Dosya durumlarını yazdır
      print('musteri.json var mı: ${await customerFile.exists()}');
      print('odeme.json var mı: ${await paymentFile.exists()}');
      print('tahakkuk.json var mı: ${await dueFile.exists()}');

      return {
        'customers': {
          'exists': await customerFile.exists(),
          'size': await customerFile.exists() ? await customerFile.length() : 0,
          'lastModified': await customerFile.exists()
              ? (await customerFile.lastModified()).millisecondsSinceEpoch
              : null,
        },
        'payments': {
          'exists': await paymentFile.exists(),
          'size': await paymentFile.exists() ? await paymentFile.length() : 0,
          'lastModified': await paymentFile.exists()
              ? (await paymentFile.lastModified()).millisecondsSinceEpoch
              : null,
        },
        'dues': {
          'exists': await dueFile.exists(),
          'size': await dueFile.exists() ? await dueFile.length() : 0,
          'lastModified': await dueFile.exists()
              ? (await dueFile.lastModified()).millisecondsSinceEpoch
              : null,
        },
      };
    } catch (e) {
      return {};
    }
  }

  // Dosya boyutunu formatla
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Tarih formatla
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
