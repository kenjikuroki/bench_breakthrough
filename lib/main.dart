import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  // Isarなどの初期化は後ほどここに追加します
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid || Platform.isIOS) {
    await MobileAds.instance.initialize();
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bench Breakthrough',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // 定義したダークテーマを適用
      home: const DashboardScreen(),
    );
  }
}
