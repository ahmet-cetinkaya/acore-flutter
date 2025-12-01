import 'package:flutter/material.dart';

class SwipeToConfirm extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;
  final Color? backgroundColor;
  final Color? sliderColor;
  final Color? iconColor;
  final Color? textColor;
  final double height;

  const SwipeToConfirm({
    super.key,
    required this.text,
    required this.onConfirmed,
    this.backgroundColor,
    this.sliderColor,
    this.iconColor,
    this.textColor,
    this.height = 56.0,
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragValue = 0.0;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isConfirmed) return;

    setState(() {
      _dragValue = (_dragValue + details.delta.dx / (maxWidth - widget.height)).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isConfirmed) return;

    if (_dragValue > 0.9) {
      setState(() {
        _dragValue = 1.0;
        _isConfirmed = true;
      });
      widget.onConfirmed();
    } else {
      _controller.value = _dragValue;
      _controller.animateTo(0.0, curve: Curves.easeOut).then((_) {
        setState(() {
          _dragValue = 0.0;
        });
      });
      _controller.addListener(() {
        setState(() {
          _dragValue = _controller.value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final sliderColor = widget.sliderColor ?? theme.colorScheme.primary;
    final iconColor = widget.iconColor ?? theme.colorScheme.onPrimary;
    final textColor = widget.textColor ?? theme.colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final sliderWidth = widget.height;
        final dragWidth = maxWidth - sliderWidth;

        return Container(
          height: widget.height,
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: const StadiumBorder(),
          ),
          child: Stack(
            children: [
              // Text
              Center(
                child: Opacity(
                  opacity: 1.0 - _dragValue,
                  child: Text(
                    widget.text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Slider Background (Fill)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: sliderWidth + (dragWidth * _dragValue),
                  height: widget.height,
                  decoration: ShapeDecoration(
                    color: sliderColor.withValues(alpha: 0.2),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),

              // Slider Button
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(dragWidth * _dragValue, 0),
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxWidth),
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: sliderWidth,
                      height: widget.height,
                      decoration: ShapeDecoration(
                        color: sliderColor,
                        shape: const StadiumBorder(),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
