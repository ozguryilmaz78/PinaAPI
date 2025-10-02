// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'due_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DueModel _$DueModelFromJson(Map<String, dynamic> json) => DueModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$DueStatusEnumMap, json['status']),
      period: json['period'] as String,
      notes: json['notes'] as String?,
      paymentId: json['paymentId'] as String?,
    );

Map<String, dynamic> _$DueModelToJson(DueModel instance) => <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'amount': instance.amount,
      'dueDate': instance.dueDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$DueStatusEnumMap[instance.status]!,
      'period': instance.period,
      'notes': instance.notes,
      'paymentId': instance.paymentId,
    };

const _$DueStatusEnumMap = {
  DueStatus.pending: 'pending',
  DueStatus.paid: 'paid',
  DueStatus.overdue: 'overdue',
  DueStatus.cancelled: 'cancelled',
};
