import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

void main() async {
  // Isarなどの初期化は後ほどここに追加します
  WidgetsFlutterBinding.ensureInitialized();
  


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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ja'), // Japanese
        Locale('es'), // Spanish
      ],
      home: const StartupGate(child: DashboardScreen()),
    );
  }
}

class StartupGate extends StatefulWidget {
  final Widget child;
  const StartupGate({super.key, required this.child});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTrackingAndAds();
    });
  }

  Future<void> _initTrackingAndAds() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // App Store Review対策: 最初のフレーム描画後にATTを呼ぶ
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await MobileAds.instance.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
