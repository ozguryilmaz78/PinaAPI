import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_provider.dart';

class CustomerStatusFilter extends StatelessWidget {
  const CustomerStatusFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: 'Tümü',
                isSelected: provider.statusFilter == null,
                onSelected: () => provider.filterByStatus(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Aktif',
                isSelected: provider.statusFilter == CustomerStatus.active,
                onSelected: () =>
                    provider.filterByStatus(CustomerStatus.active),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Pasif',
                isSelected: provider.statusFilter == CustomerStatus.inactive,
                onSelected: () =>
                    provider.filterByStatus(CustomerStatus.inactive),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
