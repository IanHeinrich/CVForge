import 'dart:async';

import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

/// A text field that pushes edits to the ViewModel debounced while typing,
/// and immediately on losing focus — per CLAUDE.md's convention that
/// controllers live in the View and carry text, while every actual
/// mutation decision lives in the ViewModel via [onChanged].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.autofocus = false,
    this.errorText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final bool autofocus;

  /// Rendered by the underlying `TextField`'s own `InputDecoration.error`
  /// styling — null (the default) shows nothing. The rule this exists to
  /// serve: a rejected edit must either show an error via this, or be
  /// impossible to make (e.g. a dropdown over a closed set) — never
  /// silently discarded.
  final String? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  Timer? _debounce;

  /// The value most recently handed to [AppTextField.onChanged]. Both blur
  /// and dispose flush, and every editor panel in the app is rebuilt
  /// constantly, so without this a field that was merely focused and left
  /// alone would still push a write through the ViewModel to storage.
  late String _lastSent = widget.initialValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync from outside when unfocused — otherwise a reactive
    // rebuild while the user is mid-keystroke would fight their typing.
    if (widget.initialValue != _controller.text && !_focusNode.hasFocus) {
      _controller.text = widget.initialValue;
      _lastSent = widget.initialValue;
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _flush();
  }

  void _handleChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _send(value));
  }

  /// Delivers whatever is in the field now, cancelling any queued debounce.
  /// Losing focus and being disposed both mean "no more keystrokes are
  /// coming", and a still-queued timer would otherwise drop the last edit
  /// — e.g. the panel closing right after a final keystroke.
  void _flush() {
    _debounce?.cancel();
    _debounce = null;
    _send(_controller.text);
  }

  void _send(String value) {
    if (value == _lastSent) return;
    _lastSent = value;
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _flush();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      onChanged: _handleChanged,
      style: const TextStyle(color: kcWhite),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: kcMediumGrey),
        errorText: widget.errorText,
      ),
    );
  }
}
