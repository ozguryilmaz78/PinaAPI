import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/services/pdf_service.dart';
import '../../domain/entities/payment.dart';
import '../../../customer/domain/entities/customer.dart';

class PaymentPdfService {
  final PdfService _pdfService = PdfService();

  // Ödeme listesi PDF'i oluşturma
  Future<pw.Document> generatePaymentListPdf(
    List<Payment> payments,
    List<Customer> customers,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Ödeme Listesi',
          subtitle: 'Toplam ${payments.length} ödeme',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildSummaryCards(payments),
          pw.SizedBox(height: 20),

          // Ödeme tablosu
          _buildPaymentTable(payments, customers),
        ],
      ),
    );

    return document;
  }

  // Özet kartları oluşturma
  pw.Widget _buildSummaryCards(List<Payment> payments) {
    final totalAmount =
        payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final cashPayments =
        payments.where((p) => p.method == PaymentMethod.cash).length;
    final cardPayments =
        payments.where((p) => p.method == PaymentMethod.card).length;
    final transferPayments =
        payments.where((p) => p.method == PaymentMethod.bank).length;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Tutar',
            _pdfService.formatCurrency(totalAmount),
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Nakit',
            '$cashPayments',
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Kart',
            '$cardPayments',
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Havale',
            '$transferPayments',
            PdfColors.purple,
          ),
        ),
      ],
    );
  }

  // Ödeme tablosu oluşturma
  pw.Widget _buildPaymentTable(
      List<Payment> payments, List<Customer> customers) {
    return pw.Column(
      children: [
        // Tablo başlığı
        _pdfService.buildTableHeader([
          'Sıra',
          'Müşteri',
          'Tutar',
          'Ödeme Yöntemi',
          'Ödeme Tarihi',
          'Notlar',
          'Oluşturma Tarihi',
        ]),

        // Tablo satırları
        ...payments.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final payment = entry.value;
          final customer = customers.firstWhere(
            (c) => c.id == payment.customerId,
            orElse: () => Customer(
              id: 'unknown',
              firstName: 'Bilinmeyen',
              lastName: 'Müşteri',
              phone: '',
              email: '',
              address: '',
              status: CustomerStatus.inactive,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          return _pdfService.buildTableRow([
            '$index',
            '${customer.firstName} ${customer.lastName}',
            _pdfService.formatCurrency(payment.amount),
            _getPaymentMethodText(payment.method),
            _pdfService.formatDate(payment.paymentDate),
            payment.notes?.isNotEmpty == true ? payment.notes! : '-',
            _pdfService.formatDate(payment.createdAt),
          ], isAlternate: index % 2 == 0);
        }),
      ],
    );
  }

  // Ödeme yöntemi metni
  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.card:
        return 'Kart';
      case PaymentMethod.bank:
        return 'Havale';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }

  // Aylık ödeme raporu PDF'i oluşturma
  Future<pw.Document> generateMonthlyPaymentReportPdf(
    List<Payment> payments,
    List<Customer> customers,
    String month,
    int year,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Aylık Ödeme Raporu',
          subtitle: '$month $year',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildMonthlySummaryCards(payments),
          pw.SizedBox(height: 20),

          // Ödeme tablosu
          _buildPaymentTable(payments, customers),
        ],
      ),
    );

    return document;
  }

  // Aylık özet kartları oluşturma
  pw.Widget _buildMonthlySummaryCards(List<Payment> payments) {
    final totalAmount =
        payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final cashAmount = payments
        .where((p) => p.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final cardAmount = payments
        .where((p) => p.method == PaymentMethod.card)
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final transferAmount = payments
        .where((p) => p.method == PaymentMethod.bank)
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Tutar',
            _pdfService.formatCurrency(totalAmount),
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Nakit Tutar',
            _pdfService.formatCurrency(cashAmount),
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Kart Tutar',
            _pdfService.formatCurrency(cardAmount),
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Havale Tutar',
            _pdfService.formatCurrency(transferAmount),
            PdfColors.purple,
          ),
        ),
      ],
    );
  }

  // Müşteri ödeme geçmişi PDF'i oluşturma
  Future<pw.Document> generateCustomerPaymentHistoryPdf(
    Customer customer,
    List<Payment> payments,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Müşteri Ödeme Geçmişi',
          subtitle: '${customer.firstName} ${customer.lastName}',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Müşteri bilgileri
          _buildCustomerInfo(customer),
          pw.SizedBox(height: 20),

          // Ödeme özeti
          _buildPaymentSummary(payments),
          pw.SizedBox(height: 20),

          // Ödeme geçmişi tablosu
          _buildPaymentHistoryTable(payments),
        ],
      ),
    );

    return document;
  }

  // Müşteri bilgileri oluşturma
  pw.Widget _buildCustomerInfo(Customer customer) {
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
            'Müşteri Bilgileri',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow(
              'Ad Soyad:', '${customer.firstName} ${customer.lastName}'),
          _buildInfoRow('Telefon:',
              customer.phone?.isNotEmpty == true ? customer.phone! : '-'),
          _buildInfoRow('Email:',
              customer.email?.isNotEmpty == true ? customer.email! : '-'),
          _buildInfoRow('Adres:',
              customer.address?.isNotEmpty == true ? customer.address! : '-'),
          _buildInfoRow('Durum:',
              customer.status == CustomerStatus.active ? 'Aktif' : 'Pasif'),
        ],
      ),
    );
  }

  // Bilgi satırı oluşturma
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
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

  // Ödeme özeti oluşturma
  pw.Widget _buildPaymentSummary(List<Payment> payments) {
    final totalAmount =
        payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final totalPayments = payments.length;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Ödeme',
            _pdfService.formatCurrency(totalAmount),
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Ödeme Sayısı',
            '$totalPayments',
            PdfColors.blue,
          ),
        ),
      ],
    );
  }

  // Ödeme geçmişi tablosu oluşturma
  pw.Widget _buildPaymentHistoryTable(List<Payment> payments) {
    return pw.Column(
      children: [
        // Tablo başlığı
        _pdfService.buildTableHeader([
          'Sıra',
          'Tutar',
          'Ödeme Yöntemi',
          'Ödeme Tarihi',
          'Notlar',
        ]),

        // Tablo satırları
        ...payments.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final payment = entry.value;

          return _pdfService.buildTableRow([
            '$index',
            _pdfService.formatCurrency(payment.amount),
            _getPaymentMethodText(payment.method),
            _pdfService.formatDate(payment.paymentDate),
            payment.notes?.isNotEmpty == true ? payment.notes! : '-',
          ], isAlternate: index % 2 == 0);
        }),
      ],
    );
  }
}
