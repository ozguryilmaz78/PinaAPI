import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/services/pdf_service.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../due/domain/entities/due.dart';
import '../../../payment/domain/entities/payment.dart';

class DebtCreditPdfService {
  final PdfService _pdfService = PdfService();

  // Müşteri borç/alacak raporu PDF'i oluşturma
  Future<pw.Document> generateCustomerDebtCreditReportPdf(
    List<CustomerDebtInfo> customerDebts,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Müşteri Borç/Alacak Raporu',
          subtitle: 'Toplam ${customerDebts.length} müşteri',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildSummaryCards(customerDebts),
          pw.SizedBox(height: 20),

          // Müşteri borç/alacak tablosu
          _buildCustomerDebtTable(customerDebts),
        ],
      ),
    );

    return document;
  }

  // Özet kartları oluşturma
  pw.Widget _buildSummaryCards(List<CustomerDebtInfo> customerDebts) {
    final customersInDebt =
        customerDebts.where((info) => info.balance < 0).length;
    final customersWithCredit =
        customerDebts.where((info) => info.balance > 0).length;
    final totalDebt = customerDebts.fold<double>(
        0.0, (sum, info) => sum + (info.balance < 0 ? info.balance.abs() : 0));
    final totalCredit = customerDebts.fold<double>(
        0.0, (sum, info) => sum + (info.balance > 0 ? info.balance : 0));

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Borçlu Müşteri',
            '$customersInDebt',
            PdfColors.red,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Alacaklı Müşteri',
            '$customersWithCredit',
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Borç',
            _pdfService.formatCurrency(totalDebt),
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Alacak',
            _pdfService.formatCurrency(totalCredit),
            PdfColors.blue,
          ),
        ),
      ],
    );
  }

  // Müşteri borç/alacak tablosu oluşturma
  pw.Widget _buildCustomerDebtTable(List<CustomerDebtInfo> customerDebts) {
    return pw.Column(
      children: [
        // Tablo başlığı
        _pdfService.buildTableHeader([
          'Sıra',
          'Müşteri',
          'Toplam Tahakkuk',
          'Toplam Ödeme',
          'Bakiye',
          'Durum',
          'Bekleyen Ödeme',
        ]),

        // Tablo satırları
        ...customerDebts.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final debtInfo = entry.value;
          final isInDebt = debtInfo.balance < 0;
          final statusText = isInDebt ? 'Borçlu' : 'Alacaklı';

          return _pdfService.buildTableRow([
            '$index',
            '${debtInfo.customer.firstName} ${debtInfo.customer.lastName}',
            _pdfService.formatCurrency(debtInfo.totalDues),
            _pdfService.formatCurrency(debtInfo.totalPayments),
            _pdfService.formatCurrency(debtInfo.balance.abs()),
            statusText,
            '${debtInfo.pendingDues.length}',
          ], isAlternate: index % 2 == 0);
        }),
      ],
    );
  }

  // Genel borç/alacak özeti PDF'i oluşturma
  Future<pw.Document> generateGeneralDebtCreditSummaryPdf(
    List<CustomerDebtInfo> customerDebts,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Genel Borç/Alacak Özeti',
          subtitle: 'Finansal Durum Raporu',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Genel özet kartları
          _buildGeneralSummaryCards(customerDebts),
          pw.SizedBox(height: 20),

          // Detaylı analiz
          _buildDetailedAnalysis(customerDebts),
          pw.SizedBox(height: 20),

          // En yüksek borçlular
          _buildTopDebtors(customerDebts),
          pw.SizedBox(height: 20),

          // En yüksek alacaklılar
          _buildTopCreditors(customerDebts),
        ],
      ),
    );

    return document;
  }

  // Genel özet kartları oluşturma
  pw.Widget _buildGeneralSummaryCards(List<CustomerDebtInfo> customerDebts) {
    final totalDebt = customerDebts.fold<double>(
        0.0, (sum, info) => sum + (info.balance < 0 ? info.balance.abs() : 0));
    final totalCredit = customerDebts.fold<double>(
        0.0, (sum, info) => sum + (info.balance > 0 ? info.balance : 0));
    final netBalance = totalCredit - totalDebt;
    final totalCustomers = customerDebts.length;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Borç',
            _pdfService.formatCurrency(totalDebt),
            PdfColors.red,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Alacak',
            _pdfService.formatCurrency(totalCredit),
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Net Bakiye',
            _pdfService.formatCurrency(netBalance),
            netBalance >= 0 ? PdfColors.green : PdfColors.red,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Müşteri',
            '$totalCustomers',
            PdfColors.blue,
          ),
        ),
      ],
    );
  }

  // Detaylı analiz oluşturma
  pw.Widget _buildDetailedAnalysis(List<CustomerDebtInfo> customerDebts) {
    final customersInDebt =
        customerDebts.where((info) => info.balance < 0).length;
    final customersWithCredit =
        customerDebts.where((info) => info.balance > 0).length;
    final customersWithZeroBalance =
        customerDebts.where((info) => info.balance == 0).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Detaylı Analiz',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildAnalysisRow('Borçlu Müşteri Sayısı:', '$customersInDebt'),
          _buildAnalysisRow('Alacaklı Müşteri Sayısı:', '$customersWithCredit'),
          _buildAnalysisRow(
              'Sıfır Bakiye Müşteri:', '$customersWithZeroBalance'),
          _buildAnalysisRow('Toplam Müşteri:', '${customerDebts.length}'),
        ],
      ),
    );
  }

  // Analiz satırı oluşturma
  pw.Widget _buildAnalysisRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // En yüksek borçlular oluşturma
  pw.Widget _buildTopDebtors(List<CustomerDebtInfo> customerDebts) {
    final topDebtors = customerDebts.where((info) => info.balance < 0).toList()
      ..sort((a, b) => a.balance.compareTo(b.balance))
      ..take(5);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.red200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'En Yüksek Borçlular (Top 5)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red900,
            ),
          ),
          pw.SizedBox(height: 12),
          ...topDebtors
              .map((debtInfo) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${debtInfo.customer.firstName} ${debtInfo.customer.lastName}',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ),
                        pw.Text(
                          _pdfService.formatCurrency(debtInfo.balance.abs()),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  ))
              ,
        ],
      ),
    );
  }

  // En yüksek alacaklılar oluşturma
  pw.Widget _buildTopCreditors(List<CustomerDebtInfo> customerDebts) {
    final topCreditors =
        customerDebts.where((info) => info.balance > 0).toList()
          ..sort((a, b) => b.balance.compareTo(a.balance))
          ..take(5);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'En Yüksek Alacaklılar (Top 5)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 12),
          ...topCreditors
              .map((debtInfo) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${debtInfo.customer.firstName} ${debtInfo.customer.lastName}',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ),
                        pw.Text(
                          _pdfService.formatCurrency(debtInfo.balance),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                  ))
              ,
        ],
      ),
    );
  }
}

class CustomerDebtInfo {
  final Customer customer;
  final double totalDues;
  final double totalPayments;
  final double balance;
  final List<Due> pendingDues;
  final List<Due> allDues;
  final List<Payment> allPayments;

  CustomerDebtInfo({
    required this.customer,
    required this.totalDues,
    required this.totalPayments,
    required this.balance,
    required this.pendingDues,
    required this.allDues,
    required this.allPayments,
  });
}
