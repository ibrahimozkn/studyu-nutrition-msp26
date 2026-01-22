import 'package:studyu_app/services/llm/meal_description_parser.dart';
import 'package:studyu_core/core.dart';

class MockMealDescriptionParser implements MealDescriptionParser {
  @override
  List<FoodEntry> parseMealDescription(String description) {
    return <FoodEntry>[
      _oatmealWithBerries(),
      _coffeeWithMilk(),
      _scrambledEggs(),
    ];
  }

  @override
  FoodEntry? parseFoodDescription(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('oatmeal')) {
      return _oatmealWithBerries();
    }
    if (lower.contains('coffee')) {
      return _coffeeWithMilk();
    }
    if (lower.contains('eggs') || lower.contains('egg')) {
      return _scrambledEggs();
    }
    return null;
  }

  FoodEntry _oatmealWithBerries() {
    return FoodEntry.withId(
      entryType: FoodEntryType.recipe,
      name: 'Oatmeal with berries',
      description: 'Rolled oats cooked with mixed berries',
      amount: 1,
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

  FoodEntry _coffeeWithMilk() {
    return FoodEntry.withId(
      entryType: FoodEntryType.singleIngredient,
      name: 'Coffee with milk',
      description: 'Brewed coffee with a splash of milk',
      amount: 1,
      unit: 'cup',
      servingSizeGrams: 240,
      portionReference: '1 cup',
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: 45,
        protein: 2,
        carbs: 5,
        fat: 2,
        sugars: 4,
        fiber: 0,
        saturatedFat: 1.2,
        transFat: 0,
        cholesterol: 5,
        sodium: 50,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.5,
      originalValues: {},
    );
  }

  FoodEntry _scrambledEggs() {
    return FoodEntry.withId(
      entryType: FoodEntryType.recipe,
      name: 'Scrambled eggs',
      description: 'Two eggs cooked with a small pat of butter',
      amount: 2,
      unit: 'eggs',
      servingSizeGrams: 120,
      portionReference: '2 eggs',
      portionEstimationMethod: PortionEstimationMethod.standardUnit,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: 210,
        protein: 13,
        carbs: 2,
        fat: 16,
        sugars: 1,
        fiber: 0,
        saturatedFat: 5.5,
        transFat: 0.2,
        cholesterol: 370,
        sodium: 180,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.55,
      originalValues: {},
    );
  }
}
