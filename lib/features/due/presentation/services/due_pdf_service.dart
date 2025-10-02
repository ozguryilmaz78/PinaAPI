import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/services/pdf_service.dart';
import '../../domain/entities/due.dart';
import '../../../customer/domain/entities/customer.dart';

class DuePdfService {
  final PdfService _pdfService = PdfService();

  // Aidat listesi PDF'i oluşturma
  Future<pw.Document> generateDueListPdf(
    List<Due> dues,
    List<Customer> customers,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Aidat Listesi',
          subtitle: 'Toplam ${dues.length} aidat',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildSummaryCards(dues),
          pw.SizedBox(height: 20),

          // Aidat tablosu
          _buildDueTable(dues, customers),
        ],
      ),
    );

    return document;
  }

  // Özet kartları oluşturma
  pw.Widget _buildSummaryCards(List<Due> dues) {
    final totalAmount = dues.fold<double>(0.0, (sum, due) => sum + due.amount);
    final pendingDues = dues.where((d) => d.status == DueStatus.pending).length;
    final completedDues = dues.where((d) => d.status == DueStatus.paid).length;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Tutar',
            _pdfService.formatCurrency(totalAmount),
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Bekleyen',
            '$pendingDues',
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Tamamlanan',
            '$completedDues',
            PdfColors.green,
          ),
        ),
      ],
    );
  }

  // Aidat tablosu oluşturma
  pw.Widget _buildDueTable(List<Due> dues, List<Customer> customers) {
    return pw.Column(
      children: [
        // Tablo başlığı
        _pdfService.buildTableHeader([
          'Sıra',
          'Müşteri',
          'Dönem',
          'Tutar',
          'Vade Tarihi',
          'Durum',
          'Oluşturma Tarihi',
        ]),

        // Tablo satırları
        ...dues.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final due = entry.value;
          final customer = customers.firstWhere(
            (c) => c.id == due.customerId,
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
            due.period,
            _pdfService.formatCurrency(due.amount),
            _pdfService.formatDate(due.dueDate),
            due.status == DueStatus.pending ? 'Bekliyor' : 'Tamamlandı',
            _pdfService.formatDate(due.createdAt),
          ], isAlternate: index % 2 == 0);
        }),
      ],
    );
  }

  // Aylık aidat raporu PDF'i oluşturma
  Future<pw.Document> generateMonthlyDueReportPdf(
    List<Due> dues,
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
          'Aylık Aidat Raporu',
          subtitle: '$month $year',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildMonthlySummaryCards(dues),
          pw.SizedBox(height: 20),

          // Aidat tablosu
          _buildDueTable(dues, customers),
        ],
      ),
    );

    return document;
  }

  // Aylık özet kartları oluşturma
  pw.Widget _buildMonthlySummaryCards(List<Due> dues) {
    final totalAmount = dues.fold<double>(0.0, (sum, due) => sum + due.amount);
    final pendingAmount = dues
        .where((d) => d.status == DueStatus.pending)
        .fold<double>(0.0, (sum, due) => sum + due.amount);
    final completedAmount = dues
        .where((d) => d.status == DueStatus.paid)
        .fold<double>(0.0, (sum, due) => sum + due.amount);

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Tutar',
            _pdfService.formatCurrency(totalAmount),
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Bekleyen Tutar',
            _pdfService.formatCurrency(pendingAmount),
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Ödenen Tutar',
            _pdfService.formatCurrency(completedAmount),
            PdfColors.green,
          ),
        ),
      ],
    );
  }

  // Vadesi geçen aidatlar PDF'i oluşturma
  Future<pw.Document> generateOverdueDuesPdf(
    List<Due> overdueDues,
    List<Customer> customers,
  ) async {
    final document = pw.Document();

    final pageFormat = _pdfService.getPageFormat();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => _pdfService.buildHeader(
          'Vadesi Geçen Tahakkuklar',
          subtitle: 'Toplam ${overdueDues.length} aidat',
        ),
        footer: (context) => _pdfService.buildFooter(),
        build: (context) => [
          // Özet kartları
          _buildOverdueSummaryCards(overdueDues),
          pw.SizedBox(height: 20),

          // Vadesi geçen aidat tablosu
          _buildOverdueTable(overdueDues, customers),
        ],
      ),
    );

    return document;
  }

  // Vadesi geçen özet kartları oluşturma
  pw.Widget _buildOverdueSummaryCards(List<Due> overdueDues) {
    final totalAmount =
        overdueDues.fold<double>(0.0, (sum, due) => sum + due.amount);
    final averageDaysOverdue = overdueDues.isNotEmpty
        ? overdueDues.fold<int>(
                0,
                (sum, due) =>
                    sum + DateTime.now().difference(due.dueDate).inDays) /
            overdueDues.length
        : 0.0;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Tutar',
            _pdfService.formatCurrency(totalAmount),
            PdfColors.red,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Ortalama Gecikme',
            '${averageDaysOverdue.toStringAsFixed(0)} gün',
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfService.buildSummaryCard(
            'Toplam Tahakkuk',
            '${overdueDues.length}',
            PdfColors.blue,
          ),
        ),
      ],
    );
  }

  // Vadesi geçen aidat tablosu oluşturma
  pw.Widget _buildOverdueTable(
      List<Due> overdueDues, List<Customer> customers) {
    return pw.Column(
      children: [
        // Tablo başlığı
        _pdfService.buildTableHeader([
          'Sıra',
          'Müşteri',
          'Dönem',
          'Tutar',
          'Vade Tarihi',
          'Gecikme (Gün)',
          'Oluşturma Tarihi',
        ]),

        // Tablo satırları
        ...overdueDues.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final due = entry.value;
          final customer = customers.firstWhere(
            (c) => c.id == due.customerId,
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

          final daysOverdue = DateTime.now().difference(due.dueDate).inDays;

          return _pdfService.buildTableRow([
            '$index',
            '${customer.firstName} ${customer.lastName}',
            due.period,
            _pdfService.formatCurrency(due.amount),
            _pdfService.formatDate(due.dueDate),
            '$daysOverdue',
            _pdfService.formatDate(due.createdAt),
          ], isAlternate: index % 2 == 0);
        }),
      ],
    );
  }
}
