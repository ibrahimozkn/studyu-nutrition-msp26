import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/widgets/food_entry_chip.dart';
import 'package:studyu_app/widgets/gatsot_selector.dart';
import 'package:studyu_app/widgets/natural_language_input_widget.dart';
import 'package:studyu_app/widgets/portion_adjustment_sheet.dart';
import 'package:studyu_app/widgets/quick_food_add_widget.dart';
import 'package:studyu_app/widgets/template_carousel_widget.dart';
import 'package:studyu_core/core.dart';

class QuickMealEntryScreen extends StatefulWidget {
  const QuickMealEntryScreen({super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const QuickMealEntryScreen());

  @override
  State<QuickMealEntryScreen> createState() => _QuickMealEntryScreenState();
}

class _QuickMealEntryScreenState extends State<QuickMealEntryScreen> {
  static const int _breakfastStart = 6;
  static const int _brunchStart = 10;
  static const int _lunchStart = 12;
  static const int _dinnerStart = 16;
  static const int _dinnerEnd = 21;

  late DateTime _timestamp;
  late MealType _mealType;
  bool _autoMealType = true;
  final List<FoodEntry> _foods = [];

  late final TextEditingController _nlController;

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();
    _mealType = _getMealTypeByTime(_timestamp);
    _nlController = TextEditingController();
  }

  @override
  void dispose() {
    _nlController.dispose();
    super.dispose();
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

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year,
          _timestamp.month,
          _timestamp.day,
          picked.hour,
          picked.minute,
        );
        if (_autoMealType) {
          _mealType = _getMealTypeByTime(_timestamp);
        }
      });
    }
  }

  void _addFoods(List<FoodEntry> foods) {
    setState(() {
      _foods.addAll(foods);
    });
  }

  void _removeFood(int index) {
    setState(() {
      _foods.removeAt(index);
    });
  }

  void _updateFood(int index, FoodEntry updatedFood) {
    setState(() {
      _foods[index] = updatedFood;
    });
  }

  void _saveMeal(DailyRecallEntryViewModel model) {
    final meal = MealLog.withId(
      mealType: _mealType,
      mealContext: MealContext.home,
      timestamp: _timestamp,
      timezone: DateTime.now().timeZoneName,
      isSkipped: false,
      foods: List.of(_foods),
    );

    model.addMeal(meal);
    Navigator.of(context).pop();
  }

  String _getMealTypeLabel(AppLocalizations l10n, MealType type) {
    switch (type) {
      case MealType.breakfast:
        return l10n.meal_type_breakfast;
      case MealType.brunch:
        return l10n.meal_type_brunch;
      case MealType.lunch:
        return l10n.meal_type_lunch;
      case MealType.dinner:
        return l10n.meal_type_dinner;
      case MealType.snack:
        return l10n.meal_type_snack;
      case MealType.other:
        return l10n.meal_type_other;
    }
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.brunch:
        return Icons.brunch_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.fastfood;
      case MealType.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return Consumer<DailyRecallEntryViewModel>(
      builder: (context, model, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.meal_entry_title),
          ),
          floatingActionButton: _foods.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _saveMeal(model),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.save),
                ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_timestamp.hour.toString().padLeft(2, '0')}:${_timestamp.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onPrimaryContainer,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GatsotSelector<MealType>(
                  label: l10n.meal_type_label,
                  items: MealType.values,
                  selectedValue: _mealType,
                  onSelected: (value) {
                    setState(() {
                      _autoMealType = false;
                      _mealType = value;
                    });
                  },
                  itemBuilder: (context, item, isSelected) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getMealTypeIcon(item),
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getMealTypeLabel(l10n, item),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.quick_summary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                NaturalLanguageInputWidget(
                  controller: _nlController,
                ),
                const SizedBox(height: 24),
                TemplateCarouselWidget(
                  userId: userId,
                  label: l10n.from_template,
                  onAddFoods: _addFoods,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.food_items_section(_foods.length),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_foods.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: Text(
                      l10n.no_food_items_yet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Column(
                    children: List.generate(_foods.length, (index) {
                      final food = _foods[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FoodEntryChip(
                          food: food,
                          onDelete: () => _removeFood(index),
                          onTap: () async {
                            final updated = await PortionAdjustmentSheet.show(
                              context,
                              food: food,
                            );
                            if (updated != null) {
                              _updateFood(index, updated);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 24),
                QuickFoodAddWidget(
                  onFoodSelected: (food) => _addFoods([food]),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
