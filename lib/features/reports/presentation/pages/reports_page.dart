import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../due/presentation/providers/due_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
import 'monthly_payment_report_page.dart';
import 'customer_debt_report_page.dart';
import 'chart_reports_page.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../customer/presentation/services/customer_pdf_service.dart';
import '../../../due/presentation/services/due_pdf_service.dart';
import '../../../payment/presentation/services/payment_pdf_service.dart';
import '../../presentation/services/debt_credit_pdf_service.dart'
    as debt_credit;
import '../../../due/domain/entities/due.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DueProvider>().loadDues();
      context.read<PaymentProvider>().loadPayments();
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DueProvider>().loadDues();
              context.read<PaymentProvider>().loadPayments();
              context.read<CustomerProvider>().loadCustomers();
            },
          ),
        ],
      ),
      body: Consumer3<DueProvider, PaymentProvider, CustomerProvider>(
        builder:
            (context, dueProvider, paymentProvider, customerProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(dueProvider, paymentProvider, customerProvider),

                const SizedBox(height: 32),

                // Rapor Kategorileri
                _buildSectionTitle('Rapor Kategorileri'),
                const SizedBox(height: 16),
                _buildReportCategories(),

                const SizedBox(height: 32),

                // Hızlı Erişim
                _buildSectionTitle('Hızlı Erişim'),
                const SizedBox(height: 16),
                _buildQuickAccess(dueProvider, paymentProvider),
              ],
            ),
          );
        },
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

  Widget _buildStatsGrid(DueProvider dueProvider,
      PaymentProvider paymentProvider, CustomerProvider customerProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          const SizedBox(width: 0),
          Expanded(
            child: _buildSummaryCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Toplam Tahakkuk Sayısı',
              value: '${dueProvider.allDues.length}',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 0),
          Expanded(
            child: _buildSummaryCard(
              context,
              icon: Icons.payment,
              title: 'Toplam Ödeme Sayısı',
              value: '${paymentProvider.allPayments.length}',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 50,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 56, 56, 56),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategories() {
    return Column(
      children: [
        _buildReportCard(
          context,
          icon: Icons.calendar_month,
          title: 'Aylık Ödeme Raporu',
          subtitle: 'Aylık ödeme trendleri ve analizi',
          color: Colors.blue,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MonthlyPaymentReportPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          context,
          icon: Icons.account_balance,
          title: 'Müşteri Borç/Alacak Raporu',
          subtitle: 'Müşteri bazında borç ve alacak durumları',
          color: Colors.orange,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CustomerDebtReportPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          context,
          icon: Icons.bar_chart,
          title: 'Grafik Raporları',
          subtitle: 'Bar chart ve Pie chart görselleştirmeleri',
          color: Colors.green,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChartReportsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess(
      DueProvider dueProvider, PaymentProvider paymentProvider) {
    return Center(
      child: _buildQuickAccessCard(
        context,
        icon: Icons.file_download,
        title: 'PDF Export',
        subtitle: 'PDF\'leri paylaş',
        color: Colors.red,
        onTap: () {
          _showExportDialog(context, 'PDF');
        },
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String format) {
    _showPdfExportDialog(context);
  }

  void _showPdfExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Paylaşım'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPdfOption(
              context,
              icon: Icons.people,
              title: 'Müşteri Listesi',
              onTap: () => _generateCustomerListPdf(context),
            ),
            const SizedBox(height: 8),
            _buildPdfOption(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Aidat Listesi',
              onTap: () => _generateDueListPdf(context),
            ),
            const SizedBox(height: 8),
            _buildPdfOption(
              context,
              icon: Icons.payment,
              title: 'Ödeme Listesi',
              onTap: () => _generatePaymentListPdf(context),
            ),
            const SizedBox(height: 8),
            _buildPdfOption(
              context,
              icon: Icons.account_balance,
              title: 'Borç/Alacak Raporu',
              onTap: () => _generateDebtCreditReportPdf(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCustomerListPdf(BuildContext context) async {
    try {
      final customerProvider = context.read<CustomerProvider>();
      final customers = customerProvider.allCustomers;

      if (customers.isEmpty) {
        _showErrorDialog(context, 'Müşteri bulunamadı');
        return;
      }

      _showLoadingDialog(context, 'PDF oluşturuluyor...');

      final customerPdfService = CustomerPdfService();
      final document =
          await customerPdfService.generateCustomerListPdf(customers);

      Navigator.pop(context); // Loading dialog'u kapat
      Navigator.pop(context); // PDF dialog'u kapat

      final pdfService = PdfService();
      final filePath =
          await pdfService.createAndSavePdfFile(document, 'Müşteri_Listesi');
      print('PDF kaydedildi: $filePath');
    } catch (e) {
      Navigator.pop(context); // Loading dialog'u kapat
      _showErrorDialog(context, 'PDF oluşturulurken hata oluştu: $e');
    }
  }

  Future<void> _generateDueListPdf(BuildContext context) async {
    try {
      final dueProvider = context.read<DueProvider>();
      final customerProvider = context.read<CustomerProvider>();
      final dues = dueProvider.allDues;
      final customers = customerProvider.allCustomers;

      if (dues.isEmpty) {
        _showErrorDialog(context, 'Aidat bulunamadı');
        return;
      }

      _showLoadingDialog(context, 'PDF oluşturuluyor...');

      final duePdfService = DuePdfService();
      final document = await duePdfService.generateDueListPdf(dues, customers);

      Navigator.pop(context); // Loading dialog'u kapat
      Navigator.pop(context); // PDF dialog'u kapat

      final pdfService = PdfService();
      final filePath =
          await pdfService.createAndSavePdfFile(document, 'Aidat_Listesi');
      print('PDF kaydedildi: $filePath');
    } catch (e) {
      Navigator.pop(context); // Loading dialog'u kapat
      _showErrorDialog(context, 'PDF oluşturulurken hata oluştu: $e');
    }
  }

  Future<void> _generatePaymentListPdf(BuildContext context) async {
    try {
      final paymentProvider = context.read<PaymentProvider>();
      final customerProvider = context.read<CustomerProvider>();
      final payments = paymentProvider.allPayments;
      final customers = customerProvider.allCustomers;

      if (payments.isEmpty) {
        _showErrorDialog(context, 'Ödeme bulunamadı');
        return;
      }

      _showLoadingDialog(context, 'PDF oluşturuluyor...');

      final paymentPdfService = PaymentPdfService();
      final document =
          await paymentPdfService.generatePaymentListPdf(payments, customers);

      Navigator.pop(context); // Loading dialog'u kapat
      Navigator.pop(context); // PDF dialog'u kapat

      final pdfService = PdfService();
      final filePath =
          await pdfService.createAndSavePdfFile(document, 'Ödeme_Listesi');
      print('PDF kaydedildi: $filePath');
    } catch (e) {
      Navigator.pop(context); // Loading dialog'u kapat
      _showErrorDialog(context, 'PDF oluşturulurken hata oluştu: $e');
    }
  }

  Future<void> _generateDebtCreditReportPdf(BuildContext context) async {
    try {
      final customerProvider = context.read<CustomerProvider>();
      final dueProvider = context.read<DueProvider>();
      final paymentProvider = context.read<PaymentProvider>();

      final customers = customerProvider.allCustomers;
      final dues = dueProvider.allDues;
      final payments = paymentProvider.allPayments;

      if (customers.isEmpty) {
        _showErrorDialog(context, 'Müşteri bulunamadı');
        return;
      }

      _showLoadingDialog(context, 'PDF oluşturuluyor...');

      // Müşteri borç/alacak bilgilerini hesapla
      final customerDebts = customers.map((customer) {
        final customerDues =
            dues.where((due) => due.customerId == customer.id).toList();
        final customerPayments = payments
            .where((payment) => payment.customerId == customer.id)
            .toList();

        final totalDues =
            customerDues.fold<double>(0.0, (sum, due) => sum + due.amount);
        final totalPayments = customerPayments.fold<double>(
            0.0, (sum, payment) => sum + payment.amount);
        final balance = totalPayments - totalDues;

        final pendingDues = customerDues
            .where((due) => due.status == DueStatus.pending)
            .toList();

        return debt_credit.CustomerDebtInfo(
          customer: customer,
          totalDues: totalDues,
          totalPayments: totalPayments,
          balance: balance,
          pendingDues: pendingDues,
          allDues: customerDues,
          allPayments: customerPayments,
        );
      }).toList();

      final debtCreditPdfService = debt_credit.DebtCreditPdfService();
      final document = await debtCreditPdfService
          .generateCustomerDebtCreditReportPdf(customerDebts);

      Navigator.pop(context); // Loading dialog'u kapat
      Navigator.pop(context); // PDF dialog'u kapat

      final pdfService = PdfService();
      final filePath =
          await pdfService.createAndSavePdfFile(document, 'Borç_Alacak_Raporu');
      print('PDF kaydedildi: $filePath');
    } catch (e) {
      Navigator.pop(context); // Loading dialog'u kapat
      _showErrorDialog(context, 'PDF oluşturulurken hata oluştu: $e');
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
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
}
