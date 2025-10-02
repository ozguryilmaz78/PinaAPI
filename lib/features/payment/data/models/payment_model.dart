import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.amount,
    required super.method,
    required super.status,
    required super.paymentDate,
    required super.createdAt,
    super.notes,
    super.referenceNumber,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      customerId: payment.customerId,
      customerName: payment.customerName,
      amount: payment.amount,
      method: payment.method,
      status: payment.status,
      paymentDate: payment.paymentDate,
      createdAt: payment.createdAt,
      notes: payment.notes,
      referenceNumber: payment.referenceNumber,
    );
  }

  Payment toEntity() {
    return Payment(
      id: id,
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      method: method,
      status: status,
      paymentDate: paymentDate,
      createdAt: createdAt,
      notes: notes,
      referenceNumber: referenceNumber,
    );
  }
}

