import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../due/presentation/providers/due_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../../due/domain/entities/due.dart';
import '../../../customer/domain/entities/customer.dart';

class ChartReportsPage extends StatefulWidget {
  const ChartReportsPage({super.key});

  @override
  State<ChartReportsPage> createState() => _ChartReportsPageState();
}

class _ChartReportsPageState extends State<ChartReportsPage> {
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
        title: const Text('Grafik Raporları'),
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
          if (dueProvider.isLoading ||
              paymentProvider.isLoading ||
              customerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aylık Ödeme Trendi
                _buildSectionTitle('Aylık Ödeme Trendi'),
                const SizedBox(height: 16),
                _buildMonthlyPaymentChart(paymentProvider),

                const SizedBox(height: 32),

                // Aidat Durumu Dağılımı
                _buildSectionTitle('Aidat Durumu Dağılımı'),
                const SizedBox(height: 16),
                _buildDueStatusChart(dueProvider),

                const SizedBox(height: 32),

                // Ödeme Yöntemi Dağılımı
                _buildSectionTitle('Ödeme Yöntemi Dağılımı'),
                const SizedBox(height: 16),
                _buildPaymentMethodChart(paymentProvider),

                const SizedBox(height: 32),

                // Müşteri Durumu
                _buildSectionTitle('Müşteri Durumu'),
                const SizedBox(height: 16),
                _buildCustomerStatusChart(customerProvider),
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

  Widget _buildMonthlyPaymentChart(PaymentProvider paymentProvider) {
    final payments = paymentProvider.allPayments;
    if (payments.isEmpty) {
      return _buildEmptyChart('Henüz ödeme kaydı yok');
    }

    // Son 6 ayın verilerini hazırla
    final now = DateTime.now();
    final monthlyData = <String, double>{};

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final period = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyData[period] = 0.0;
    }

    // Ödemeleri aylara göre grupla
    for (final payment in payments) {
      final period =
          '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}';
      if (monthlyData.containsKey(period)) {
        monthlyData[period] = monthlyData[period]! + payment.amount;
      }
    }

    final chartData = monthlyData.entries.map((entry) {
      final month = entry.key.split('-')[1];
      final monthNames = [
        '',
        'Oca',
        'Şub',
        'Mar',
        'Nis',
        'May',
        'Haz',
        'Tem',
        'Ağu',
        'Eyl',
        'Eki',
        'Kas',
        'Ara'
      ];
      return BarChartGroupData(
        x: int.parse(month),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: monthlyData.values.isEmpty
              ? 100
              : monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const monthNames = [
                    '',
                    'Oca',
                    'Şub',
                    'Mar',
                    'Nis',
                    'May',
                    'Haz',
                    'Tem',
                    'Ağu',
                    'Eyl',
                    'Eki',
                    'Kas',
                    'Ara'
                  ];
                  return Text(
                    monthNames[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}₺',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: chartData,
        ),
      ),
    );
  }

  Widget _buildDueStatusChart(DueProvider dueProvider) {
    final dues = dueProvider.allDues;
    if (dues.isEmpty) {
      return _buildEmptyChart('Henüz aidat kaydı yok');
    }

    final pendingCount =
        dues.where((due) => due.status == DueStatus.pending).length;
    final paidCount = dues.where((due) => due.status == DueStatus.paid).length;
    final overdueCount = dues.where((due) => due.isOverdue).length;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: pendingCount.toDouble(),
              title: 'Bekleyen\n$pendingCount',
              color: Colors.orange,
              radius: 80,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: paidCount.toDouble(),
              title: 'Ödenen\n$paidCount',
              color: Colors.green,
              radius: 80,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: overdueCount.toDouble(),
              title: 'Vadesi Geçmiş\n$overdueCount',
              color: Colors.red,
              radius: 80,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChart(PaymentProvider paymentProvider) {
    final payments = paymentProvider.allPayments;
    if (payments.isEmpty) {
      return _buildEmptyChart('Henüz ödeme kaydı yok');
    }

    final methodCounts = <String, int>{};
    for (final payment in payments) {
      final method = _getPaymentMethodText(payment.method);
      methodCounts[method] = (methodCounts[method] ?? 0) + 1;
    }

    final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange];
    int colorIndex = 0;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: methodCounts.entries.map((entry) {
            final color = colors[colorIndex % colors.length];
            colorIndex++;
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: '${entry.key}\n${entry.value}',
              color: color,
              radius: 80,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCustomerStatusChart(CustomerProvider customerProvider) {
    final customers = customerProvider.allCustomers;
    if (customers.isEmpty) {
      return _buildEmptyChart('Henüz müşteri kaydı yok');
    }

    final activeCount = customers
        .where((customer) => customer.status == CustomerStatus.active)
        .length;
    final inactiveCount = customers
        .where((customer) => customer.status == CustomerStatus.inactive)
        .length;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: activeCount.toDouble(),
              title: 'Aktif\n$activeCount',
              color: Colors.green,
              radius: 80,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: inactiveCount.toDouble(),
              title: 'Pasif\n$inactiveCount',
              color: Colors.grey,
              radius: 80,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
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
