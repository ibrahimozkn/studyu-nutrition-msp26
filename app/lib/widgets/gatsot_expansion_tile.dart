import 'package:flutter/material.dart';

class GatsotExpansionTile extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? icon;

  const GatsotExpansionTile({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.icon,
  });

  @override
  State<GatsotExpansionTile> createState() => _GatsotExpansionTileState();
}

class _GatsotExpansionTileState extends State<GatsotExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.child to remove it from the tree!
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final closedTitleColor = theme.textTheme.titleMedium?.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: _isExpanded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isExpanded
                          ? theme.colorScheme.primary
                          : closedTitleColor,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: _isExpanded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller.view,
          builder: (BuildContext context, Widget? child) {
            return ClipRect(
              child: Align(heightFactor: _heightFactor.value, child: child),
            );
          },
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: widget.child,
                )
              : null,
        ),
        if (!_isExpanded)
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
      ],
    );
  }
}
