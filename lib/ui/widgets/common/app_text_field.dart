import 'dart:async';

import 'package:cv_forge/ui/common/markup/cv_markup_editing_controller.dart';
import 'package:cv_forge/ui/common/markup/markup_selection.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/widgets/common/markup_toolbar/markup_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.markup = false,
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

  /// Whether this field's text prints on the CV and may therefore carry
  /// inline emphasis.
  ///
  /// Opt-in rather than inferred, and deliberately matched to what the
  /// renderer honours: exactly the fields that would draw a `**` as bold
  /// are the ones that offer a bold button. A contact address or a URL
  /// gets neither, because markup there would reach an ATS as noise or
  /// diverge from a link's own destination. The AI job-description box
  /// gets neither because it is never printed at all.
  final bool markup;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  Timer? _debounce;

  /// Drives the formatting row's reveal. The node is already listened to
  /// for the blur-flush below, so this costs one `setState`, not new
  /// plumbing.
  bool _focused = false;

  /// The value most recently handed to [AppTextField.onChanged]. Both blur
  /// and dispose flush, and every editor panel in the app is rebuilt
  /// constantly, so without this a field that was merely focused and left
  /// alone would still push a write through the ViewModel to storage.
  late String _lastSent = widget.initialValue;

  @override
  void initState() {
    super.initState();
    _controller = widget.markup
        ? CvMarkupEditingController(
            text: widget.initialValue,
            // Resolved in `build`, where a theme is available; seeded
            // here so the very first frame is not unstyled.
            markerColor: const Color(0x00000000),
          )
        : TextEditingController(text: widget.initialValue);
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
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  /// Applies a marker and pushes the result through the same debounce a
  /// keystroke takes, so formatting and typing commit identically.
  void _wrap(String marker) {
    if (wrapSelectionInMarker(_controller, marker)) {
      _handleChanged(_controller.text);
    }
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
    final controller = _controller;
    if (controller is CvMarkupEditingController) {
      // The dimmed-marker colour is a theme value, so it is resolved here
      // rather than in initState.
      controller.markerColor = context.appPalette.placeholder;
    }

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      onChanged: _handleChanged,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: TextStyle(color: context.appPalette.placeholder),
        errorText: widget.errorText,
      ),
    );

    if (!widget.markup) return field;

    return CallbackShortcuts(
      bindings: {
        // Both platforms' habits, since this ships as a web app: Cmd on
        // macOS, Ctrl elsewhere.
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () =>
            _wrap(boldMarker),
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
            _wrap(boldMarker),
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true): () =>
            _wrap(italicMarker),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
            _wrap(italicMarker),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reserved at rest rather than absent, so revealing the row
          // cannot shove the field out from under the cursor that just
          // clicked into it.
          SizedBox(
            height: context.appSpacing.gapMedium,
            child: _focused
                ? MarkupToolbar(controller: _controller)
                : const SizedBox.shrink(),
          ),
          field,
        ],
      ),
    );
  }
}
