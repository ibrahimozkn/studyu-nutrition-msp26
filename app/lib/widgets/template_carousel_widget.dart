import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/widgets/gatsot_selector.dart';
import 'package:studyu_core/core.dart';

class TemplateCarouselWidget extends StatefulWidget {
  final String userId;
  final String? label;
  final TemplateFilter filter;
  final void Function(List<FoodEntry> foods) onAddFoods;
  final void Function(dynamic template)? onTemplateTap;

  const TemplateCarouselWidget({
    required this.userId,
    required this.onAddFoods,
    this.label,
    this.filter = TemplateFilter.all,
    this.onTemplateTap,
    super.key,
  });

  @override
  State<TemplateCarouselWidget> createState() =>
      _TemplateCarouselWidgetState();
}

class _TemplateCarouselWidgetState extends State<TemplateCarouselWidget> {
  late final TemplateViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TemplateViewModel(userId: widget.userId);
    if (widget.filter != TemplateFilter.all) {
      _viewModel.setFilter(widget.filter);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TemplateViewModel>(
        builder: (context, viewModel, _) {
          final l10n = AppLocalizations.of(context)!;

          if (viewModel.isLoading) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final templates = viewModel.filteredTemplates;
          if (templates.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return GatsotSelector<dynamic>(
            items: templates,
            selectedValue: null,
            onSelected: widget.onTemplateTap != null
                ? (template) => widget.onTemplateTap!(template)
                : (_) {},
            label: widget.label,
            itemBuilder: (context, template, isSelected) {
              return _buildTemplateCard(
                context,
                template,
                viewModel,
                l10n,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        l10n.no_templates_saved,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    dynamic template,
    TemplateViewModel viewModel,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    String name;
    int foodCount;

    if (template is SavedMealTemplate) {
      name = template.name;
      foodCount = template.prototypes.length;
    } else if (template is SavedFoodTemplate) {
      name = template.name;
      foodCount = 1;
    } else {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.items_count(foodCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildQuickAddButton(context, template, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    dynamic template,
    TemplateViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleAddTemplate(template, viewModel),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _handleAddTemplate(dynamic template, TemplateViewModel viewModel) {
    if (template is SavedMealTemplate) {
      final meal = viewModel.applyMealTemplate(template);
      widget.onAddFoods(meal.foods);
    } else if (template is SavedFoodTemplate) {
      final food = viewModel.applyFoodTemplate(template);
      widget.onAddFoods([food]);
    }
  }
}
