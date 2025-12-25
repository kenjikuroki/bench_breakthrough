import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../recorder/recorder_screen.dart';
import '../../data/local/isar_service.dart';
import 'dashboard_provider.dart';

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
  // 開閉フラグ (今回はグラフ/リストの切り替えに使用)
  // 開閉フラグ
  bool _isHistoryOpen = false;
  // グラフ/リストの切り替え
  bool _isChartMode = true; // デフォルトはグラフモード

  // ---------------------------------------------------
  // シェア機能のロジック
  // ---------------------------------------------------
  Future<void> _captureAndShare() async {
    // 1. プレミアム会員チェック
    if (!_isPremiumMember) {
      _showPremiumDialog("シェア機能");
      return;
    }

    try {
      // 2. 画面（Widget）を画像データに変換
      RenderRepaintBoundary? boundary = _graphKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // pixelRatio: 3.0 にすると高画質（Retina対応）になります
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. 一時フォルダに画像を保存
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/bench_pr.png').create();
      await imagePath.writeAsBytes(pngBytes);

      // 4. シェア機能を呼び出す
      await Share.shareXFiles(
        [XFile(imagePath.path)], 
        text: 'ベンチプレス 100kg突破！ #BenchBreakthrough',
      );
      
    } catch (e) {
      debugPrint("エラーが発生しました: $e");
    }
  }

  // 課金誘導ダイアログ
  void _showPremiumDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Premium Feature", style: TextStyle(color: Colors.amber)),
        content: Text(
          "$featureNameを利用するには、\nプレミアム会員への登録が必要です。\n\n推定1RMグラフで成長の軌跡を確認しましょう！",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text("キャンセル"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("アップグレード (¥480)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              // ここで実際の課金処理をする
              setState(() {
                _isPremiumMember = true; // デモ用に購入済みにしちゃう
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("プレミアム会員になりました！"))
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

    final currentMax = currentMaxAsync.when(
      data: (value) => value,
      loading: () => 0.0,
      error: (err, stack) => 0.0,
    );

    return Scaffold(
      backgroundColor: Colors.black, // ユーザー指定: 黒
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // ヘッダー（タイトル）
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BENCH', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        )),
                      Text('BREAKTHROUGH', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          letterSpacing: 2.0,
                        )),
                    ],
                  ),
                  // 右上のアイコン群
                  Row(
                    children: [
                      // シェアボタン
                      IconButton(
                        icon: const Icon(Icons.ios_share, color: Colors.white),
                        onPressed: _captureAndShare, // 押すとシェア処理へ
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.grey, size: 30),
                        onPressed: () {
                           // context.push('/settings'); 
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              // ==========================================
              // メインビジュアル（グラフ） (伸縮する)
              // ==========================================
              // ==========================================
              // メインビジュアル（グラフ） (Expanded flex: 4)
              // ==========================================
              // ==========================================
              // メインビジュアル（グラフ） (伸縮する)
              // ==========================================
              Expanded(
                // flexは指定せず、残りの領域をすべて使う
                child: RepaintBoundary(
                  key: _graphKey, // これが目印
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black, // 背景黒
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 履歴が開いて高さが極端に小さくなった時の対策
                        if (constraints.maxHeight < 50) return const SizedBox();

                        // 1. まず「100kgのライン」が画面上のどの高さに来るか決める
                        // 親Widgetの高さすべてを100kgエリアとする
                        final double height100kg = constraints.maxHeight;

                        return Stack(
                          alignment: Alignment.bottomCenter, // 下揃え
                          clipBehavior: Clip.none, // 重要：枠からはみ出しても描画を許可する
                          children: [
                            // ---------------------------------------------------
                            // 背面：アニメーションする棒
                            // ---------------------------------------------------
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: currentMax),
                              duration: const Duration(milliseconds: 1800), // 1.8秒
                              curve: Curves.easeOutExpo,
                              builder: (context, animatedWeight, child) {
                                // 1. 高さの計算
                                // 黄色いライン(height100kg)が「100kg」なので、100で割る
                                final double animatedHeight = height100kg * (animatedWeight / 100.0);

                                // 2. 色の判定
                                // 100kg以上ならゴールド
                                final bool isOver100 = animatedWeight >= 100.0;
                                final Color barColor = isOver100 ? AppColors.accent : AppColors.primary;

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
                                        // 100kg超えなら発光させる
                                        boxShadow: isOver100 ? [
                                          BoxShadow(
                                            color: AppColors.accent.withValues(alpha: 0.8), // 発光を強めに
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
                                        "${animatedWeight.toInt()}kg",
                                        style: TextStyle(
                                          color: barColor, // 文字色も変わる
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18, // 少し大きく
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

                                    // 3. 100kg超え達成テキスト演出
                                    Align(
                                      alignment: Alignment.center,
                                      // isOver100の切り替わりで自動アニメーションする
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300), // 0.3秒でフワッと出る
                                        opacity: isOver100 ? 1.0 : 0.0, // 超えたら表示、それ以外は透明
                                        child: AnimatedScale(
                                          duration: const Duration(milliseconds: 400), // 0.4秒でズーム
                                          scale: isOver100 ? 1.0 : 0.5, // 超えたら等倍、それまでは半分サイズ
                                          curve: Curves.elasticOut, // ボヨヨンと飛び出す動き
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7), // 背景を少し暗くして文字を強調
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.accent, width: 2),
                                            ),
                                            child: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "LIMIT BREAK!",
                                                  style: TextStyle(
                                                    color: AppColors.accent,
                                                    fontWeight: FontWeight.w900, // 超太字
                                                    fontSize: 24,
                                                    fontStyle: FontStyle.italic,
                                                    shadows: [
                                                      Shadow(blurRadius: 10, color: AppColors.accent, offset: Offset(0,0))
                                                    ]
                                                  ),
                                                ),
                                                Text(
                                                  "100kg 超え達成！",
                                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                            // 前面：黄色い100kgライン (基準)
                            // ---------------------------------------------------
                            Container(
                              height: height100kg, // ちょうど100kgの高さ
                              width: double.infinity, // 横幅いっぱい
                              decoration: const BoxDecoration(
                                // 上辺だけに黄色い線を引く
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.accent, // 黄色いライン
                                    width: 3.0, // ラインの太さ
                                  ),
                                ),
                              ),
                              child: const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "100kg",
                                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
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
              
              // ==========================================
              // 切り替えヘッダー (1RM GRAPH <-> HISTORY LIST)
              // ==========================================
              const SizedBox(height: 10),
              
              // ==========================================
              // HISTORY / ANALYSIS トグルボタン (アニメーションのトリガー)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // アイコンとラベルを離す
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
                      // 閉じてる時は何も表示しないか、軽いヒントを出す? 今はシンプルに
                    ],
                  ),
                ),
              ),

              // ==========================================
              // アニメーションパネル (ビヨーンと出る)
              // ==========================================
              AnimatedContainer(
                curve: _isHistoryOpen ? Curves.easeOutBack : Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                height: _isHistoryOpen ? 320.0 : 0.0, // 高さを確保 (トグルボタン分含める)
                clipBehavior: Clip.hardEdge, 
                decoration: const BoxDecoration(),
                
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 320, 
                    child: Column(
                      children: [
                        // Header for the chart/list section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _isChartMode ? "MAX WEIGHT" : "WORKOUT HISTORY",
                              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                            ),
                          ),
                        ),
                        // 1. 内部トグル (Graph <-> List)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isChartMode = !_isChartMode;
                                  });
                                },
                                icon: Icon(_isChartMode ? Icons.list : Icons.show_chart, size: 16, color: AppColors.accent),
                                label: Text(_isChartMode ? "Show List" : "Show Chart", style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                              ),
                            ],
                          ),
                        ),

                        // 2. コンテンツエリア
                        Expanded(
                          child: _isChartMode 
                            // ------------------------------------
                            // A. 1RM 推移グラフ
                            // ------------------------------------
                            ? GestureDetector(
                                onTap: () {
                        // ロック中ならダイアログを出す
                        if (!_isPremiumMember) _showPremiumDialog("MAX重量推移グラフ");
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
                                          return FlSpot(e.key.toDouble(), e.value.weightValue);
                                        }).toList(),
                                        isCurved: true, // 滑らかな曲線
                                        color: AppColors.primary, // 1RM(Orange)と区別してPrimary(Cyan)に戻す
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: false), // ドットは非表示
                                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.2)), // 下を塗る
                                      ),
                                    ],
                                    // インタラクション設定
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (touchedSpot) => Colors.blueGrey,
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            final record = reversedList[spot.x.toInt()];
                                            return LineTooltipItem(
                                              "${record.date}\nWeight: ${spot.y.toInt()}kg",
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
                                            color: Colors.black.withOpacity(0.6),
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
                              )
                            // ------------------------------------
                            // B. 履歴リスト
                            // ------------------------------------
                            : historyAsync.when(
                                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                                data: (historyList) {
                                  return ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: historyList.length,
                                    separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                                    itemBuilder: (context, index) {
                                      final item = historyList[index];
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
                                // 1. DB削除
                                final service = IsarService();
                                await service.deleteLog(item.id);
                                
                                // 2. Max重量の再計算が必要かもしれないので無効化
                                // (StreamProviderは自動更新されるが、FutureProviderのcurrentMaxは手動更新が必要)
                                ref.invalidate(currentMaxProvider);

                                // 3. 完了メッセージ
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Record deleted")),
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
                                      item.weight,
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
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // ボタンとの隙間

              // ==========================================
              // ボタン（固定）
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate to RecorderScreen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecorderScreen(initialWeight: currentMax),
                      ),
                    );
                    // 戻ってきたらデータを再読み込み
                    ref.invalidate(currentMaxProvider);
                    // refresh is automatic for stream provider
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
                  child: const Text('START WORKOUT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
