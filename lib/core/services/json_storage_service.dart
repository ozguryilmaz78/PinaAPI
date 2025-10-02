import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonStorageService {
  static const String _customersFileName = 'musteri.json';
  static const String _paymentsFileName = 'odeme.json';
  static const String _duesFileName = 'tahakkuk.json';

  Future<File> getFile(String fileName) async {
    // Android için external storage kullan
    Directory directory;
    if (Platform.isAndroid) {
      // Android'de external storage kullan
      directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      // Diğer platformlar için documents directory
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/$fileName');
    return file;
  }

  Future<void> writeJson(String fileName, Map<String, dynamic> data) async {
    final file = await getFile(fileName);
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>> readJson(String fileName) async {
    try {
      final file = await getFile(fileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> readJsonList(String fileName) async {
    try {
      final file = await getFile(fileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> writeJsonList(
      String fileName, List<Map<String, dynamic>> data) async {
    final file = await getFile(fileName);

    // Dosya dizinini oluştur
    await file.parent.create(recursive: true);

    await file.writeAsString(jsonEncode(data));
  }

  // Specific methods for each data type
  Future<void> saveCustomers(List<Map<String, dynamic>> customers) async {
    await writeJsonList(_customersFileName, customers);
  }

  Future<List<Map<String, dynamic>>> loadCustomers() async {
    return await readJsonList(_customersFileName);
  }

  Future<void> savePayments(List<Map<String, dynamic>> payments) async {
    await writeJsonList(_paymentsFileName, payments);
  }

  Future<List<Map<String, dynamic>>> loadPayments() async {
    return await readJsonList(_paymentsFileName);
  }

  Future<void> saveDues(List<Map<String, dynamic>> dues) async {
    await writeJsonList(_duesFileName, dues);
  }

  Future<List<Map<String, dynamic>>> loadDues() async {
    return await readJsonList(_duesFileName);
  }
}
