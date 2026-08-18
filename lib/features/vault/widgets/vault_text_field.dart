import 'dart:async';

import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

/// A text field that pushes edits to the ViewModel debounced while typing,
/// and immediately on losing focus — per CLAUDE.md's convention that
/// controllers live in the View and carry text, while every actual
/// mutation decision lives in the ViewModel via [onChanged].
class VaultTextField extends StatefulWidget {
  const VaultTextField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  State<VaultTextField> createState() => _VaultTextFieldState();
}

class _VaultTextFieldState extends State<VaultTextField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant VaultTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync from outside when unfocused — otherwise a reactive
    // rebuild while the user is mid-keystroke would fight their typing.
    if (widget.initialValue != _controller.text && !_focusNode.hasFocus) {
      _controller.text = widget.initialValue;
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _flush();
  }

  void _handleChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => widget.onChanged(value),
    );
  }

  void _flush() {
    _debounce?.cancel();
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    // A pending debounce means the last keystroke(s) haven't reached
    // onChanged yet — cancelling it outright without flushing would drop
    // them (e.g. the panel closes right after a final edit).
    if (_debounce?.isActive ?? false) widget.onChanged(_controller.text);
    _debounce?.cancel();
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
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: _handleChanged,
      style: const TextStyle(color: kcWhite),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: kcMediumGrey),
      ),
    );
  }
}
