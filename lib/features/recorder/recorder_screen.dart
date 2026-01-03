import 'dart:async';
import 'dart:io';
import 'dart:ui'; // FontFeatureのため
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bench_breakthrough/core/theme/app_colors.dart';
import 'package:bench_breakthrough/core/utils/one_rm_calculator.dart';
import '../../data/local/isar_service.dart';
import '../../data/models/workout_log.dart';
import '../settings/settings_provider.dart'; // Settings
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';


class RecorderScreen extends ConsumerStatefulWidget {
  final double initialWeight;
  const RecorderScreen({super.key, required this.initialWeight});

  @override
  ConsumerState<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends ConsumerState<RecorderScreen> {
  // 初期値
  late double _selectedWeight;
  int _selectedReps = 8;
  
  late List<double> _weightOptions;
  late bool _isLbs;
  bool _initialized = false;
    
  // 回数の選択肢 (1回 ~ 30回)
  final List<int> _repOptions = List.generate(30, (index) => index + 1);

  // セッション履歴 (今日の記録)
  final List<WorkoutLog> _sessionLogs = [];

  // タイマー関連
  Timer? _timer;
  static const int _defaultIntervalSeconds = 180; // 3分
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  // 広告関連
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  
  // テスト用ID (本番時は差し替えが必要)
  // Android Test ID
  // TODO: Replace with your real Android Ad Unit ID (ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy)
  final String _adUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  // iOS Test ID
  // TODO: Replace with your real iOS Ad Unit ID (ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy)
  final String _adUnitIdIos = 'ca-app-pub-3940256099942544/4411468910';

  String get _adUnitId {
    if (Platform.isAndroid) return _adUnitIdAndroid;
    if (Platform.isIOS) return _adUnitIdIos;
    return ''; // Unsupported platform
  }

  @override
  void initState() {
    super.initState();
    // モバイルのみ広告ロード (画面生成と同時に開始)
    if (Platform.isAndroid || Platform.isIOS) {
      _loadInterstitialAd();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // 設定を読み込み
      _isLbs = ref.read(isLbsProvider);

      if (_isLbs) {
        // Lbs Mode: 45lbs ~ 495lbs (5lbs step)
        _weightOptions = List.generate(91, (index) => 45.0 + (index * 5.0));
      } else {
        // Kg Mode: 20kg ~ 200kg (0.25kg step)
        _weightOptions = List.generate(721, (index) => 20.0 + (index * 0.25));
      }

      // 初期選択値の決定
      // widget.initialWeightは常にKGで来る
      final double initKg = widget.initialWeight > 0 ? widget.initialWeight : 60.0;
      
      // 現在の単位系に合わせて変換
      final double targetVal = _isLbs ? convertWeightToDisplay(initKg, true) : initKg;

      // 最も近い選択肢を選ぶ
      _selectedWeight = _weightOptions.reduce((a, b) => 
        (a - targetVal).abs() < (b - targetVal).abs() ? a : b);

      _loadTodaysSession();
      _loadTodaysSession();
      // 広告ロードはinitStateに移動済み
      _initialized = true;
    }
  }

  // 広告ロード処理
  void _loadInterstitialAd() {
    if (_adUnitId.isEmpty) return;
    
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('$ad loaded');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error.');
          _interstitialAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  // 終了ボタン処理
  void _finishWorkout() {
    // モバイル以外または広告IDがない場合は即終了
    if (!(Platform.isAndroid || Platform.isIOS)) {
      Navigator.pop(context);
      return;
    }

    final isPremium = ref.read(isPremiumProvider).value ?? false;

    // プレミアム会員、または広告がロードされていない場合はそのまま終了
    if (isPremium || !_isAdLoaded || _interstitialAd == null) {
      Navigator.pop(context);
      return;
    }

    // 広告表示
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // 広告を閉じたら画面も閉じる
        if (mounted) Navigator.pop(context);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        // 失敗しても画面は閉じる
        if (mounted) Navigator.pop(context);
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // 使い捨てなのでnullにする
  }

  Future<void> _loadTodaysSession() async {
    final service = IsarService();
    final logs = await service.getTodaysWorkouts();
    if (mounted) {
      setState(() {
        _sessionLogs.clear();
        _sessionLogs.addAll(logs);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // タイマー開始処理
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _defaultIntervalSeconds;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
    });
  }

  String get _timerString {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveLog() async {
    // DB保存用にKGに変換
    // _selectedWeightは現在の単位系の値（lbsならlbs）
    final double weightInKg = convertWeightToStorage(_selectedWeight, _isLbs);

    // 1RM計算 (保存用)
    final double estMaxKg = OneRmCalculator.calculate(weightInKg, _selectedReps);

    final service = IsarService();
    final newLog = WorkoutLog()
      ..date = DateTime.now()
      ..weight = weightInKg // 常にKGで保存
      ..reps = _selectedReps
      ..estimated1RM = estMaxKg; // 常にKGで保存

    // 1. DB保存
    await service.saveWorkout(newLog);

    // 2. セッションログに追加
    if (mounted) {
      setState(() {
        _sessionLogs.insert(0, newLog); // 最新を上に
      });
      // 3. タイマー開始
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    // リアルタイムで1RMを計算 (表示用)
    final currentEstMax = OneRmCalculator.calculate(_selectedWeight, _selectedReps);
    final unitLabel = _isLbs ? 'lbs' : 'kg';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false, // 戻るボタンを消す
        title: const Text('LOG WORKOUT', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          // 終了ボタン
          TextButton(
            onPressed: _finishWorkout, // 広告チェック処理へ
            child: Text(AppLocalizations.of(context)!.finish, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- タイマー表示 ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: _isTimerRunning ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: _isTimerRunning ? Border.all(color: AppColors.accent) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, color: _isTimerRunning ? AppColors.accent : AppColors.textSecondary),
                    const Gap(8),
                    Text(
                      _timerString,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isTimerRunning ? AppColors.accent : AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()], // 等幅数字
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(10),

            // --- リアルタイム計算結果 ---
            Column(
              children: [
                Text(AppLocalizations.of(context)!.estimated1rm, 
                  style: const TextStyle(color: AppColors.textSecondary, letterSpacing: 1.5)),
                Text(
                  '${currentEstMax.toStringAsFixed(1)} $unitLabel',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 56, 
                  ),
                ),
              ],
            ),

            const Gap(20),

            // --- 入力エリア (ドラムロール) ---
            SizedBox(
              height: 200, // 高さを少し詰める
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // 重量
                    Expanded(
                      child: _buildPicker<double>(
                        label: AppLocalizations.of(context)!.weight,
                        unit: unitLabel,
                        options: _weightOptions,
                        selectedValue: _selectedWeight,
                        onChanged: (value) => setState(() => _selectedWeight = value),
                      ),
                    ),
                    const Gap(16),
                    // 回数
                    Expanded(
                      child: _buildPicker<int>(
                        label: AppLocalizations.of(context)!.reps,
                        unit: 'reps',
                        options: _repOptions,
                        selectedValue: _selectedReps,
                        onChanged: (value) => setState(() => _selectedReps = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(24),

            // --- 保存ボタン ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveLog,
                  child: Text(AppLocalizations.of(context)!.saveSet),
                ),
              ),
            ),

            const Gap(24),

            // --- セッション履歴 ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Text(AppLocalizations.of(context)!.todaysSets, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const Gap(8),
                    Expanded(
                      child: _sessionLogs.isEmpty
                          ? Center(child: Text(AppLocalizations.of(context)!.noSetsYet, style: const TextStyle(color: AppColors.textSecondary)))
                          : ListView.builder(
                              itemCount: _sessionLogs.length,
                              itemBuilder: (context, index) {
                                final log = _sessionLogs[index];
                                final setNumber = _sessionLogs.length - index;

                                // 表示用に変換
                                final double displayW = convertWeightToDisplay(log.weight, _isLbs);
                                final double display1RM = convertWeightToDisplay(log.estimated1RM ?? 0, _isLbs);

                                return Dismissible(
                                  key: Key(log.id.toString()), // IDをキーにする
                                  direction: DismissDirection.endToStart, // 右から左へスワイプ
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: AppColors.error,
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (direction) async {
                                    // 1. リストから削除 (画面更新)
                                    setState(() {
                                      _sessionLogs.removeAt(index);
                                    });

                                    // 2. DBから削除
                                    final service = IsarService();
                                    await service.deleteLog(log.id);

                                    // 3. スナックバーで通知
                                    if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(AppLocalizations.of(context)!.setDeleted)),
                                        );
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      radius: 12,
                                      child: Text('$setNumber', style: const TextStyle(fontSize: 12)),
                                    ),
                                    title: Text(
                                      '${formatWeight(displayW)} $unitLabel x ${log.reps ?? 1} reps',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Text(
                                      '1RM: ${display1RM.toStringAsFixed(1)}',
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker<T>({
    required String label,
    required String unit,
    required List<T> options,
    required T selectedValue,
    required ValueChanged<T> onChanged,
  }) {
    // 初期位置の計算
    int initialIndex = options.indexOf(selectedValue);
    if (initialIndex == -1) initialIndex = 0; // 万が一見つからない場合

    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const Gap(8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: initialIndex),
              itemExtent: 40, // 1行の高さ
              onSelectedItemChanged: (index) {
                onChanged(options[index]);
              },
              children: options.map((option) => Center(
                child: Text(
                  // 小数点の処理はformatWeightではなくここで簡易的にやってもいいが、
                  // optionがdoubleならtoStringAsFixed(2)等で出す
                  T == double 
                      ? formatWeight(option as double) + " $unit"
                      : '$option $unit',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
