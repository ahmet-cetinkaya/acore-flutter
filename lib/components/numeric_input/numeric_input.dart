import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'numeric_input_translation_keys.dart';

enum NumericInputStyle {
  minimal,
  contained,
}

class NumericInput extends StatefulWidget {
  final int initialValue;
  final int? value;
  final int? minValue;
  final int? maxValue;
  final int incrementValue;
  final int decrementValue;
  final void Function(int) onValueChanged;
  final String? valueSuffix;
  final double? iconSize;
  final Color? iconColor;
  final Map<NumericInputTranslationKey, String>? translations;
  final NumericInputStyle style;
  final double? textFieldWidth;

  const NumericInput({
    super.key,
    this.initialValue = 0,
    this.value,
    this.minValue,
    this.maxValue,
    this.incrementValue = 1,
    this.decrementValue = 1,
    required this.onValueChanged,
    this.valueSuffix,
    this.iconSize,
    this.iconColor,
    this.translations,
    this.style = NumericInputStyle.minimal,
    this.textFieldWidth,
  });

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final startValue = widget.value ?? widget.initialValue;
    _controller = TextEditingController(text: startValue.toString());
  }

  /// Calculate optimal text field width based on text metrics
  double _measureTextFieldWidth(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    final suffix = widget.valueSuffix ?? '';

    // Use a representative maximum-length numeric string (e.g., for 3-4 digit input)
    const sample = '0000';

    final painter = TextPainter(
      text: TextSpan(text: '$sample$suffix', style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Add some horizontal padding so the text doesn't touch edges
    const horizontalPadding = 16.0;

    return painter.width + horizontalPadding;
  }

  @override
  void didUpdateWidget(NumericInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != oldWidget.value) {
      final currentValue = int.tryParse(_controller.text) ?? 0;
      if (currentValue != widget.value) {
        _controller.text = widget.value!.toString();
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
    final minValue = widget.minValue ?? 0;
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

    final minValue = widget.minValue ?? 0;
    final maxValue = widget.maxValue;

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
    final minValue = widget.minValue ?? 0;
    final maxValue = widget.maxValue;

    Widget content = Row(
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
          child: widget.style == NumericInputStyle.contained
              ? IconButton.filledTonal(
                  icon: Icon(
                    Icons.remove,
                    size: widget.iconSize,
                    color: widget.iconColor,
                  ),
                  onPressed: currentValue > minValue ? _decrement : null,
                  tooltip: _getTranslation(NumericInputTranslationKey.decrementTooltip, 'Decrease'),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                )
              : IconButton(
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
        if (widget.style == NumericInputStyle.contained)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: widget.textFieldWidth ?? _measureTextFieldWidth(context),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  isDense: true,
                  hintText: widget.valueSuffix != null ? '0 ${widget.valueSuffix}' : '0',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  suffixText: widget.valueSuffix,
                  suffixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                onChanged: _onValueChanged,
              ),
            ),
          )
        else ...[
          SizedBox(
            width: (_controller.text.length * 12.0).clamp(50.0, 100.0),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
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
        ],
        Semantics(
          button: true,
          label: _getTranslation(
            NumericInputTranslationKey.incrementButtonLabel,
            'Increment button',
          ),
          hint: maxValue == null || currentValue < maxValue
              ? _getTranslation(NumericInputTranslationKey.incrementHint, 'Increases the current value')
              : _getTranslation(NumericInputTranslationKey.atMaximumValue, 'Already at maximum value'),
          child: widget.style == NumericInputStyle.contained
              ? IconButton.filledTonal(
                  icon: Icon(
                    Icons.add,
                    size: widget.iconSize,
                    color: widget.iconColor,
                  ),
                  onPressed: maxValue == null || currentValue < maxValue ? _increment : null,
                  tooltip: _getTranslation(NumericInputTranslationKey.incrementTooltip, 'Increase'),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                )
              : IconButton(
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

    if (widget.style == NumericInputStyle.contained) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: content,
      );
    }

    return content;
  }
}
