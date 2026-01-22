import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/food_entry_chip.dart';
import 'package:studyu_core/core.dart';

Widget setup(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

FoodEntry _sampleFood() {
  return FoodEntry.withId(
    entryType: FoodEntryType.recipe,
    name: 'Oatmeal with berries',
    description: 'Rolled oats cooked with mixed berries',
    amount: 1.5,
    unit: 'bowl',
    servingSizeGrams: 280,
    portionReference: '1 bowl',
    portionEstimationMethod: PortionEstimationMethod.householdMeasure,
    portionState: PortionState.asServed,
    nutrition: NutritionProfile(
      energyKcal: 290,
      protein: 9,
      carbs: 52,
      fat: 6,
      sugars: 12,
      fiber: 8,
      saturatedFat: 1.5,
      transFat: 0,
      cholesterol: 0,
      sodium: 120,
      waterContent: 0,
      micros: {},
    ),
    source: FoodSource.manual,
    confidenceScore: 0.6,
    originalValues: {},
  );
}

void main() {
  testWidgets('FoodEntryChip renders name, amount, unit, and calories', (
    tester,
  ) async {
    final food = _sampleFood();

    await tester.pumpWidget(
      setup(
        FoodEntryChip(food: food),
      ),
    );

    expect(find.text('Oatmeal with berries'), findsOneWidget);
    expect(find.text('1.5 bowl'), findsOneWidget);
    expect(find.text('290 kcal'), findsOneWidget);
  });

  testWidgets('FoodEntryChip triggers onTap', (tester) async {
    final food = _sampleFood();
    var tapped = false;

    await tester.pumpWidget(
      setup(
        FoodEntryChip(
          food: food,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(FoodEntryChip));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('FoodEntryChip triggers delete on long press', (tester) async {
    final food = _sampleFood();
    var deleted = false;

    await tester.pumpWidget(
      setup(
        FoodEntryChip(
          food: food,
          onDelete: () => deleted = true,
        ),
      ),
    );

    await tester.longPress(find.byType(FoodEntryChip));
    await tester.pump();

    expect(deleted, isTrue);
  });
}
