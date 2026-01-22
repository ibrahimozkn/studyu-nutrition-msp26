import 'package:flutter/material.dart';

class NaturalLanguageInputWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool autofocus;

  const NaturalLanguageInputWidget({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.autofocus = false,
  });

  @override
  State<NaturalLanguageInputWidget> createState() =>
      _NaturalLanguageInputWidgetState();
}

class _NaturalLanguageInputWidgetState
    extends State<NaturalLanguageInputWidget> {
  late final TextEditingController _internalController;
  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.done,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: 'e.g., Oatmeal with berries and coffee',
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
