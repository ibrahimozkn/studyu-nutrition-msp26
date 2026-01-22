import 'package:flutter/material.dart';

class GatsotSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedValue;
  final void Function(T) onSelected;
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;
  final String? label;

  const GatsotSelector({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.itemBuilder,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: items.map((item) {
              final isSelected = item == selectedValue;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onSelected(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Builder(
                      builder: (context) =>
                          itemBuilder(context, item, isSelected),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
