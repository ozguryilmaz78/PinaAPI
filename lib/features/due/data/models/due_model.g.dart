// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'due_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DueModel _$DueModelFromJson(Map<String, dynamic> json) => DueModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: $enumDecode(_$DueStatusEnumMap, json['status']),
      period: json['period'] as String,
      notes: json['notes'] as String?,
      paymentId: json['payment_id'] as String?,
    );

Map<String, dynamic> _$DueModelToJson(DueModel instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'amount': instance.amount,
      'due_date': instance.dueDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'status': _$DueStatusEnumMap[instance.status]!,
      'period': instance.period,
      'notes': instance.notes,
      'payment_id': instance.paymentId,
    };

const _$DueStatusEnumMap = {
  DueStatus.pending: 'pending',
  DueStatus.paid: 'paid',
  DueStatus.overdue: 'overdue',
  DueStatus.cancelled: 'cancelled',
};
