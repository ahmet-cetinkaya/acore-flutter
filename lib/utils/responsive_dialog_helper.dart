import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dialog_size.dart';

/// Keyboard height adjustment factor when keyboard is visible
const double _kKeyboardVisibleHeightShrinkFactor = 0.6;

/// Configuration for responsive dialog theming and breakpoints
class ResponsiveDialogConfig {
  final double screenMediumBreakpoint;
  final double containerBorderRadius;
  final bool Function(BuildContext context) isDesktopScreen;

  const ResponsiveDialogConfig({
    this.screenMediumBreakpoint = 600,
    this.containerBorderRadius = 12,
    this.isDesktopScreen = _defaultIsDesktopScreen,
  });

  static bool _defaultIsDesktopScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 600;
  }
}

/// A utility class for showing detail pages responsively,
/// as modal dialogs on desktop and bottom sheets on mobile.
class ResponsiveDialogHelper {
  static ResponsiveDialogConfig _config = const ResponsiveDialogConfig();

  /// Configure the responsive dialog behavior
  static void configure(ResponsiveDialogConfig config) {
    _config = config;
  }

  /// Get current configuration
  static ResponsiveDialogConfig get config => _config;

  /// Shows a details page responsively.
  static Future<T?> showResponsiveDialog<T>({
    required BuildContext context,
    required Widget child,
    Widget? mobileChild,
    DialogSize size = DialogSize.medium,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    ResponsiveDialogConfig? config,
    Color? backgroundColor,
  }) async {
    final effectiveConfig = config ?? _config;
    final isDesktop = effectiveConfig.isDesktopScreen(context);
    final screenSize = MediaQuery.sizeOf(context);

    if (isDesktop) {
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          if (size == DialogSize.min) {
            return child;
          }
          final dialogHeight = screenSize.height * size.desktopHeightRatio;
          final dialogWidth = screenSize.width * size.desktopWidthRatio;
          final maxWidth = size.maxDesktopWidth;

          return Dialog(
            backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            shadowColor: Theme.of(context).shadowColor,
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveConfig.containerBorderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(effectiveConfig.containerBorderRadius),
              child: SizedBox(
                child: _wrapWithConstrainedContent(
                  context,
                  child,
                  maxHeight: dialogHeight,
                  maxWidth: min(dialogWidth, maxWidth),
                  isScrollable: isScrollable,
                ),
              ),
            ),
          );
        },
      );
    } else {
      final effectiveMobileChild = mobileChild ?? child;
      if (size == DialogSize.min) {
        return showDialog<T>(
          context: context,
          barrierDismissible: isDismissible,
          builder: (BuildContext context) {
            return effectiveMobileChild;
          },
        );
      }
      return showMaterialModalBottomSheet<T>(
        context: context,
        backgroundColor: backgroundColor,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useRootNavigator: false,
        expand: false,
        builder: (BuildContext context) {
          final mediaQuery = MediaQuery.of(context);
          final screenHeight = mediaQuery.size.height;
          final keyboardHeight = mediaQuery.viewInsets.bottom;

          final availableHeight = screenHeight;
          final maxHeight = availableHeight * size.mobileMaxSizeRatio;
          final initialHeight = availableHeight * size.mobileInitialSizeRatio;
          if (mobileChild != null) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: keyboardHeight > 0
                      ? min(initialHeight * _kKeyboardVisibleHeightShrinkFactor, maxHeight)
                      : min(initialHeight, maxHeight),
                  maxHeight: maxHeight,
                ),
                child: Material(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(effectiveConfig.containerBorderRadius),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: effectiveMobileChild,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            child: Container(
              constraints: BoxConstraints(
                minHeight: keyboardHeight > 0
                    ? min(initialHeight * _kKeyboardVisibleHeightShrinkFactor, maxHeight)
                    : min(initialHeight, maxHeight),
                maxHeight: maxHeight,
              ),
              child: Material(
                color: backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(effectiveConfig.containerBorderRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SafeArea(
                        top: false,
                        child: effectiveMobileChild,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  static Widget _wrapWithConstrainedContent(
    BuildContext context,
    Widget child, {
    bool isScrollable = true,
    double? maxHeight,
    double? maxWidth,
  }) {
    Widget constrainedContent = child;
    if (maxHeight != null || maxWidth != null) {
      constrainedContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? double.infinity,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: child,
      );
    }
    if (isScrollable && maxHeight != null) {
      constrainedContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: constrainedContent,
      );
    }

    return constrainedContent;
  }
}

void showResponsiveBottomSheet(
  BuildContext context, {
  required Widget child,
  ResponsiveDialogConfig? config,
}) {
  ResponsiveDialogHelper.showResponsiveDialog<void>(
    context: context,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: child,
    ),
    size: DialogSize.medium,
    isScrollable: true,
    config: config,
  );
}
