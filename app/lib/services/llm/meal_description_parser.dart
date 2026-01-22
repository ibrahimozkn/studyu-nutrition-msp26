import 'package:studyu_core/core.dart';

abstract class MealDescriptionParser {
  List<FoodEntry> parseMealDescription(String description);

  FoodEntry? parseFoodDescription(String description);
}
