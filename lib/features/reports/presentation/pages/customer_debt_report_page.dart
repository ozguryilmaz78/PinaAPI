import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
import '../../../due/presentation/providers/due_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../due/domain/entities/due.dart';
import '../../../payment/domain/entities/payment.dart';

class CustomerDebtReportPage extends StatefulWidget {
  const CustomerDebtReportPage({super.key});

  @override
  State<CustomerDebtReportPage> createState() => _CustomerDebtReportPageState();
}

class _CustomerDebtReportPageState extends State<CustomerDebtReportPage> {
  List<CustomerDebtInfo> _customerDebts = [];
  List<CustomerDebtInfo> _filteredCustomerDebts = [];
  String _selectedFilter = 'all'; // 'all', 'debtors', 'creditors'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<CustomerProvider>().loadCustomers();
    context.read<DueProvider>().loadDues();
    context.read<PaymentProvider>().loadPayments();
  }

  void _calculateCustomerDebts() {
    final customerProvider = context.read<CustomerProvider>();
    final dueProvider = context.read<DueProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    final customers = customerProvider.allCustomers;
    final dues = dueProvider.allDues;
    final payments = paymentProvider.allPayments;

    _customerDebts = customers.map((customer) {
      // Müşterinin aidatları
      final customerDues =
          dues.where((due) => due.customerId == customer.id).toList();

      // Müşterinin ödemeleri
      final customerPayments = payments
          .where((payment) => payment.customerId == customer.id)
          .toList();

      // Toplam aidat tutarı
      final totalDues =
          customerDues.fold<double>(0.0, (sum, due) => sum + due.amount);

      // Toplam ödeme tutarı
      final totalPayments = customerPayments.fold<double>(
          0.0, (sum, payment) => sum + payment.amount);

      // Borç/Alacak hesaplama
      final balance = totalPayments - totalDues;

      // Bekleyen aidatlar
      final pendingDues =
          customerDues.where((due) => due.status == DueStatus.pending).toList();

      return CustomerDebtInfo(
        customer: customer,
        totalDues: totalDues,
        totalPayments: totalPayments,
        balance: balance,
        pendingDues: pendingDues,
        allDues: customerDues,
        allPayments: customerPayments,
      );
    }).toList();

    // Borç/Alacak durumuna göre sırala (borçlu müşteriler önce)
    _customerDebts.sort((a, b) => a.balance.compareTo(b.balance));
  }

  void _applyFiltersAndSearch() {
    List<CustomerDebtInfo> filtered = _customerDebts;

    // Filtre uygula
    switch (_selectedFilter) {
      case 'debtors':
        filtered = filtered.where((info) => info.balance < 0).toList();
        break;
      case 'creditors':
        filtered = filtered.where((info) => info.balance > 0).toList();
        break;
      case 'all':
      default:
        // Tüm müşteriler
        break;
    }

    // Arama uygula
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((info) {
        final customerName =
            '${info.customer.firstName} ${info.customer.lastName}'
                .toLowerCase();
        return customerName.contains(searchQuery);
      }).toList();
    }

    _filteredCustomerDebts = filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Borç/Alacak Raporu'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              _selectedFilter = value;
              _applyFiltersAndSearch();
              setState(() {});
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Tümü'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'debtors',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Borçlular'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'creditors',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Alacaklılar'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer3<CustomerProvider, DueProvider, PaymentProvider>(
        builder:
            (context, customerProvider, dueProvider, paymentProvider, child) {
          if (customerProvider.isLoading ||
              dueProvider.isLoading ||
              paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          _calculateCustomerDebts();
          _applyFiltersAndSearch();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Özet Kartları
                _buildSummaryCards(),

                // Arama Çubuğu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Müşteri adı ile ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      _applyFiltersAndSearch();
                      setState(() {});
                    },
                  ),
                ),

                // Müşteri Listesi
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      300, // Sabit yükseklik
                  child: _buildCustomerList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final customersInDebt =
        _customerDebts.where((info) => info.balance < 0).length;
    final customersWithCredit =
        _customerDebts.where((info) => info.balance > 0).length;
    final totalDebt = _customerDebts.fold<double>(
        0.0, (sum, info) => sum + (info.balance < 0 ? info.balance.abs() : 0));
    final totalCredit = _customerDebts.fold<double>(
        0.0, (sum, info) => sum + (info.balance > 0 ? info.balance : 0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          // İlk satır
          Row(
            children: [
              const SizedBox(width: 0),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Alacaklı Müşteri',
                  value: '$customersWithCredit',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 0),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.warning,
                  title: 'Borçlu Müşteri',
                  value: '$customersInDebt',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          // İkinci satır
          Row(
            children: [
              const SizedBox(width: 0),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.account_balance,
                  title: 'Toplam Alacak',
                  value: '${totalCredit.toStringAsFixed(0)} ₺',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 0),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Toplam Borç',
                  value: '${totalDebt.toStringAsFixed(0)} ₺',
                  color: Colors.orange,
                ),
              ),
            ],
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

  Widget _buildCustomerList() {
    if (_filteredCustomerDebts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz müşteri kaydı yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomerDebts.length,
      itemBuilder: (context, index) {
        final debtInfo = _filteredCustomerDebts[index];
        return _buildCustomerCard(context, debtInfo);
      },
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerDebtInfo debtInfo) {
    final isInDebt = debtInfo.balance < 0;
    final balanceColor = isInDebt ? Colors.red : Colors.green;
    final balanceIcon = isInDebt ? Icons.warning : Icons.check_circle;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Müşteri Bilgileri
            Row(
              children: [
                // Müşteri Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: balanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      debtInfo.customer.firstName.isNotEmpty
                          ? debtInfo.customer.firstName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Müşteri Detayları
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${debtInfo.customer.firstName} ${debtInfo.customer.lastName}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            balanceIcon,
                            size: 16,
                            color: balanceColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isInDebt
                                ? 'Borçlu: ${debtInfo.balance.abs().toStringAsFixed(0)} ₺'
                                : 'Alacaklı: ${debtInfo.balance.toStringAsFixed(0)} ₺',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: balanceColor,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: balanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: balanceColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isInDebt ? 'Borçlu' : 'Alacaklı',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Detay Bilgileri
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    label: 'Toplam Tahakkuk',
                    value: '${debtInfo.totalDues.toStringAsFixed(0)} ₺',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.payment,
                    label: 'Toplam Ödeme',
                    value: '${debtInfo.totalPayments.toStringAsFixed(0)} ₺',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.pending_actions,
                    label: 'Bekleyen',
                    value: '${debtInfo.pendingDues.length}',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CustomerDebtInfo {
  final Customer customer;
  final double totalDues;
  final double totalPayments;
  final double balance; // Pozitif: alacaklı, Negatif: borçlu
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
