import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/inline_food_search_sheet.dart';
import 'package:studyu_core/core.dart';

class QuickFoodAddWidget extends StatelessWidget {
  final ValueChanged<FoodEntry>? onFoodSelected;

  const QuickFoodAddWidget({
    this.onFoodSelected,
    super.key,
  });

  static final List<FoodEntry> _recentFoods = [
    FoodEntry.withId(
      entryType: FoodEntryType.singleIngredient,
      name: 'Greek yogurt',
      description: 'Plain nonfat Greek yogurt',
      amount: 1,
      unit: 'cup',
      servingSizeGrams: 245,
      portionReference: '1 cup',
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: 130,
        protein: 23,
        carbs: 9,
        fat: 0,
        sugars: 9,
        fiber: 0,
        saturatedFat: 0,
        transFat: 0,
        cholesterol: 10,
        sodium: 70,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.7,
      originalValues: {},
    ),
    FoodEntry.withId(
      entryType: FoodEntryType.singleIngredient,
      name: 'Banana',
      description: 'Medium banana',
      amount: 1,
      unit: 'banana',
      servingSizeGrams: 118,
      portionReference: '1 medium',
      portionEstimationMethod: PortionEstimationMethod.standardUnit,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: 105,
        protein: 1.3,
        carbs: 27,
        fat: 0.3,
        sugars: 14,
        fiber: 3.1,
        saturatedFat: 0.1,
        transFat: 0,
        cholesterol: 0,
        sodium: 1,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.7,
      originalValues: {},
    ),
    FoodEntry.withId(
      entryType: FoodEntryType.recipe,
      name: 'Chicken salad',
      description: 'Grilled chicken with greens',
      amount: 1,
      unit: 'bowl',
      servingSizeGrams: 320,
      portionReference: '1 bowl',
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: 380,
        protein: 34,
        carbs: 18,
        fat: 18,
        sugars: 6,
        fiber: 5,
        saturatedFat: 3.5,
        transFat: 0,
        cholesterol: 95,
        sodium: 520,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.65,
      originalValues: {},
    ),
    FoodEntry.withId(
      entryType: FoodEntryType.singleIngredient,
      name: 'Almonds',
      description: 'Raw almonds',
      amount: 1,
      unit: 'oz',
      servingSizeGrams: 28,
      portionReference: '1 oz (about 23 almonds)',
      portionEstimationMethod: PortionEstimationMethod.standardUnit,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: 164,
        protein: 6,
        carbs: 6,
        fat: 14,
        sugars: 1.2,
        fiber: 3.5,
        saturatedFat: 1.1,
        transFat: 0,
        cholesterol: 0,
        sodium: 0,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.6,
      originalValues: {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Foods',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentFoods
                .map(
                  (food) => _RecentFoodChip(
                    food: food,
                    onSelected: () => _handleRecentFood(food),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                icon: Icons.search,
                label: 'Search',
                onPressed: () => _openSearch(context),
              ),
              _ActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan Barcode',
                onPressed: () => _openBarcodeScanner(context),
              ),
              _ActionButton(
                icon: Icons.edit_note,
                label: 'Custom Food',
                onPressed: () => _openCustomFood(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleRecentFood(FoodEntry food) {
    onFoodSelected?.call(food);
  }

  Future<void> _openSearch(BuildContext context) async {
    final result = await InlineFoodSearchSheet.show(context);
    if (result != null) {
      onFoodSelected?.call(result);
    }
  }

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final result = await Navigator.of(context).push(
      BarcodeScannerScreen.route(),
    );
    if (result != null) {
      onFoodSelected?.call(result);
    }
  }

  Future<void> _openCustomFood(BuildContext context) async {
    final result = await Navigator.of(context).push(
      FoodEntryScreen.route(),
    );
    if (result != null) {
      onFoodSelected?.call(result);
    }
  }
}

class _RecentFoodChip extends StatelessWidget {
  final FoodEntry food;
  final VoidCallback onSelected;

  const _RecentFoodChip({
    required this.food,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calories = food.nutrition.energyKcal.round();

    return ActionChip(
      onPressed: onSelected,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            food.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$calories kcal',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
