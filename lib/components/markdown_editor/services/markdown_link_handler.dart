import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:developer' as developer;
import '../models/markdown_editor_interfaces.dart';

/// Default implementation of markdown link handling
class MarkdownLinkHandler implements IMarkdownLinkHandler {
  @override
  void handleLinkTap(String text, String? href, String title) {
    if (href != null && href.isNotEmpty) {
      launchUrl(href);
    }
  }

  @override
  Future<void> launchUrl(String url) async {
    try {
      if (url.isEmpty) return;

      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
      } else {
        developer.log('Could not launch $url');
      }
    } catch (e) {
      developer.log('Error launching URL $url: $e');
    }
  }
}
