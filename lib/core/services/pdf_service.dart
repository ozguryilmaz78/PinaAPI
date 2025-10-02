import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  // PDF oluşturma ve yazdırma
  Future<void> generateAndPrintPdf(pw.Document document) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => document.save(),
    );
  }

  // PDF'i dosyaya kaydetme
  Future<String> savePdfToFile(pw.Document document, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await document.save());
    return file.path;
  }

  // PDF'i paylaşma
  Future<void> sharePdf(pw.Document document, String fileName) async {
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: fileName,
    );
  }

  // PDF'i dosya olarak oluşturup paylaşma
  Future<void> createAndSharePdfFile(
      pw.Document document, String fileName) async {
    // PDF'i geçici dosya olarak kaydet
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await document.save());

    // Dosyayı paylaş
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'PİNA Raporu: $fileName',
      subject: 'PİNA Raporu - $fileName',
    );
  }

  // Temel PDF sayfa formatı
  PdfPageFormat getPageFormat() {
    return PdfPageFormat.a4;
  }

  // PDF başlık oluşturma
  pw.Widget buildHeader(String title, {String? subtitle}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.blue700,
              ),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // PDF alt bilgi oluşturma
  pw.Widget buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Pina Sanat Atölyesi',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            'Sayfa: ',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Tablo başlığı oluşturma
  pw.Widget buildTableHeader(List<String> headers) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: headers
            .map((header) => pw.Expanded(
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Tablo satırı oluşturma
  pw.Widget buildTableRow(List<String> cells, {bool isAlternate = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: isAlternate ? PdfColors.grey50 : PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: cells
            .map((cell) => pw.Expanded(
                  child: pw.Text(
                    cell,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey800,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Özet kartı oluşturma
  pw.Widget buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tarih formatı
  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Para formatı
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₺';
  }

  // Sayfa sonu
  pw.Widget buildPageBreak() {
    return pw.SizedBox(height: 20);
  }
}
