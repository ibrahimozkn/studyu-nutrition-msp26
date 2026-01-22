import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/portion_adjustment_sheet.dart';
import 'package:studyu_core/core.dart';

class FoodEntryChip extends StatelessWidget {
  final FoodEntry food;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const FoodEntryChip({
    required this.food,
    this.onDelete,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _buildChip(context);

    if (onDelete == null) {
      return chip;
    }

    return Dismissible(
      key: ValueKey('food-entry-${food.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: chip,
    );
  }

  Widget _buildChip(BuildContext context) {
    final theme = Theme.of(context);
    final amountText = '${_formatAmount(food.amount)} ${food.unit}';
    final caloriesText = '${food.nutrition.energyKcal.toStringAsFixed(0)} kcal';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => PortionAdjustmentSheet.show(context, food: food),
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amountText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              _CalorieBadge(text: caloriesText),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) return amount.toStringAsFixed(0);
    return amount.toStringAsFixed(1);
  }
}

class _CalorieBadge extends StatelessWidget {
  final String text;

  const _CalorieBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
