import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/due.dart';
import '../providers/due_provider.dart';
import 'due_form_page.dart';

class DueListPage extends StatefulWidget {
  const DueListPage({super.key});

  @override
  State<DueListPage> createState() => _DueListPageState();
}

class _DueListPageState extends State<DueListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DueProvider>().loadDues();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahakkuk'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DueProvider>().loadDues();
            },
          ),
        ],
      ),
      body: Consumer<DueProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Arama Çubuğu
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Müşteri adı, dönem veya tutar ile ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    provider.searchDues(value);
                  },
                ),
              ),

              // Özet Kartları
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: [
                    const SizedBox(width: 0),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.account_balance_wallet,
                        title: 'Toplam Tahakkuk',
                        value: '${provider.filteredDues.length}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 0),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.money,
                        title: 'Toplam Tutar',
                        value:
                            '${provider.filteredDues.fold<double>(0.0, (sum, due) => sum + due.amount).toStringAsFixed(0)} ₺',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Aidat Listesi
              Expanded(
                child: provider.filteredDues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz aidat kaydı yok',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni aidat eklemek için + butonuna tıklayın',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.filteredDues.length,
                        itemBuilder: (context, index) {
                          return _buildDueCard(
                              context, provider.filteredDues[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 45,
        height: 45,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DueFormPage(),
              ),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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

  Widget _buildDueCard(BuildContext context, Due due) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Müşteri Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(due.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  due.customerName.isNotEmpty
                      ? due.customerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(due.status),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Aidat Detayları
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    due.customerName,
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
                        due.periodDisplayText,
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
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Vade: ${due.dueDate.day.toString().padLeft(2, '0')}.${due.dueDate.month.toString().padLeft(2, '0')}.${due.dueDate.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  // Not bilgisi varsa göster
                  if (due.notes != null && due.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            due.notes!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Tutar Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(due.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(due.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${due.amount.toStringAsFixed(0)} ₺',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(due.status),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Menü Butonu
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DueFormPage(due: due),
                      ),
                    );
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, due);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DueStatus status) {
    switch (status) {
      case DueStatus.pending:
        return Colors.orange;
      case DueStatus.paid:
        return Colors.green;
      case DueStatus.overdue:
        return Colors.red;
      case DueStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DueStatus status) {
    switch (status) {
      case DueStatus.pending:
        return Icons.pending;
      case DueStatus.paid:
        return Icons.check;
      case DueStatus.overdue:
        return Icons.warning;
      case DueStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              onTap: () {
                Navigator.pop(context);
                context.read<DueProvider>().searchDues('');
              },
            ),
            ListTile(
              title: const Text('Bekleyen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Bekleyen aidatları filtrele
              },
            ),
            ListTile(
              title: const Text('Ödenen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Ödenen aidatları filtrele
              },
            ),
            ListTile(
              title: const Text('Vadesi Geçmiş'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Vadesi geçmiş aidatları filtrele
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Due due) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aidat Sil'),
        content: Text(
            '${due.customerName} müşterisinin ${due.periodDisplayText} dönemindeki ${due.amount.toStringAsFixed(0)} ₺ tutarındaki aidatını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DueProvider>().deleteDue(due.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
