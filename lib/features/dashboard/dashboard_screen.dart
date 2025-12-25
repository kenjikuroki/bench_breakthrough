import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../recorder/recorder_screen.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // データ取得 (AsyncValueになったので、.whenで状態を分ける)
    final currentMaxAsync = ref.watch(currentMaxProvider);

    // データが取れるまでは0.0kg扱い、エラーなら0.0kg扱いにする
    final currentMax = currentMaxAsync.when(
      data: (value) => value,
      loading: () => 0.0,
      error: (err, stack) => 0.0,
    );

    // 以降の targetMax, toGo, progress の計算などは変更なし
    // 残り重量
    // final toGo = (targetMax - currentMax).clamp(0.0, 100.0);

    return Scaffold(
      backgroundColor: Colors.black, // ユーザー指定: 黒
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------------------------------------------------
              // 1. タイトル部分 (高さは自動)
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BENCH',
                        style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'BREAKTHROUGH',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.grey, size: 30),
                      onPressed: () {
                         // context.push('/settings'); 
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20), // 少し隙間

              // ------------------------------------------------
              // 2. グラフ部分 (★ここを変える！余った場所を全部使う★)
              // ------------------------------------------------
              Expanded( // ← これで囲むのがポイント！
                child: Container(
                  width: double.infinity,
                  // height: 400, // ← 高さ指定は削除！Expandedに任せる
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black, // グレーから黒に変更
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LayoutBuilder(
                      builder: (context, constraints) {
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

              const SizedBox(height: 20), // ボタンとの隙間

              // ------------------------------------------------
              // 3. ボタン部分 (高さは固定)
              // ------------------------------------------------
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
                  child: const Text(
                    'START WORKOUT',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
