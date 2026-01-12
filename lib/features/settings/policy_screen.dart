import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class PolicyScreen extends StatelessWidget {
  final String fileName; // e.g. "terms.md"
  final String title;

  const PolicyScreen({
    super.key,
    required this.fileName,
    required this.title,
  });

  Future<String> _loadAsset(BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode;
    // Try to load localized asset, fallback to 'en'
    // Actually simplicity: first try 'assets/docs/$locale/$fileName'
    // If error, try 'assets/docs/en/$fileName'
    
    final path = 'assets/docs/$locale/$fileName';
    debugPrint('Attempting to load: $path');
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      debugPrint('Failed to load $path: $e');
      // Fallback
      final fallbackPath = 'assets/docs/en/$fileName';
      debugPrint('Attempting fallback: $fallbackPath');
      return await rootBundle.loadString(fallbackPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String>(
        future: _loadAsset(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("Content not found.", style: TextStyle(color: Colors.white)),
            );
          }

          return Markdown(
            data: snapshot.data!,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              p: const TextStyle(color: Colors.white70, fontSize: 16),
              listBullet: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
