import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class QuickMealEntryViewModel extends ChangeNotifier {
  static const int _breakfastStart = 6;
  static const int _brunchStart = 10;
  static const int _lunchStart = 12;
  static const int _dinnerStart = 16;
  static const int _dinnerEnd = 21;

  final List<FoodEntry> _foods = [];
  late DateTime _timestamp;
  late MealType _mealType;

  QuickMealEntryViewModel({DateTime? initialTimestamp}) {
    _timestamp = initialTimestamp ?? DateTime.now();
    _mealType = _getMealTypeByTime(_timestamp);
  }

  DateTime get timestamp => _timestamp;
  MealType get mealType => _mealType;
  List<FoodEntry> get foods => List.unmodifiable(_foods);

  void setTimestamp(DateTime timestamp, {bool updateMealType = false}) {
    _timestamp = timestamp;
    if (updateMealType) {
      _mealType = _getMealTypeByTime(_timestamp);
    }
    notifyListeners();
  }

  void setMealType(MealType type) {
    _mealType = type;
    notifyListeners();
  }

  void addFoods(List<FoodEntry> foods) {
    if (foods.isEmpty) return;
    _foods.addAll(foods);
    notifyListeners();
  }

  void removeFoodAt(int index) {
    _foods.removeAt(index);
    notifyListeners();
  }

  void updateFood(int index, FoodEntry updatedFood) {
    _foods[index] = updatedFood;
    notifyListeners();
  }

  MealType _getMealTypeByTime(DateTime time) {
    final hour = time.hour;
    if (hour >= _breakfastStart && hour < _brunchStart) {
      return MealType.breakfast;
    }
    if (hour >= _brunchStart && hour < _lunchStart) return MealType.brunch;
    if (hour >= _lunchStart && hour < _dinnerStart) return MealType.lunch;
    if (hour >= _dinnerStart && hour < _dinnerEnd) return MealType.dinner;
    return MealType.snack;
  }
}
