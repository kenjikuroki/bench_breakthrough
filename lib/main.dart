import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_colors.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/subscription/purchase_service.dart';

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


class StartupGate extends ConsumerStatefulWidget {
  final Widget child;
  const StartupGate({super.key, required this.child});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 画面描画後に初期化開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    // 1. 課金サービスの初期化 (ストリーム監視開始)
    ref.read(purchaseServiceProvider);

    // 2. ATT要求 (iOS)
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // App Store Review対策: 最初のフレーム描画後にATTを呼ぶ
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    // 3. 広告初期化
    if (Platform.isAndroid || Platform.isIOS) {
      await MobileAds.instance.initialize();
    }

    // Isarの初期化などはmain()前に完了している想定だが、
    // ここで何か待つ必要があればawaitする

    // 初期化完了・最低でも少し待つ（スプラッシュを感じさせるため）
    // await Future.delayed(const Duration(seconds: 1)); 

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent, // アクセントカラーを使用
          ),
        ),
      );
    }
    return widget.child;
  }
}
