import 'package:flutter/material.dart';
import 'package:studyu_app/services/llm/meal_description_parser.dart';
import 'package:studyu_app/services/llm/mock_meal_description_parser.dart';
import 'package:studyu_core/core.dart';

class QuickMealEntryViewModel extends ChangeNotifier {
  static const int _breakfastStart = 6;
  static const int _brunchStart = 10;
  static const int _lunchStart = 12;
  static const int _dinnerStart = 16;
  static const int _dinnerEnd = 21;

  final List<FoodEntry> _foods = [];
  final MealDescriptionParser _mealDescriptionParser;
  late DateTime _timestamp;
  late MealType _mealType;

  bool _isLoading = false;
  String? _loadingMessage;
  String? _errorMessage;
  VoidCallback? _retryAction;
  String _lastNlInput = '';

  QuickMealEntryViewModel({
    DateTime? initialTimestamp,
    MealDescriptionParser? mealDescriptionParser,
  }) : _mealDescriptionParser =
            mealDescriptionParser ?? MockMealDescriptionParser() {
    _timestamp = initialTimestamp ?? DateTime.now();
    _mealType = _getMealTypeByTime(_timestamp);
  }

  DateTime get timestamp => _timestamp;
  MealType get mealType => _mealType;
  List<FoodEntry> get foods => List.unmodifiable(_foods);

  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;
  String? get errorMessage => _errorMessage;
  VoidCallback? get retryAction => _retryAction;

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

  void setLoading(bool value, {String? message}) {
    _isLoading = value;
    if (value) {
      _loadingMessage = message;
    } else {
      _loadingMessage = null;
    }
    notifyListeners();
  }

  void setError(String? message, {VoidCallback? retry}) {
    _errorMessage = message;
    _retryAction = retry;
    notifyListeners();
  }

  void clearError() {
    setError(null);
  }

  Future<void> submitNaturalLanguageInput(String description) async {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return;

    _lastNlInput = trimmed;
    setError(null);
    setLoading(true, message: 'Processing...');

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final foods = _mealDescriptionParser.parseMealDescription(trimmed);
      addFoods(foods);
    } catch (e) {
      setError(
        'Could not parse that description.',
        retry: () => submitNaturalLanguageInput(_lastNlInput),
      );
    } finally {
      setLoading(false);
    }
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
