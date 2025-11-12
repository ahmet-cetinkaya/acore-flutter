import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'numeric_input_translation_keys.dart';

class NumericInput extends StatefulWidget {
  final int initialValue;
  final int? minValue;
  final int? maxValue;
  final int incrementValue;
  final int decrementValue;
  final void Function(int) onValueChanged;
  final String? valueSuffix;
  final double? iconSize;
  final Color? iconColor;
  final Map<NumericInputTranslationKey, String>? translations;

  const NumericInput({
    super.key,
    this.initialValue = 0,
    this.minValue,
    this.maxValue,
    this.incrementValue = 1,
    this.decrementValue = 1,
    required this.onValueChanged,
    this.valueSuffix,
    this.iconSize,
    this.iconColor,
    this.translations,
  });

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  late TextEditingController _controller;
  late FocusNode _containerFocusNode;
  late FocusNode _textFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
    _containerFocusNode = FocusNode();
    _textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _containerFocusNode.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  String _getTranslation(NumericInputTranslationKey key, String fallback) {
    return widget.translations?[key] ?? fallback;
  }

  void _increment() {
    int? value = int.tryParse(_controller.text);
    if (value == null) return;

    int nextValue = value + widget.incrementValue;
    final maxValue = widget.maxValue;
    if (maxValue != null && nextValue > maxValue) {
      nextValue = maxValue;
    }

    if (mounted) {
      setState(() {
        _controller.value = TextEditingValue(text: nextValue.toString());
      });
    }
    _triggerHapticFeedback();
    widget.onValueChanged(nextValue);
  }

  void _decrement() {
    int? value = int.tryParse(_controller.text);
    if (value == null) return;

    int nextValue = value - widget.decrementValue;
    final minValue = widget.minValue ?? 0; // Default minimum is 0
    if (nextValue < minValue) {
      nextValue = minValue;
    }

    if (mounted) {
      setState(() {
        _controller.value = TextEditingValue(text: nextValue.toString());
      });
    }
    _triggerHapticFeedback();
    widget.onValueChanged(nextValue);
  }

  void _onValueChanged(String value) {
    int? newValue = int.tryParse(value);
    if (newValue == null) return;

    final minValue = widget.minValue ?? 0; // Default minimum is 0
    final maxValue = widget.maxValue;

    // Enforce minimum value constraint
    if (newValue < minValue) {
      setState(() {
        _controller.value = TextEditingValue(
          text: minValue.toString(),
          selection: TextSelection.fromPosition(
            TextPosition(offset: minValue.toString().length),
          ),
        );
      });
      newValue = minValue;
    }

    // Enforce maximum value constraint
    if (maxValue != null && newValue > maxValue) {
      setState(() {
        _controller.value = TextEditingValue(
          text: maxValue.toString(),
          selection: TextSelection.fromPosition(
            TextPosition(offset: maxValue.toString().length),
          ),
        );
      });
      newValue = maxValue;
    }

    widget.onValueChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = int.tryParse(_controller.text) ?? 0;
    final minValue = widget.minValue ?? 0; // Default minimum is 0
    final maxValue = widget.maxValue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: _getTranslation(
            NumericInputTranslationKey.decrementButtonLabel,
            'Decrement button',
          ),
          hint: currentValue > minValue
              ? _getTranslation(NumericInputTranslationKey.decrementHint, 'Decreases the current value')
              : _getTranslation(NumericInputTranslationKey.atMinimumValue, 'Already at minimum value'),
          child: IconButton(
            icon: Icon(
              Icons.remove,
              size: widget.iconSize,
              color: widget.iconColor,
            ),
            onPressed: currentValue > minValue ? _decrement : null,
            tooltip: _getTranslation(NumericInputTranslationKey.decrementTooltip, 'Decrease'),
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
            ),
          ),
        ),
        Semantics(
          textField: true,
          label: _getTranslation(NumericInputTranslationKey.textFieldLabel, 'Numeric input'),
          hint: widget.valueSuffix != null
              ? _getTranslation(
                  NumericInputTranslationKey.textFieldHint,
                  'Enter a number between $minValue and ${maxValue ?? 'unlimited'} ${widget.valueSuffix}',
                )
              : _getTranslation(
                  NumericInputTranslationKey.textFieldHint,
                  'Enter a number between $minValue and ${maxValue ?? 'unlimited'}',
                ),
          value: _controller.text,
          child: SizedBox(
            width: (_controller.text.length * 12.0).clamp(50.0, 100.0), // Minimum 50, maximum 100 width
            child: Focus(
              focusNode: _containerFocusNode,
              onKeyEvent: (node, event) {
                // Handle keyboard navigation
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    if (currentValue < (maxValue ?? double.infinity)) {
                      _increment();
                      return KeyEventResult.handled;
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    if (currentValue > minValue) {
                      _decrement();
                      return KeyEventResult.handled;
                    }
                  }
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _controller,
                focusNode: _textFieldFocusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')), // Only allow digits
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: _onValueChanged,
              ),
            ),
          ),
        ),
        if (widget.valueSuffix != null)
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                widget.valueSuffix!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1,
                    ),
              ),
            ),
          ),
        Semantics(
          button: true,
          label: _getTranslation(
            NumericInputTranslationKey.incrementButtonLabel,
            'Increment button',
          ),
          hint: maxValue == null || currentValue < maxValue
              ? _getTranslation(NumericInputTranslationKey.incrementHint, 'Increases the current value')
              : _getTranslation(NumericInputTranslationKey.atMaximumValue, 'Already at maximum value'),
          child: IconButton(
            icon: Icon(
              Icons.add,
              size: widget.iconSize,
              color: widget.iconColor,
            ),
            onPressed: maxValue == null || currentValue < maxValue ? _increment : null,
            tooltip: _getTranslation(NumericInputTranslationKey.incrementTooltip, 'Increase'),
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
