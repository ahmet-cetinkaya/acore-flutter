import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Error level for categorizing different types of errors
enum DatePickerErrorLevel {
  warning, // Minor issues that don't prevent functionality
  error, // Errors that affect functionality but don't crash
  critical, // Critical errors that may cause crashes
}

/// Error information for date picker components
class DatePickerError {
  final String error;
  final StackTrace? stackTrace;
  final DatePickerErrorLevel level;
  final String component;
  final DateTime timestamp;
  final String? userFriendlyMessage;

  DatePickerError({
    required this.error,
    required this.level,
    required this.component,
    this.stackTrace,
    this.userFriendlyMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'DatePickerError(component: $component, level: $level, error: $error, timestamp: $timestamp)';
  }
}

/// Error callback function type
typedef DatePickerErrorHandler = void Function(DatePickerError error);

/// Error boundary widget for date picker components
///
/// This widget catches errors in its child widgets and provides graceful fallbacks,
/// error reporting, and user-friendly error messages. It follows Flutter best practices
/// for error handling and provides comprehensive error information for debugging.
class DatePickerErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? errorWidget;
  final DatePickerErrorHandler? onError;
  final DatePickerErrorHandler? onWarning;
  final bool enableLogging;
  final String componentId;
  final Map<String, dynamic>? context;

  const DatePickerErrorBoundary({
    super.key,
    required this.child,
    this.errorWidget,
    this.onError,
    this.onWarning,
    this.enableLogging = true,
    required this.componentId,
    this.context,
  });

  @override
  State<DatePickerErrorBoundary> createState() => _DatePickerErrorBoundaryState();
}

class _DatePickerErrorBoundaryState extends State<DatePickerErrorBoundary> {
  Object? _lastError;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableLogging && kDebugMode) {
      debugPrint('DatePickerErrorBoundary: Initialized for component ${widget.componentId}');
    }
  }

  void _handleError(Object error, StackTrace stackTrace, {DatePickerErrorLevel level = DatePickerErrorLevel.error}) {
    setState(() {
      _hasError = true;
      _lastError = error;
    });

    final datePickerError = DatePickerError(
      error: error.toString(),
      stackTrace: stackTrace,
      level: level,
      component: widget.componentId,
      userFriendlyMessage: _getUserFriendlyMessage(error, level),
    );

    if (widget.enableLogging) {
      _logError(datePickerError);
    }

    // Call appropriate error handler
    if (level == DatePickerErrorLevel.warning && widget.onWarning != null) {
      widget.onWarning!(datePickerError);
    } else if (level == DatePickerErrorLevel.error && widget.onError != null) {
      widget.onError!(datePickerError);
    } else if (level == DatePickerErrorLevel.critical && widget.onError != null) {
      widget.onError!(datePickerError);
    }
  }

  String _getUserFriendlyMessage(Object error, DatePickerErrorLevel level) {
    // Convert technical errors to user-friendly messages
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('range') || errorString.contains('bounds')) {
      return 'The selected date is out of range. Please choose a different date.';
    } else if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Date format is invalid. Please try again.';
    } else if (errorString.contains('argument') || errorString.contains('null')) {
      return 'Invalid input provided. Please check your selection.';
    } else if (errorString.contains('state') || errorString.contains('disposed')) {
      return 'Component is no longer available. Please try again.';
    }

    switch (level) {
      case DatePickerErrorLevel.warning:
        return 'There was a minor issue, but you can continue using the date picker.';
      case DatePickerErrorLevel.error:
        return 'An error occurred. The date picker may not work as expected.';
      case DatePickerErrorLevel.critical:
        return 'A critical error occurred. Please refresh and try again.';
    }
  }

  void _logError(DatePickerError error) {
    if (kDebugMode) {
      debugPrint('=== DatePicker Error ===');
      debugPrint('Component: ${error.component}');
      debugPrint('Level: ${error.level}');
      debugPrint('Error: ${error.error}');
      debugPrint('User Message: ${error.userFriendlyMessage}');
      debugPrint('Timestamp: ${error.timestamp}');
      if (error.stackTrace != null) {
        debugPrint('Stack Trace: ${error.stackTrace}');
      }
      if (widget.context != null) {
        debugPrint('Context: ${widget.context}');
      }
      debugPrint('========================');
    }

    // In release mode, you might want to send this to a crash reporting service
    if (!kDebugMode && error.level == DatePickerErrorLevel.critical) {
      debugPrint('Critical error in production: ${error.component} - ${error.error}');
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _lastError = null;
    });
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Date Picker Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getUserFriendlyMessage(_lastError!, DatePickerErrorLevel.error),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_lastError != null && kDebugMode) ...[
            ExpansionTile(
              title: Text(
                'Technical Details',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              tilePadding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _lastError.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  // Dismiss the error boundary and show minimal fallback
                  setState(() {
                    _hasError = false;
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Dismiss'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalFallback() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Date picker unavailable',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    // Wrap child with additional error handling for runtime errors
    try {
      return widget.child;
    } catch (error, stackTrace) {
      _handleError(error, stackTrace, level: DatePickerErrorLevel.error);
      return _buildMinimalFallback();
    }
  }

  @override
  void dispose() {
    if (widget.enableLogging && kDebugMode) {
      debugPrint('DatePickerErrorBoundary: Disposed for component ${widget.componentId}');
    }
    super.dispose();
  }
}

/// Utility widget to easily wrap date picker components with error boundaries
class SafeDatePicker extends StatelessWidget {
  final Widget child;
  final String componentId;
  final DatePickerErrorHandler? onError;
  final bool enableDetailedErrors;

  const SafeDatePicker({
    super.key,
    required this.child,
    required this.componentId,
    this.onError,
    this.enableDetailedErrors = true,
  });

  @override
  Widget build(BuildContext context) {
    return DatePickerErrorBoundary(
      componentId: componentId,
      onError: onError,
      enableLogging: true,
      errorWidget: enableDetailedErrors ? null : _buildMinimalErrorWidget(context),
      child: child,
    );
  }

  Widget _buildMinimalErrorWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Date picker unavailable',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
