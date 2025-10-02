import 'package:equatable/equatable.dart';

enum DueStatus { pending, paid, overdue, cancelled }

class Due extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime dueDate;
  final DateTime createdAt;
  final DueStatus status;
  final String period; // "2024-01", "2024-02" formatında
  final String? notes;
  final String? paymentId; // Ödeme yapıldığında bağlantı

  const Due({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    required this.createdAt,
    required this.status,
    required this.period,
    this.notes,
    this.paymentId,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        amount,
        dueDate,
        createdAt,
        status,
        period,
        notes,
        paymentId,
      ];

  Due copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? amount,
    DateTime? dueDate,
    DateTime? createdAt,
    DueStatus? status,
    String? period,
    String? notes,
    String? paymentId,
  }) {
    return Due(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      period: period ?? this.period,
      notes: notes ?? this.notes,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  // Yardımcı metodlar
  bool get isOverdue {
    return status == DueStatus.pending && dueDate.isBefore(DateTime.now());
  }

  bool get isPaid {
    return status == DueStatus.paid;
  }

  bool get isPending {
    return status == DueStatus.pending;
  }

  String get statusText {
    switch (status) {
      case DueStatus.pending:
        return isOverdue ? 'Vadesi Geçmiş' : 'Bekliyor';
      case DueStatus.paid:
        return 'Ödendi';
      case DueStatus.overdue:
        return 'Vadesi Geçmiş';
      case DueStatus.cancelled:
        return 'İptal';
    }
  }

  String get periodDisplayText {
    final year = period.substring(0, 4);
    final month = period.substring(5, 7);
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
    return '${monthNames[int.parse(month)]} $year';
  }
}

