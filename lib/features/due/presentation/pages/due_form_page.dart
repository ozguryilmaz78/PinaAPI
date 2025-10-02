import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/due.dart';
import '../providers/due_provider.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
import '../../../customer/domain/entities/customer.dart';

class DueFormPage extends StatefulWidget {
  final Due? due;

  const DueFormPage({super.key, this.due});

  @override
  State<DueFormPage> createState() => _DueFormPageState();
}

class _DueFormPageState extends State<DueFormPage> {
  final _formKey = GlobalKey<FormState>();
  Set<String> _selectedCustomerIds = {};
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Müşterileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerProvider>();
      if (customerProvider.allCustomers.isEmpty) {
        customerProvider.loadCustomers();
      }
    });

    if (widget.due != null) {
      _loadDueData();
    } else {
      // Yeni aidat için varsayılan değerler
      final now = DateTime.now();
      _periodController.text =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
  }

  void _loadDueData() {
    final due = widget.due!;
    _amountController.text = due.amount.toString();
    _notesController.text = due.notes ?? '';
    _selectedCustomerIds = {due.customerId};
    _selectedDate = due.dueDate;
    _periodController.text = due.period;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _periodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.due == null ? 'Yeni Tahakkuk' : 'Tahakkuk Düzenle'),
        centerTitle: true,
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Müşteri Bilgisi
                  if (widget.due != null)
                    // Düzenleme modu - Büyük müşteri adı
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              // Seçili müşterinin adını bul
                              final selectedCustomer = customerProvider
                                  .allCustomers
                                  .where((customer) => _selectedCustomerIds
                                      .contains(customer.id))
                                  .firstOrNull;

                              return Text(
                                selectedCustomer != null
                                    ? '${selectedCustomer.firstName} ${selectedCustomer.lastName}'
                                    : 'Müşteri Bulunamadı',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bu tahakkuk için seçili müşteri',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.blue.shade600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    // Yeni tahakkuk modu - Müşteri seçimi
                    SizedBox(
                      height: 66,
                      child: CheckboxListTile(
                        dense: true,
                        title: Text(
                          'Müşteri Seçimi (${_selectedCustomerIds.length})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Text(
                          '${customerProvider.allCustomers.where((customer) => customer.status.isActive).length} aktif müşteri',
                        ),
                        value: _selectedCustomerIds.length ==
                            customerProvider.allCustomers
                                .where((customer) => customer.status.isActive)
                                .length,
                        onChanged: (value) {
                          setState(() {
                            final activeCustomers = customerProvider
                                .allCustomers
                                .where((customer) => customer.status.isActive)
                                .toList()
                              ..sort((a, b) => '${a.firstName} ${a.lastName}'
                                  .toLowerCase()
                                  .compareTo('${b.firstName} ${b.lastName}'
                                      .toLowerCase()));

                            if (value == true) {
                              _selectedCustomerIds =
                                  activeCustomers.map((c) => c.id).toSet();
                            } else {
                              _selectedCustomerIds.clear();
                            }
                          });
                        },
                        secondary: Icon(
                          Icons.people,
                          color: _selectedCustomerIds.length ==
                                  customerProvider.allCustomers
                                      .where((customer) =>
                                          customer.status.isActive)
                                      .length
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ),
                    ),

                  // Müşteri Listesi - Sadece yeni tahakkuk modunda
                  if (widget.due == null) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final activeCustomers = customerProvider.allCustomers
                            .where((customer) => customer.status.isActive)
                            .toList()
                          ..sort((a, b) => '${a.firstName} ${a.lastName}'
                              .toLowerCase()
                              .compareTo('${b.firstName} ${b.lastName}'
                                  .toLowerCase()));

                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: activeCustomers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Aktif müşteri bulunamadı',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: activeCustomers.length,
                                  itemBuilder: (context, index) {
                                    final customer = activeCustomers[index];
                                    final isSelected = _selectedCustomerIds
                                        .contains(customer.id);

                                    return SizedBox(
                                      height: 48,
                                      child: CheckboxListTile(
                                        dense: true,
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedCustomerIds
                                                  .add(customer.id);
                                            } else {
                                              _selectedCustomerIds
                                                  .remove(customer.id);
                                            }
                                          });
                                        },
                                        title: Text(
                                          '${customer.firstName} ${customer.lastName}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        secondary: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              customer.firstName.isNotEmpty
                                                  ? customer.firstName[0]
                                                      .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Tutar
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Tutar (₺)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen tutarı girin';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dönem
                  TextFormField(
                    controller: _periodController,
                    decoration: const InputDecoration(
                      labelText: 'Dönem (YYYY-MM)',
                      border: OutlineInputBorder(),
                      hintText: '2024-01',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen dönem girin';
                      }
                      if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(value)) {
                        return 'Dönem formatı: YYYY-MM (örn: 2024-01)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vade Tarihi
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Vade Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notlar
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notlar (Opsiyonel)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Kaydet Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveDue,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.due == null ? 'Kaydet' : 'Güncelle'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Allow dates from 2020 onwards
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveDue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_selectedCustomerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir müşteri seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dueProvider = context.read<DueProvider>();
    final customerProvider = context.read<CustomerProvider>();

    try {
      final amount = double.parse(_amountController.text);
      final period = _periodController.text;
      final notes =
          _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.due != null) {
        // Düzenleme - tek müşteri
        final updatedDue = widget.due!.copyWith(
          customerId: _selectedCustomerIds.first,
          customerName: customerProvider.allCustomers
              .firstWhere((c) => c.id == _selectedCustomerIds.first)
              .fullName,
          amount: amount,
          dueDate: _selectedDate,
          period: period,
          notes: notes,
        );
        await dueProvider.updateDue(updatedDue);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tahakkuk güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Yeni tahakkuk - çoklu müşteri
        int successCount = 0;
        for (final customerId in _selectedCustomerIds) {
          final customer = customerProvider.allCustomers
              .firstWhere((c) => c.id == customerId);

          final due = Due(
            id: const Uuid().v4(),
            customerId: customerId,
            customerName: customer.fullName,
            amount: amount,
            dueDate: _selectedDate,
            createdAt: DateTime.now(),
            status: DueStatus.pending,
            period: period,
            notes: notes,
          );

          await dueProvider.createDue(due);
          successCount++;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$successCount müşteri için tahakkuk oluşturuldu'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
