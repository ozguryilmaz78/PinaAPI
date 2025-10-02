import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.email,
    super.address,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      firstName: customer.firstName,
      lastName: customer.lastName,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      status: customer.status,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      address: address,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
