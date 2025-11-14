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
  /// On desktop, it appears as a modal dialog.
  /// On mobile, it appears as a bottom sheet.
  ///
  /// Returns the result from the dialog/bottom sheet when closed.
  static Future<T?> showResponsiveDialog<T>({
    required BuildContext context,
    required Widget child,
    DialogSize size = DialogSize.medium,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    ResponsiveDialogConfig? config,
  }) async {
    final effectiveConfig = config ?? _config;
    final isDesktop = effectiveConfig.isDesktopScreen(context);
    final screenSize = MediaQuery.sizeOf(context);

    if (isDesktop) {
      // Show as modal dialog on desktop
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          // For minimum size, use default Dialog behavior (content-based sizing)
          if (size == DialogSize.min) {
            return Dialog(child: child); // Maintain dialog semantics while using default sizing
          }

          // For other sizes, use ratio-based sizing
          final dialogHeight = screenSize.height * size.desktopHeightRatio;
          final dialogWidth = screenSize.width * size.desktopWidthRatio;
          final maxWidth = size.maxDesktopWidth;

          return Dialog(
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
      // Show as bottom sheet on mobile
      // For minimum size, use keyboard-aware modal dialog instead of bottom sheet
      if (size == DialogSize.min) {
        return showDialog<T>(
          context: context,
          barrierDismissible: isDismissible,
          builder: (BuildContext context) {
            return Center(
              child: SingleChildScrollView(
                child: child,
              ),
            );
          },
        );
      }

      // For other sizes, use modal bottom sheet with keyboard awareness
      return showMaterialModalBottomSheet<T>(
        context: context,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useRootNavigator: false,
        // Enable scroll control for better keyboard handling
        expand: false,
        builder: (BuildContext context) {
          final mediaQuery = MediaQuery.of(context);
          final safeAreaBottom = mediaQuery.viewPadding.bottom;
          final screenHeight = mediaQuery.size.height;
          final keyboardHeight = mediaQuery.viewInsets.bottom;

          // Use full screen height for better space utilization
          // The modal_bottom_sheet package handles safe areas and keyboard avoidance automatically
          final availableHeight = screenHeight;
          final maxHeight = availableHeight * size.mobileMaxSizeRatio;
          final initialHeight = availableHeight * size.mobileInitialSizeRatio;

          // Remove the manual keyboard padding since modal_bottom_sheet handles it
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            child: Container(
              // Use flexible initial height that can expand with content
              constraints: BoxConstraints(
                minHeight: keyboardHeight > 0 ? initialHeight * _kKeyboardVisibleHeightShrinkFactor : initialHeight,
                maxHeight: maxHeight,
              ),
              child: Material(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(effectiveConfig.containerBorderRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Flexible wrapper allows content to adapt when keyboard appears
                    Flexible(
                      child: SafeArea(
                        top: false,
                        child: child,
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

  /// Wraps content with appropriate constraints to prevent unbounded height errors
  /// when content contains a Scaffold or similar widget that expects bounded height.
  static Widget _wrapWithConstrainedContent(
    BuildContext context,
    Widget child, {
    bool isScrollable = true,
    double? maxHeight,
    double? maxWidth,
  }) {
    Widget constrainedContent = child;

    // For bottom sheets, we don't need special handling anymore since we're using Flexible
    // Bottom sheet constraints are now handled by the parent Column/Flexible structure

    // For desktop dialogs, use the original constraint-based approach
    if (maxHeight != null || maxWidth != null) {
      constrainedContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? double.infinity,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: child,
      );
    }

    // If scrollable for desktop dialogs
    if (isScrollable && maxHeight != null) {
      constrainedContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: constrainedContent,
      );
    }

    return constrainedContent;
  }
}

/// Legacy function for backward compatibility and simple use cases.
/// Shows a responsive bottom sheet that properly handles keyboard insets.
void showResponsiveBottomSheet(
  BuildContext context, {
  required Widget child,
  ResponsiveDialogConfig? config,
}) {
  // Use the more robust ResponsiveDialogHelper with medium size for standard bottom sheets
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
