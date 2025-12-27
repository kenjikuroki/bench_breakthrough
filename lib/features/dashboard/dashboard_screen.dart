import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../recorder/recorder_screen.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_screen.dart';
import '../../data/local/isar_service.dart';
import 'dashboard_provider.dart';
import 'package:bench_breakthrough/features/dashboard/motivation_provider.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';
import 'package:bench_breakthrough/features/diagnosis/diagnosis_screen.dart';


enum HistoryMode {
  chart,
  list,
  diagnosis,
}



class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // プレミアム会員かどうかのフラグ
  bool _isPremiumMember = false; 

  // 画面撮影用のキー
  final GlobalKey _graphKey = GlobalKey();

  // 開閉フラグ
  bool _isHistoryOpen = false;
  // グラフ/リスト/診断の切り替え
  HistoryMode _historyMode = HistoryMode.chart; // デフォルトはグラフモード

  Future<void> _captureAndShare() async {
    if (!_isPremiumMember) {
      _showPremiumDialog("シェア機能");
      return;
    }

    try {
      RenderRepaintBoundary? boundary = _graphKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/bench_pr.png').create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)], 
        text: 'Bench Breakthrough 100kg! #BenchBreakthrough',
      );
      
    } catch (e) {
      debugPrint("エラーが発生しました: $e");
    }
  }

  void _showPremiumDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppLocalizations.of(context)!.premiumFeature, style: const TextStyle(color: Colors.amber)),
        content: Text(
          AppLocalizations.of(context)!.premiumBody,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text("${AppLocalizations.of(context)!.upgrade} (¥480)", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                _isPremiumMember = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.premiumSuccess))
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // データ取得
    final currentMaxAsync = ref.watch(currentMaxProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);

    // 設定値取得 (Unit)
    final isLbs = ref.watch(isLbsProvider);
    final unitString = ref.watch(unitStringProvider);
    final targetWeight = ref.watch(targetWeightProvider); // 100 or 225

    final currentMax = currentMaxAsync.when(
      data: (value) => value,
      loading: () => 0.0,
      error: (err, stack) => 0.0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 他のウィジェットの高さの概算 (ミッション+ヘッダー+ボタン+余白)
            // ヒストリーが開いているときはその分(+320)を考慮
            final double otherWidgetsHeight = _isHistoryOpen ? 720.0 : 400.0;
            // 利用可能な高さから計算、ただし最低300pxは確保
            final double graphHeight = math.max(300.0, constraints.maxHeight - otherWidgetsHeight);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final messageId = ref.watch(motivationMessageIdProvider);
                            // IDから翻訳を取得 (motivation1 ~ motivation21)
                            String message = "";
                            final l10n = AppLocalizations.of(context)!;
                            switch(messageId) {
                      case 1: message = l10n.motivation1; break;
                      case 2: message = l10n.motivation2; break;
                      case 3: message = l10n.motivation3; break;
                      case 4: message = l10n.motivation4; break;
                      case 5: message = l10n.motivation5; break;
                      case 6: message = l10n.motivation6; break;
                      case 7: message = l10n.motivation7; break;
                      case 8: message = l10n.motivation8; break;
                      case 9: message = l10n.motivation9; break;
                      case 10: message = l10n.motivation10; break;
                      case 11: message = l10n.motivation11; break;
                      case 12: message = l10n.motivation12; break;
                      case 13: message = l10n.motivation13; break;
                      case 14: message = l10n.motivation14; break;
                      case 15: message = l10n.motivation15; break;
                      case 16: message = l10n.motivation16; break;
                      case 17: message = l10n.motivation17; break;
                      case 18: message = l10n.motivation18; break;
                      case 19: message = l10n.motivation19; break;
                      case 20: message = l10n.motivation20; break;
                      case 21: message = l10n.motivation21; break;
                      default: message = l10n.motivation1;
                    }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 上左右に余白、下に少し広めの余白
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212121), // ダークグレー背景
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        left: BorderSide(
                          color: Colors.redAccent, // 警告色のライン
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.todaysMission,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.3, // 行間を少し開ける
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ==========================================
              // ヘッダー
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.appTitle.split(' ').first, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        )),
                      Text(AppLocalizations.of(context)!.appTitle.split(' ').last, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          letterSpacing: 2.0,
                        )),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.ios_share, color: Colors.white),
                        onPressed: _captureAndShare,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.grey, size: 30),
                        onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const SettingsScreen()),
                           );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              // ==========================================
              // メインビジュアル（グラフ）
              // ==========================================
              SizedBox(
                height: graphHeight,
                child: RepaintBoundary(
                  key: _graphKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxHeight < 50) return const SizedBox();

                        final double heightTarget = constraints.maxHeight;

                        return Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            // ---------------------------------------------------
                            // 背面：アニメーションする棒
                            // ---------------------------------------------------
                            TweenAnimationBuilder<double>(
                              // currentMax(kg)に対してアニメーション
                              tween: Tween<double>(begin: 0, end: currentMax),
                              duration: const Duration(milliseconds: 1800),
                              curve: Curves.easeOutExpo,
                              builder: (context, animatedKg, child) {
                                // 1. 表示用の値に変換 (kg -> lbs or kg)
                                final displayVal = convertWeightToDisplay(animatedKg, isLbs);
                                
                                // 2. 高さの比率計算 (displayVal / targetWeight)
                                // 例: 80kg / 100kg = 0.8
                                // 例: 180lbs / 225lbs = 0.8
                                final ratio = (targetWeight > 0) ? (displayVal / targetWeight) : 0.0;
                                final double animatedHeight = heightTarget * ratio;

                                // 3. 色の判定
                                final bool isOverTarget = displayVal >= targetWeight;
                                final Color barColor = isOverTarget ? AppColors.accent : AppColors.primary;

                                return Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // 1. 伸びる棒
                                    Container(
                                      height: animatedHeight,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: barColor, 
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        boxShadow: isOverTarget ? [
                                          BoxShadow(
                                            color: AppColors.accent.withValues(alpha: 0.8),
                                            blurRadius: 20,
                                            spreadRadius: 4,
                                          )
                                        ] : [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.6),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                    ),

                                    // 2. 棒の上に乗っかる数値
                                    Positioned(
                                      bottom: animatedHeight + 8, 
                                      child: Text(
                                        "${formatWeight(displayVal)}$unitString",
                                        style: TextStyle(
                                          color: barColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          shadows: [
                                             Shadow(
                                               blurRadius: 2, 
                                               color: Colors.black.withValues(alpha: 0.5), 
                                               offset: const Offset(1, 1)
                                             ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 3. 目標達成テキスト
                                    if (heightTarget > 100)
                                    Align(
                                      alignment: Alignment.center,
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: isOverTarget ? 1.0 : 0.0,
                                        child: AnimatedScale(
                                          duration: const Duration(milliseconds: 400),
                                          scale: isOverTarget ? 1.0 : 0.5,
                                          curve: Curves.elasticOut,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.accent, width: 2),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  const Text(
                                                    "LIMIT BREAK!", // Assuming this is kept in English as a stylistic choice or use AppLocalizations.of(context)!.limitBreak
                                                    style: TextStyle(
                                                      color: AppColors.accent,
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 24,
                                                      fontStyle: FontStyle.italic,
                                                      shadows: [
                                                        Shadow(blurRadius: 10, color: AppColors.accent, offset: Offset(0,0))
                                                      ]
                                                    ),
                                                  ),
                                                  Text(
                                                    "${formatWeight(targetWeight)}$unitString ${AppLocalizations.of(context)!.limitBreakMsg}",
                                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            // ---------------------------------------------------
                            // 前面：ターゲットライン (100kg or 225lbs)
                            // ---------------------------------------------------
                            Container(
                              height: heightTarget,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.accent, width: 3.0),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "${formatWeight(targetWeight)}$unitString",
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ),
                ),
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 10),
              
              // ==========================================
              // HISTORY / ANALYSIS トグル
              // ==========================================
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isHistoryOpen = !_isHistoryOpen;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                           Text(
                            "HISTORY / ANALYSIS", 
                            style: TextStyle(
                              color: _isHistoryOpen ? Colors.white : Colors.white54, 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.0
                            )
                          ),
                          const SizedBox(width: 5),
                          AnimatedRotation(
                            turns: _isHistoryOpen ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // アニメーションパネル
              // ==========================================
              AnimatedContainer(
                curve: _isHistoryOpen ? Curves.easeOutBack : Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                height: _isHistoryOpen ? 320.0 : 0.0,
                clipBehavior: Clip.hardEdge, 
                decoration: const BoxDecoration(),
                
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 320, 
                    child: Column(
                      children: [
                        // Panel Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getPanelTitle(context),
                                style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                              ),
                              // Toggle Button (Chart -> List -> Diagnosis -> Chart)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (_historyMode == HistoryMode.chart) {
                                      _historyMode = HistoryMode.list;
                                    } else if (_historyMode == HistoryMode.list) {
                                      _historyMode = HistoryMode.diagnosis;
                                    } else {
                                      _historyMode = HistoryMode.chart;
                                    }
                                  });
                                },
                                icon: Icon(
                                  _historyMode == HistoryMode.chart ? Icons.list 
                                  : _historyMode == HistoryMode.list ? Icons.analytics 
                                  : Icons.show_chart,
                                  size: 16, 
                                  color: AppColors.accent
                                ),
                                label: Text(
                                  _historyMode == HistoryMode.chart ? AppLocalizations.of(context)!.showList 
                                  : _historyMode == HistoryMode.list ? "Diagnosis" 
                                  : AppLocalizations.of(context)!.showChart,
                                  style: const TextStyle(color: AppColors.accent, fontSize: 12)
                                ),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                              ),
                            ],
                          ),
                        ),

                        // Panel Content
                        Expanded(
                          child: _historyMode == HistoryMode.chart
                            ? _buildChart(historyAsync, unitString, isLbs)
                            : _historyMode == HistoryMode.list
                              ? _buildHistoryList(historyAsync, unitString, isLbs)
                              : _buildDiagnosisPanel(currentMax),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // ボタンとの隙間

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // RecorderScreenに現在のMax(kg)を渡す
                    // RecorderScreen側でisLbsを見て初期値を適切に設定する必要がある
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecorderScreen(initialWeight: currentMax),
                      ),
                    );
                    ref.invalidate(currentMaxProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: Text(AppLocalizations.of(context)!.startWorkout, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              ],
            ),
          ),
        );
      },
    ),
      ),
    );
  }

  String _getPanelTitle(BuildContext context) {
    switch (_historyMode) {
      case HistoryMode.chart:
        return AppLocalizations.of(context)!.showChart;
      case HistoryMode.list:
        return AppLocalizations.of(context)!.showList;
      case HistoryMode.diagnosis:
        return AppLocalizations.of(context)!.diagnosisTitle;
    }
  }

  Widget _buildChart(AsyncValue<List<WorkoutHistoryItem>> historyAsync, String unitString, bool isLbs) {
    return GestureDetector(
      onTap: () {
        if (!_isPremiumMember) _showPremiumDialog(AppLocalizations.of(context)!.maxWeight);
      },
      child: Container(
        padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          children: [
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => Center(child: Text('Error', style: const TextStyle(color: Colors.red))),
              data: (historyList) {
                if (historyList.isEmpty) return const Center(child: Text("No Data"));
                final reversedList = historyList.reversed.toList();
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text("${value.toInt()}", style: const TextStyle(color: Colors.grey, fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: reversedList.asMap().entries.map((e) {
                          // Y軸を現在の単位に変換
                          final displayY = convertWeightToDisplay(e.value.weightValue, isLbs);
                          return FlSpot(e.key.toDouble(), displayY);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primary, 
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.blueGrey,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final record = reversedList[spot.x.toInt()];
                            return LineTooltipItem(
                              "${record.date}\nWeight: ${spot.y.toInt()}$unitString",
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              }
            ),
            if (!_isPremiumMember)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.amber, size: 40),
                        SizedBox(height: 8),
                        Text("PREMIUM ONLY", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(AsyncValue<List<WorkoutHistoryItem>> historyAsync, String unitString, bool isLbs) {
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (historyList) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: historyList.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
          itemBuilder: (context, index) {
            final item = historyList[index];
            
            // 単位変換
            final displayWeightVal = convertWeightToDisplay(item.weightValue, isLbs);
            final displayWeightStr = "${formatWeight(displayWeightVal)}$unitString";

            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: AppColors.error,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                final service = IsarService();
                await service.deleteLog(item.id);
                ref.invalidate(currentMaxProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.setDeleted)),
                  );
                }
              },
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(item.date, style: const TextStyle(color: Colors.grey, fontFamily: 'monospace')),
                subtitle: Text("${item.reps} reps", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayWeightStr,
                      style: TextStyle(
                        color: item.isPersonalBest ? AppColors.accent : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                    if (item.isPersonalBest) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.star, color: AppColors.accent, size: 14)
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosisPanel(double currentMax) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 48, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            "Analyze your weakness with Ghost Coach.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DiagnosisScreen(currentMaxWeight: currentMax),
                )
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text("START DIAGNOSIS"),
          ),
        ],
      ),
    );
  }
}
