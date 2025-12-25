import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bench_breakthrough/core/theme/app_colors.dart';
import 'package:bench_breakthrough/core/utils/one_rm_calculator.dart';
import '../../data/local/isar_service.dart';
import '../../data/models/workout_log.dart';

class RecorderScreen extends StatefulWidget {
  final double initialWeight;
  const RecorderScreen({super.key, required this.initialWeight});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  // 初期値
  late double _selectedWeight;
  int _selectedReps = 8;
  
  // 重量の選択肢 (20kg ~ 200kg, 2.5kg刻み)
  final List<double> _weightOptions = List.generate(
    73, (index) => 20.0 + (index * 2.5));
    
  // 回数の選択肢 (1回 ~ 30回)
  final List<int> _repOptions = List.generate(30, (index) => index + 1);

  // セッション履歴 (今日の記録)
  final List<WorkoutLog> _sessionLogs = [];

  // タイマー関連
  Timer? _timer;
  static const int _defaultIntervalSeconds = 180; // 3分
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    // 渡された初期値を使う（有効な値でなければ60kg）
    if (widget.initialWeight > 0) {
        _selectedWeight = widget.initialWeight;
    } else {
        _selectedWeight = 60.0;
    }
    _loadTodaysSession();
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
    // リアルタイム計算値を参照
    final currentEstMax = OneRmCalculator.calculate(_selectedWeight, _selectedReps);

    final service = IsarService();
    final newLog = WorkoutLog()
      ..date = DateTime.now()
      ..weight = _selectedWeight
      ..reps = _selectedReps
      ..estimated1RM = currentEstMax;

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
    // リアルタイムで1RMを計算
    final currentEstMax = OneRmCalculator.calculate(_selectedWeight, _selectedReps);

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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('FINISH', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- タイマー表示 (稼働中のみ、または常に表示して00:00にするか) ---
            // ここでは常時表示とし、稼働中は目立たせる
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
                const Text('ESTIMATED 1RM', 
                  style: TextStyle(color: AppColors.textSecondary, letterSpacing: 1.5)),
                Text(
                  '${currentEstMax.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 56, // 少し小さく調整
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
                        label: 'WEIGHT',
                        unit: 'kg',
                        options: _weightOptions,
                        selectedValue: _selectedWeight,
                        onChanged: (value) => setState(() => _selectedWeight = value),
                      ),
                    ),
                    const Gap(16),
                    // 回数
                    Expanded(
                      child: _buildPicker<int>(
                        label: 'REPS',
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
                  child: const Text('SAVE SET'),
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
                    const Text("TODAY'S SETS", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const Gap(8),
                    Expanded(
                      child: _sessionLogs.isEmpty
                          ? const Center(child: Text('No sets yet', style: TextStyle(color: AppColors.textSecondary)))
                          : ListView.builder(
                              itemCount: _sessionLogs.length,
                              itemBuilder: (context, index) {
                                final log = _sessionLogs[index];
                                final setNumber = _sessionLogs.length - index;
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
                                        const SnackBar(content: Text('Set deleted')),
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
                                      '${log.weight} kg x ${log.reps} reps',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Text(
                                      '1RM: ${log.estimated1RM.toStringAsFixed(1)}',
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

  // ピッカーを作る共通ウィジェット
  Widget _buildPicker<T>({
    required String label,
    required String unit,
    required List<T> options,
    required T selectedValue,
    required ValueChanged<T> onChanged,
  }) {
    // 初期位置の計算
    final initialIndex = options.indexOf(selectedValue);
    
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
                  '$option $unit',
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
