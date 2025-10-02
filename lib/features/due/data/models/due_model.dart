import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/due.dart';

part 'due_model.g.dart';

@JsonSerializable()
class DueModel extends Due {
  const DueModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.amount,
    required super.dueDate,
    required super.createdAt,
    required super.status,
    required super.period,
    super.notes,
    super.paymentId,
  });

  factory DueModel.fromJson(Map<String, dynamic> json) =>
      _$DueModelFromJson(json);

  Map<String, dynamic> toJson() => _$DueModelToJson(this);

  factory DueModel.fromEntity(Due due) {
    return DueModel(
      id: due.id,
      customerId: due.customerId,
      customerName: due.customerName,
      amount: due.amount,
      dueDate: due.dueDate,
      createdAt: due.createdAt,
      status: due.status,
      period: due.period,
      notes: due.notes,
      paymentId: due.paymentId,
    );
  }

  Due toEntity() {
    return Due(
      id: id,
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      dueDate: dueDate,
      createdAt: createdAt,
      status: status,
      period: period,
      notes: notes,
      paymentId: paymentId,
    );
  }

  @override
  DueModel copyWith({
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
    return DueModel(
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
}
