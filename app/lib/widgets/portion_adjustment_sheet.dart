import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class PortionAdjustmentSheet extends StatefulWidget {
  final FoodEntry food;
  final ValueChanged<FoodEntry>? onConfirm;

  const PortionAdjustmentSheet({
    required this.food,
    this.onConfirm,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required FoodEntry food,
    ValueChanged<FoodEntry>? onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PortionAdjustmentSheet(
        food: food,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<PortionAdjustmentSheet> createState() =>
      _PortionAdjustmentSheetState();
}

class _PortionAdjustmentSheetState extends State<PortionAdjustmentSheet> {
  static const List<double> _presetMultipliers = [0.5, 1.0, 1.5, 2.0];

  late double _multiplier;

  @override
  void initState() {
    super.initState();
    _multiplier = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaledFood = _scaleFoodEntry(widget.food, _multiplier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Adjust portion',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.food.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${_formatAmount(scaledFood.amount)} ${scaledFood.unit}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${scaledFood.nutrition.energyKcal.toStringAsFixed(0)} kcal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multiplier',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_multiplier.toStringAsFixed(1)}x',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _multiplier,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    label: '${_multiplier.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      setState(() {
                        _multiplier = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presets',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetMultipliers
                        .map(
                          (value) => ChoiceChip(
                            label: Text('${value.toStringAsFixed(1)}x'),
                            selected: (_multiplier - value).abs() < 0.01,
                            onSelected: (_) => _setMultiplier(value),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final updated = _scaleFoodEntry(widget.food, _multiplier);
                    widget.onConfirm?.call(updated);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setMultiplier(double value) {
    setState(() {
      _multiplier = value;
    });
  }

  FoodEntry _scaleFoodEntry(FoodEntry base, double multiplier) {
    return FoodEntry(
      id: base.id,
      entryType: base.entryType,
      name: base.name,
      brandName: base.brandName,
      description: base.description,
      amount: base.amount * multiplier,
      unit: base.unit,
      servingSizeGrams: base.servingSizeGrams,
      portionReference: base.portionReference,
      portionEstimationMethod: base.portionEstimationMethod,
      portionState: base.portionState,
      yieldFactor: base.yieldFactor,
      ediblePortion: base.ediblePortion,
      nutrition: _scaleNutrition(base.nutrition, multiplier),
      foodCode: base.foodCode,
      externalId: base.externalId,
      source: base.source,
      confidenceScore: base.confidenceScore,
      templateId: base.templateId,
      createdAt: base.createdAt,
      modifiedAt: base.modifiedAt,
      originalValues: base.originalValues,
      parentRecipeId: base.parentRecipeId,
      recipeMetadata: base.recipeMetadata,
      recipeIngredients: base.recipeIngredients,
    );
  }

  NutritionProfile _scaleNutrition(NutritionProfile base, double multiplier) {
    return NutritionProfile(
      energyKcal: base.energyKcal * multiplier,
      protein: base.protein * multiplier,
      carbs: base.carbs * multiplier,
      fat: base.fat * multiplier,
      sugars: base.sugars * multiplier,
      fiber: base.fiber * multiplier,
      saturatedFat: base.saturatedFat * multiplier,
      transFat: base.transFat * multiplier,
      cholesterol: base.cholesterol * multiplier,
      sodium: base.sodium * multiplier,
      waterContent: base.waterContent * multiplier,
      micros: base.micros.map(
        (key, value) => MapEntry(key, value * multiplier),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) return amount.toStringAsFixed(0);
    return amount.toStringAsFixed(1);
  }
}
