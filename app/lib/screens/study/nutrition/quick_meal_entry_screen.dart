import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/quick_meal_entry_view_model.dart';
import 'package:studyu_app/widgets/food_entry_chip.dart';
import 'package:studyu_app/widgets/gatsot_expansion_tile.dart';
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
  bool _autoMealType = true;

  late final TextEditingController _nlController;
  late final TextEditingController _locationDescriptionController;

  late MealContext _mealContext;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _locationDescription;

  @override
  void initState() {
    super.initState();
    _nlController = TextEditingController();
    _locationDescriptionController = TextEditingController();
    _mealContext = MealContext.home;
    _companyContext = null;
    _distractionContext = null;
    _locationDescription = null;
  }

  @override
  void dispose() {
    _nlController.dispose();
    _locationDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(QuickMealEntryViewModel viewModel) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(viewModel.timestamp),
    );
    if (picked != null) {
      final updatedTimestamp = DateTime(
        viewModel.timestamp.year,
        viewModel.timestamp.month,
        viewModel.timestamp.day,
        picked.hour,
        picked.minute,
      );
      viewModel.setTimestamp(
        updatedTimestamp,
        updateMealType: _autoMealType,
      );
    }
  }

  void _saveMeal(
    DailyRecallEntryViewModel model,
    QuickMealEntryViewModel viewModel,
  ) {
    final locationDescription = _mealContext == MealContext.other
        ? _locationDescription?.trim()
        : null;

    final meal = MealLog.withId(
      mealType: viewModel.mealType,
      mealContext: _mealContext,
      locationDescription:
          locationDescription == '' ? null : locationDescription,
      companyContext: _companyContext,
      distractionContext: _distractionContext,
      timestamp: viewModel.timestamp,
      timezone: DateTime.now().timeZoneName,
      isSkipped: false,
      foods: List.of(viewModel.foods),
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

  String _getMealContextLabel(MealContext mealContext) {
    final l10n = AppLocalizations.of(context)!;
    switch (mealContext) {
      case MealContext.home:
        return l10n.context_home;
      case MealContext.restaurant:
        return l10n.context_restaurant;
      case MealContext.takeout:
        return l10n.context_takeout;
      case MealContext.vending:
        return l10n.context_vending;
      case MealContext.other:
        return l10n.context_other;
    }
  }

  String _getCompanyContextLabel(CompanyContext companyContext) {
    final l10n = AppLocalizations.of(context)!;
    switch (companyContext) {
      case CompanyContext.alone:
        return l10n.company_alone;
      case CompanyContext.family:
        return l10n.company_family;
      case CompanyContext.friends:
        return l10n.company_friends;
      case CompanyContext.colleagues:
        return l10n.company_colleagues;
      case CompanyContext.other:
        return l10n.company_other;
    }
  }

  String _getDistractionContextLabel(DistractionContext distractionContext) {
    final l10n = AppLocalizations.of(context)!;
    switch (distractionContext) {
      case DistractionContext.none:
        return l10n.distraction_none;
      case DistractionContext.tv:
        return l10n.distraction_tv;
      case DistractionContext.phone:
        return l10n.distraction_phone;
      case DistractionContext.work:
        return l10n.distraction_work;
      case DistractionContext.other:
        return l10n.distraction_other;
    }
  }

  Future<void> _handleNaturalLanguageSubmit(
    QuickMealEntryViewModel viewModel,
    String value,
  ) async {
    if (value.trim().isEmpty) return;
    await viewModel.submitNaturalLanguageInput(value);
    if (mounted) {
      _nlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return ChangeNotifierProvider(
      create: (_) => QuickMealEntryViewModel(),
      child: Consumer2<DailyRecallEntryViewModel, QuickMealEntryViewModel>(
        builder: (context, model, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.meal_entry_title),
            ),
            floatingActionButton: viewModel.foods.isEmpty
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _saveMeal(model, viewModel),
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
                      onTap: () => _selectTime(viewModel),
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
                              '${viewModel.timestamp.hour.toString().padLeft(2, '0')}:${viewModel.timestamp.minute.toString().padLeft(2, '0')}',
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
                    selectedValue: viewModel.mealType,
                    onSelected: (value) {
                      setState(() {
                        _autoMealType = false;
                      });
                      viewModel.setMealType(value);
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
                    onSubmitted: (value) =>
                        _handleNaturalLanguageSubmit(viewModel, value),
                  ),
                  if (viewModel.isLoading && viewModel.loadingMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.loadingMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          if (viewModel.retryAction != null)
                            TextButton(
                              onPressed: () {
                                viewModel.clearError();
                                viewModel.retryAction?.call();
                              },
                              child: Text(l10n.try_again),
                            ),
                          TextButton(
                            onPressed: viewModel.clearError,
                            child: Text(l10n.close),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TemplateCarouselWidget(
                    userId: userId,
                    label: l10n.from_template,
                    onAddFoods: (foods) {
                      viewModel.clearError();
                      viewModel.addFoods(foods);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.food_items_section(viewModel.foods.length),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.foods.isEmpty)
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
                      children: List.generate(viewModel.foods.length, (index) {
                        final food = viewModel.foods[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FoodEntryChip(
                            food: food,
                            onDelete: () => viewModel.removeFoodAt(index),
                            onTap: () async {
                              final updated =
                                  await PortionAdjustmentSheet.show(
                                context,
                                food: food,
                              );
                              if (updated != null) {
                                viewModel.updateFood(index, updated);
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: 24),
                  QuickFoodAddWidget(
                    userId: userId,
                    onFoodSelected: (food) => viewModel.addFoods([food]),
                    onActionStarted: (message) {
                      viewModel.clearError();
                      viewModel.setLoading(true, message: message);
                    },
                    onActionFinished: () => viewModel.setLoading(false),
                    onActionError: (message, retry) {
                      viewModel.setError(message, retry: retry);
                    },
                  ),
                  const SizedBox(height: 24),
                  GatsotExpansionTile(
                    title: l10n.additionalInfo,
                    icon: Icons.tune,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.where_did_you_eat,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MealContext.values.map((ctx) {
                            final isSelected = _mealContext == ctx;
                            return ChoiceChip(
                              label: Text(_getMealContextLabel(ctx)),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _mealContext = ctx);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        if (_mealContext == MealContext.other) ...[
                          TextField(
                            decoration: InputDecoration(
                              labelText: l10n.location_description,
                              border: const OutlineInputBorder(),
                              hintText: l10n.location_description_hint,
                            ),
                            onChanged: (value) => _locationDescription = value,
                            controller: _locationDescriptionController,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          l10n.who_were_you_with,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.not_specified),
                              selected: _companyContext == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _companyContext = null);
                                }
                              },
                            ),
                            ...CompanyContext.values.map((ctx) {
                              final isSelected = _companyContext == ctx;
                              return ChoiceChip(
                                label: Text(_getCompanyContextLabel(ctx)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _companyContext = ctx);
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.distractions_during_meal,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.not_specified),
                              selected: _distractionContext == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _distractionContext = null);
                                }
                              },
                            ),
                            ...DistractionContext.values.map((ctx) {
                              final isSelected = _distractionContext == ctx;
                              return ChoiceChip(
                                label: Text(_getDistractionContextLabel(ctx)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _distractionContext = ctx);
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
