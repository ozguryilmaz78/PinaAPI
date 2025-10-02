import 'package:equatable/equatable.dart';

enum PaymentMethod { cash, bank, card, other }

enum PaymentStatus { pending, completed, cancelled }

class Payment extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime paymentDate;
  final DateTime createdAt;
  final String? notes;
  final String? referenceNumber;

  const Payment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.method,
    required this.status,
    required this.paymentDate,
    required this.createdAt,
    this.notes,
    this.referenceNumber,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        amount,
        method,
        status,
        paymentDate,
        createdAt,
        notes,
        referenceNumber,
      ];

  Payment copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? paymentDate,
    DateTime? createdAt,
    String? notes,
    String? referenceNumber,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }
}

