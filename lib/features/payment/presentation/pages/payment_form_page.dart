import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/payment.dart';
import '../providers/payment_provider.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
import '../../../customer/domain/entities/customer.dart';

class PaymentFormPage extends StatefulWidget {
  final Payment? payment; // null ise yeni ödeme, dolu ise düzenleme

  const PaymentFormPage({super.key, this.payment});

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Set<String> _selectedCustomerIds = {}; // Multiselect için Set kullanıyoruz
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _loadPaymentData();
    }
    // Müşteri verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerProvider>();
      if (customerProvider.allCustomers.isEmpty) {
        customerProvider.loadCustomers();
      }
    });
  }

  void _loadPaymentData() {
    final payment = widget.payment!;
    _amountController.text = payment.amount.toString();
    _notesController.text = payment.notes ?? '';
    _selectedCustomerIds = {payment.customerId}; // Tek müşteri için Set'e ekle
    _selectedMethod = payment.method;
    _selectedDate = payment.paymentDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment == null ? 'Yeni Ödeme' : 'Ödeme Düzenle'),
        centerTitle: true,
      ),
      body: Consumer2<PaymentProvider, CustomerProvider>(
        builder: (context, paymentProvider, customerProvider, child) {
          // Debug: Müşteri verilerini kontrol et
          print(
              'Toplam müşteri sayısı: ${customerProvider.allCustomers.length}');
          print(
              'Aktif müşteri sayısı: ${customerProvider.allCustomers.where((customer) => customer.status.isActive).length}');

          return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Müşteri Bilgisi
                    if (widget.payment != null)
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
                              'Bu ödeme için seçili müşteri',
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
                      // Yeni ödeme modu - Müşteri seçimi
                      SizedBox(
                        height: 66,
                        child: CheckboxListTile(
                          dense: true,
                          title: Text(
                            'Müşteri Seçimi (${_selectedCustomerIds.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                      ),

                    // Müşteri Listesi - Sadece yeni ödeme modunda
                    if (widget.payment == null) ...[
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                  Colors.green.withOpacity(0.1),
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
                                                  color: Colors.green,
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
                      decoration: InputDecoration(
                        labelText: 'Tutar (₺)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.money),
                        suffixText: '₺',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen tutar girin';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Geçerli bir tutar girin';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Ödeme Yöntemi
                    DropdownButtonFormField<PaymentMethod>(
                      value: _selectedMethod,
                      decoration: InputDecoration(
                        labelText: 'Ödeme Yöntemi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.payment),
                      ),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem<PaymentMethod>(
                          value: method,
                          child: Text(_getPaymentMethodText(method)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Ödeme Tarihi
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ödeme Tarihi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notlar
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notlar (Opsiyonel)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _savePayment,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.payment == null ? 'Kaydet' : 'Güncelle'),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.bank:
        return 'Banka Transferi';
      case PaymentMethod.card:
        return 'Kredi Kartı';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_selectedCustomerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir müşteri seçin')),
      );
      return;
    }

    final customerProvider = context.read<CustomerProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    // Her seçili müşteri için ödeme oluştur
    for (final customerId in _selectedCustomerIds) {
      final customer = customerProvider.allCustomers.firstWhere(
        (c) => c.id == customerId,
      );

      final payment = Payment(
        id: widget.payment?.id ??
            '${DateTime.now().millisecondsSinceEpoch}_$customerId',
        customerId: customerId,
        customerName: '${customer.firstName} ${customer.lastName}',
        amount: double.parse(_amountController.text),
        paymentDate: _selectedDate,
        method: _selectedMethod,
        status: PaymentStatus.completed,
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      try {
        if (widget.payment == null) {
          await paymentProvider.createPayment(payment);
        } else {
          await paymentProvider.updatePayment(payment);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.payment == null
              ? '${_selectedCustomerIds.length} müşteri için ödeme kaydedildi'
              : 'Ödeme güncellendi'),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
