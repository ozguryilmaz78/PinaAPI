import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_search_bar.dart';
import 'customer_form_page.dart';
import 'debug_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteriler'),
        actions: [
          Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'all':
                      provider.filterByStatus(null);
                      break;
                    case 'active':
                      provider.filterByStatus(CustomerStatus.active);
                      break;
                    case 'inactive':
                      provider.filterByStatus(CustomerStatus.inactive);
                      break;
                    case 'debug':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DebugPage(),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('Tümü'),
                  ),
                  const PopupMenuItem(
                    value: 'active',
                    child: Text('Aktif'),
                  ),
                  const PopupMenuItem(
                    value: 'inactive',
                    child: Text('Pasif'),
                  ),
                ],
                icon: const Icon(Icons.filter_list),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CustomerSearchBar(),
          ),
          Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              print('🖥️ CustomerListPage: Building UI - isLoading: ${provider.isLoading}, customers: ${provider.customers.length}');
              
              if (provider.isLoading) {
                print('⏳ CustomerListPage: Showing loading indicator');
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (provider.customers.isEmpty) {
                print('📭 CustomerListPage: No customers found, showing empty state');
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isNotEmpty ||
                                  provider.statusFilter != null
                              ? 'Arama kriterlerinize uygun müşteri bulunamadı'
                              : 'Henüz müşteri kaydı bulunmuyor',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        if (provider.searchQuery.isNotEmpty ||
                            provider.statusFilter != null)
                          TextButton(
                            onPressed: () => provider.clearFilters(),
                            child: const Text('Filtreleri Temizle'),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadCustomers(),
                  child: ListView.builder(
                    itemCount: provider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = provider.customers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomerCard(
                          customer: customer,
                          onTap: () => _navigateToCustomerForm(customer),
                          onEdit: () => _navigateToCustomerForm(customer),
                          onDelete: () => _showDeleteDialog(customer),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
  floatingActionButton: SizedBox(
  width: 45,
  height: 45,
  child: FloatingActionButton(
    onPressed: () => _navigateToCustomerForm(null),
    backgroundColor: Colors.blue,
    child: const Icon(Icons.add, size: 20, color: Colors.white),
  ),
),
    );
  }

  void _navigateToCustomerForm(Customer? customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(customer: customer),
      ),
    );
  }

  void _showDeleteDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: Text(
            '${customer.fullName} müşterisini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomerProvider>().deleteCustomer(customer.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${customer.fullName} silindi'),
                  action: SnackBarAction(
                    label: 'Geri Al',
                    onPressed: () {
                      // TODO: Implement undo functionality
                    },
                  ),
                ),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
