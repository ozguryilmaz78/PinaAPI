import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/services/pdf_service.dart';
import '../../domain/entities/customer.dart';

class CustomerPdfService {
  final PdfService _pdfService = PdfService();

  // Müşteri listesi PDF'i oluşturma
  Future<pw.Document> generateCustomerListPdf(List<Customer> customers) async {
    final document = pw.Document();

    // Sayfa formatı
    final pageFormat = _pdfService.getPageFormat();

    // PDF sayfası oluşturma
    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Müşteri Listesi',
          subtitle: 'Toplam ${customers.length} müşteri',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildSummaryCards(customers),
          pw.SizedBox(height: 20),

          // Müşteri tablosu
          _buildCustomerTable(customers),
        ],
      ),
    );

    return document;
  }

  // Özet kartları oluşturma
  pw.Widget _buildSummaryCards(List<Customer> customers) {
    final activeCustomers =
        customers.where((c) => c.status == CustomerStatus.active).length;
    final passiveCustomers =
        customers.where((c) => c.status == CustomerStatus.inactive).length;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Aktif Müşteri',
            '$activeCustomers',
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Pasif Müşteri',
            '$passiveCustomers',
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Müşteri',
            '${customers.length}',
            PdfColors.blue,
          ),
        ),
      ],
    );
  }

  // Müşteri tablosu oluşturma
  pw.Widget _buildCustomerTable(List<Customer> customers) {
    return pw.Column(
      children: [
        // Tablo başlığı
        _pdfService.buildTableHeader([
          'Sıra',
          'Ad Soyad',
          'Telefon',
          'Email',
          'Adres',
          'Durum',
          'Kayıt Tarihi',
        ]),

        // Tablo satırları
        ...customers.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final customer = entry.value;

          return _pdfService.buildTableRow([
            '$index',
            '${customer.firstName} ${customer.lastName}',
            customer.phone?.isNotEmpty == true ? customer.phone! : '-',
            customer.email?.isNotEmpty == true ? customer.email! : '-',
            customer.address?.isNotEmpty == true ? customer.address! : '-',
            customer.status == CustomerStatus.active ? 'Aktif' : 'Pasif',
            _pdfService.formatDate(customer.createdAt),
          ], isAlternate: index % 2 == 0);
        }),
      ],
    );
  }

  // Müşteri detay PDF'i oluşturma
  Future<pw.Document> generateCustomerDetailPdf(Customer customer) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Müşteri Detay Raporu',
          subtitle: '${customer.firstName} ${customer.lastName}',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Müşteri bilgileri
          _buildCustomerInfo(customer),
          pw.SizedBox(height: 20),

          // Durum özeti
          _buildStatusSummary(customer),
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
          _buildInfoRow('Ad:', customer.firstName),
          _buildInfoRow('Soyad:', customer.lastName),
          _buildInfoRow('Telefon:',
              customer.phone?.isNotEmpty == true ? customer.phone! : '-'),
          _buildInfoRow('Email:',
              customer.email?.isNotEmpty == true ? customer.email! : '-'),
          _buildInfoRow('Adres:',
              customer.address?.isNotEmpty == true ? customer.address! : '-'),
          _buildInfoRow('Durum:',
              customer.status == CustomerStatus.active ? 'Aktif' : 'Pasif'),
          _buildInfoRow(
              'Kayıt Tarihi:', _pdfService.formatDate(customer.createdAt)),
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

  // Durum özeti oluşturma
  pw.Widget _buildStatusSummary(Customer customer) {
    final statusColor = customer.status == CustomerStatus.active
        ? PdfColors.green
        : PdfColors.orange;

    final statusText =
        customer.status == CustomerStatus.active ? 'Aktif' : 'Pasif';

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: statusColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: statusColor),
      ),
      child: pw.Row(
        children: [
          pw.Icon(
            const pw.IconData(0xe5ca), // check_circle icon
            size: 24,
            color: statusColor,
          ),
          pw.SizedBox(width: 12),
          pw.Text(
            'Müşteri Durumu: $statusText',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
