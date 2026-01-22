import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/llm/meal_description_parser.dart';
import 'package:studyu_app/services/llm/mock_meal_description_parser.dart';
import 'package:studyu_core/core.dart';

void main() {
  group('MockMealDescriptionParser', () {
    late MealDescriptionParser parser;

    setUp(() {
      parser = MockMealDescriptionParser();
    });

    test('parseMealDescription returns list of FoodEntry objects', () {
      final result = parser.parseMealDescription('oatmeal with berries');

      expect(result, isNotNull);
      expect(result, isA<List<FoodEntry>>());
      expect(result.length, equals(3));
    });

    test('parseMealDescription returns foods with valid nutrition', () {
      final result = parser.parseMealDescription('chicken salad');

      for (final food in result) {
        expect(food.name, isNotEmpty);
        expect(food.amount, greaterThan(0));
        expect(food.unit, isNotEmpty);
        expect(food.nutrition.energyKcal, greaterThan(0));
        expect(food.nutrition.protein, greaterThanOrEqualTo(0));
        expect(food.nutrition.carbs, greaterThanOrEqualTo(0));
        expect(food.nutrition.fat, greaterThanOrEqualTo(0));
      }
    });

    test('parseFoodDescription returns single FoodEntry for oatmeal', () {
      final result = parser.parseFoodDescription('oatmeal');

      expect(result, isNotNull);
      expect(result!.name.toLowerCase(), contains('oatmeal'));
      expect(result.nutrition.energyKcal, greaterThan(0));
    });

    test('parseFoodDescription returns single FoodEntry for coffee', () {
      final result = parser.parseFoodDescription('I love coffee with milk');

      expect(result, isNotNull);
      expect(result!.name.toLowerCase(), contains('coffee'));
      expect(result.nutrition.energyKcal, greaterThan(0));
    });

    test('parseFoodDescription returns single FoodEntry for eggs', () {
      final result = parser.parseFoodDescription('eggs');

      expect(result, isNotNull);
      expect(result?.name, contains('eggs'));
      expect(result?.nutrition.energyKcal, greaterThan(0));
    });

    test('parseFoodDescription returns null for unknown food', () {
      final result = parser.parseFoodDescription('unknown_food_xyz');

      expect(result, isNull);
    });

    test('parseFoodDescription returns null for empty string', () {
      final result = parser.parseFoodDescription('');

      expect(result, isNull);
    });

    test('returned FoodEntry has all required fields', () {
      final result = parser.parseMealDescription('yogurt');

      expect(result.isNotEmpty, true);

      final food = result.first;
      expect(food.id, isNotNull);
      expect(food.entryType, isNotNull);
      expect(food.name, isNotEmpty);
      expect(food.amount, greaterThan(0));
      expect(food.unit, isNotEmpty);
      expect(food.servingSizeGrams, greaterThan(0));
      expect(food.nutrition, isNotNull);
      expect(food.source, isNotNull);
    });

    test('parseMealDescription always returns same mock foods', () {
      final result1 = parser.parseMealDescription('breakfast');
      final result2 = parser.parseMealDescription('lunch');

      // Mock parser always returns the same 3 foods
      expect(result1.length, equals(result2.length));
      expect(result1.first.name, equals(result2.first.name));
    });
  });
}
