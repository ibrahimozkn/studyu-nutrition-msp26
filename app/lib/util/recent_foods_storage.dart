import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';

class RecentFoodsStorage {
  static const String _recentFoodsKey = 'studyu_recent_foods';
  static const int _maxItems = 10;

  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _keyForUser(String? userId) {
    if (userId == null || userId.isEmpty) return _recentFoodsKey;
    return '${_recentFoodsKey}_$userId';
  }

  Future<List<FoodEntry>> loadRecentFoods({String? userId}) async {
    final prefs = await _getPrefs();
    final key = _keyForUser(userId);
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => FoodEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      StudyULogger.error('Failed to load recent foods: $e');
      return [];
    }
  }

  Future<void> saveRecentFoods(
    List<FoodEntry> foods, {
    String? userId,
  }) async {
    final prefs = await _getPrefs();
    final key = _keyForUser(userId);

    final trimmedFoods = foods.take(_maxItems).toList();
    final jsonList = trimmedFoods.map((food) => food.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<FoodEntry>> addRecentFood(
    FoodEntry food, {
    String? userId,
  }) async {
    final foods = await loadRecentFoods(userId: userId);

    foods.removeWhere((existing) => _isSameFood(existing, food));
    foods.insert(0, food);

    if (foods.length > _maxItems) {
      foods.removeRange(_maxItems, foods.length);
    }

    await saveRecentFoods(foods, userId: userId);
    return foods;
  }

  Future<List<FoodEntry>> addRecentFoods(
    List<FoodEntry> foods, {
    String? userId,
  }) async {
    if (foods.isEmpty) return loadRecentFoods(userId: userId);

    var recent = await loadRecentFoods(userId: userId);

    for (final food in foods) {
      recent.removeWhere((existing) => _isSameFood(existing, food));
      recent.insert(0, food);
    }

    if (recent.length > _maxItems) {
      recent = recent.take(_maxItems).toList();
    }

    await saveRecentFoods(recent, userId: userId);
    return recent;
  }

  bool _isSameFood(FoodEntry a, FoodEntry b) {
    final aJson = a.toJson();
    final bJson = b.toJson();

    final aId = aJson['id'];
    final bId = bJson['id'];

    if (aId != null && bId != null) return aId == bId;

    return aJson['name'] == bJson['name'] &&
        aJson['entryType'] == bJson['entryType'];
  }
}
