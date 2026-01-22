import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/inline_food_search_sheet.dart';
import 'package:studyu_app/util/recent_foods_storage.dart';
import 'package:studyu_core/core.dart';

typedef ActionErrorCallback = void Function(String message, VoidCallback retry);

typedef ActionStartedCallback = void Function(String message);

class QuickFoodAddWidget extends StatefulWidget {
  final ValueChanged<FoodEntry>? onFoodSelected;
  final String? userId;
  final ActionStartedCallback? onActionStarted;
  final VoidCallback? onActionFinished;
  final ActionErrorCallback? onActionError;

  const QuickFoodAddWidget({
    this.onFoodSelected,
    this.userId,
    this.onActionStarted,
    this.onActionFinished,
    this.onActionError,
    super.key,
  });

  @override
  State<QuickFoodAddWidget> createState() => _QuickFoodAddWidgetState();
}

class _QuickFoodAddWidgetState extends State<QuickFoodAddWidget> {
  final RecentFoodsStorage _storage = RecentFoodsStorage();
  List<FoodEntry> _recentFoods = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadRecentFoods();
  }

  Future<void> _loadRecentFoods() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final foods = await _storage.loadRecentFoods(userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _recentFoods = foods;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load recent foods.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          _buildRecentSection(theme, l10n),
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

  Widget _buildRecentSection(ThemeData theme, AppLocalizations l10n) {
    if (_isLoading) {
      return const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _loadError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadRecentFoods,
            child: Text(l10n.try_again),
          ),
        ],
      );
    }

    if (_recentFoods.isEmpty) {
      return Text(
        'No recent foods yet.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _recentFoods
          .map(
            (food) => _RecentFoodChip(
              food: food,
              onSelected: () => _handleFoodSelected(food),
            ),
          )
          .toList(),
    );
  }

  Future<void> _handleFoodSelected(FoodEntry food) async {
    final updatedFoods = await _storage.addRecentFood(
      food,
      userId: widget.userId,
    );

    if (mounted) {
      setState(() {
        _recentFoods = updatedFoods;
      });
    }

    widget.onFoodSelected?.call(food);
  }

  Future<T?> _runAction<T>(
    String loadingMessage,
    Future<T?> Function() action,
    VoidCallback retry,
  ) async {
    widget.onActionStarted?.call(loadingMessage);
    try {
      return await action();
    } catch (e) {
      widget.onActionError?.call(
        'Something went wrong. Please try again.',
        retry,
      );
      return null;
    } finally {
      widget.onActionFinished?.call();
    }
  }

  Future<void> _openSearch(BuildContext context) async {
    final result = await _runAction<FoodEntry>(
      'Searching...',
      () => InlineFoodSearchSheet.show(context),
      () {
        if (!mounted) return;
        _openSearch(context);
      },
    );
    if (result != null) {
      await _handleFoodSelected(result);
    }
  }

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final result = await _runAction<FoodEntry>(
      'Opening scanner...',
      () => Navigator.of(context).push(BarcodeScannerScreen.route()),
      () {
        if (!mounted) return;
        _openBarcodeScanner(context);
      },
    );
    if (result != null) {
      await _handleFoodSelected(result);
    }
  }

  Future<void> _openCustomFood(BuildContext context) async {
    final result = await _runAction<FoodEntry>(
      'Opening food editor...',
      () => Navigator.of(context).push(FoodEntryScreen.route()),
      () {
        if (!mounted) return;
        _openCustomFood(context);
      },
    );
    if (result != null) {
      await _handleFoodSelected(result);
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
