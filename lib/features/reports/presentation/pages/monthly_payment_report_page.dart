import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../due/presentation/providers/due_provider.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../../due/domain/entities/due.dart';

class MonthlyPaymentReportPage extends StatefulWidget {
  const MonthlyPaymentReportPage({super.key});

  @override
  State<MonthlyPaymentReportPage> createState() =>
      _MonthlyPaymentReportPageState();
}

class _MonthlyPaymentReportPageState extends State<MonthlyPaymentReportPage> {
  String _selectedPeriod = '';
  List<Payment> _filteredPayments = [];
  List<Due> _filteredDues = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<PaymentProvider>().loadPayments();
    context.read<DueProvider>().loadDues();
  }

  void _filterByPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      final paymentProvider = context.read<PaymentProvider>();
      final dueProvider = context.read<DueProvider>();

      if (period.isEmpty) {
        _filteredPayments = paymentProvider.allPayments;
        _filteredDues = dueProvider.allDues;
      } else {
        _filteredPayments = paymentProvider.allPayments.where((payment) {
          final paymentPeriod =
              '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}';
          return paymentPeriod == period;
        }).toList();

        _filteredDues = dueProvider.allDues.where((due) {
          return due.period == period;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aylık Ödeme Raporu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer2<PaymentProvider, DueProvider>(
        builder: (context, paymentProvider, dueProvider, child) {
          if (paymentProvider.isLoading || dueProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Dönem Seçimi
              _buildPeriodSelector(dueProvider),

              // Özet Kartları
              _buildSummaryCards(),

              // Ödeme Listesi
              Expanded(
                child: _buildPaymentList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(DueProvider dueProvider) {
    final periods = dueProvider.duesByPeriod.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dönem Seçimi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPeriod.isEmpty ? null : _selectedPeriod,
            decoration: const InputDecoration(
              labelText: 'Dönem Seçin',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_month),
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Tüm Dönemler'),
              ),
              ...periods.map((period) {
                final parts = period.split('-');
                final year = parts[0];
                final month = parts[1];
                final monthNames = [
                  '',
                  'Ocak',
                  'Şubat',
                  'Mart',
                  'Nisan',
                  'Mayıs',
                  'Haziran',
                  'Temmuz',
                  'Ağustos',
                  'Eylül',
                  'Ekim',
                  'Kasım',
                  'Aralık'
                ];
                final monthName = monthNames[int.parse(month)];
                return DropdownMenuItem(
                  value: period,
                  child: Text('$monthName $year'),
                );
              }),
            ],
            onChanged: (value) {
              _filterByPeriod(value ?? '');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalPayments = _filteredPayments.length;
    final totalAmount = _filteredPayments.fold<double>(
        0.0, (sum, payment) => sum + payment.amount);
    final totalDues = _filteredDues.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              icon: Icons.payment,
              title: 'Toplam Ödeme',
              value: '$totalPayments',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              context,
              icon: Icons.money,
              title: 'Toplam Tutar',
              value: '${totalAmount.toStringAsFixed(0)} ₺',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Toplam Tahakkuk',
              value: '$totalDues',
              color: Colors.orange,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_filteredPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedPeriod.isEmpty
                  ? 'Henüz ödeme kaydı yok'
                  : 'Bu dönemde ödeme kaydı yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = _filteredPayments[index];
        return _buildPaymentCard(context, payment);
      },
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Müşteri Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  payment.customerName.isNotEmpty
                      ? payment.customerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Ödeme Detayları
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.customerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd.MM.yyyy').format(payment.paymentDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.account_balance_wallet,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${payment.amount.toStringAsFixed(0)} ₺',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getPaymentMethodIcon(payment.method),
                        size: 14,
                        color: _getPaymentMethodColor(payment.method),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPaymentMethodText(payment.method),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getPaymentMethodColor(payment.method),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Durum Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: const Text(
                'Ödendi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bank:
        return Icons.account_balance;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.bank:
        return Colors.blue;
      case PaymentMethod.card:
        return Colors.purple;
      case PaymentMethod.other:
        return Colors.grey;
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.bank:
        return 'Banka';
      case PaymentMethod.card:
        return 'Kart';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }
}
