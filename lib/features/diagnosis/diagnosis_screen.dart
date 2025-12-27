import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../settings/settings_provider.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';

// =========================================================
// 1. 定義とデータ (The Soul of the App)
// =========================================================

enum IntensityZone {
  reckless,   // Zone A: 105%以上 (無謀)
  challenge,  // Zone B: 102.5%〜105% (挑戦)
  close,      // Zone C: 100%〜102.5% (惜敗)
  stagnation, // Zone D: 95%〜100% (停滞)
  slump       // Zone E: 95%未満 (不調)
}

enum FailPosition {
  bottom, // 胸上〜10cm
  middle, // 肘90度付近
  top     // フィニッシュ手前
}

// 全45パターンのドSコーチングデータは AppLocalizations から取得する


// =========================================================
// 2. 診断画面 Widget (UI)
// =========================================================

class DiagnosisScreen extends ConsumerStatefulWidget {
  // 実際にはDBなどから取得した「現在のMAX重量」を渡す
  final double currentMaxWeight;

  const DiagnosisScreen({super.key, this.currentMaxWeight = 100.0});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  double _selectedWeight = 0.0;
  List<double> _weightOptions = [];
  bool _isLbs = false;
  bool _initialized = false;
  FailPosition? _selectedPosition;
  
  // ハードボイルド・カラーパレット
  final Color _neonRed = const Color(0xFFFF0033);
  final Color _darkBg = const Color(0xFF121212);
  final Color _cardBg = const Color(0xFF1E1E1E);
  
  bool _isAnalyzing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _isLbs = ref.read(isLbsProvider);

      if (_isLbs) {
        // Lbs Mode: 45lbs ~ 600lbs (5lbs step)
        _weightOptions = List.generate(112, (index) => 45.0 + (index * 5.0));
      } else {
        // Kg Mode: 20kg ~ 300kg (0.25kg step) - 範囲を少し広めに
        _weightOptions = List.generate(1121, (index) => 20.0 + (index * 0.25));
      }

      // 初期選択値 (currentMaxWeightに近い値)
      // currentMaxWeightはKgで来る想定だが、表示単位に合わせて変換・選択
      final double initKg = widget.currentMaxWeight > 0 ? widget.currentMaxWeight : 60.0;
      final double targetVal = _isLbs ? convertWeightToDisplay(initKg, true) : initKg;

      // 最も近い選択肢を選ぶ
      if (_weightOptions.isNotEmpty) {
        _selectedWeight = _weightOptions.reduce((a, b) => 
          (a - targetVal).abs() < (b - targetVal).abs() ? a : b);
      } else {
        _selectedWeight = targetVal;
      }
      
      _initialized = true;
    }
  }

  Future<void> _analyze() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 未入力チェック (0以下は弾く)
    if (_selectedPosition == null || _selectedWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.msgInputError, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _neonRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // シンキングタイム演出 (2秒)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    // 計算ロジック
    // _selectedWeightは表示単位(kg or lbs)の値。
    // 比率計算のために、currentMaxWeight(kg)と比較するなら、_selectedWeightをkgに戻す必要がある。
    // ただし、widget.currentMaxWeightは常にkg。
    // ここでは、比率 = (失敗重量 / MAX重量) * 100
    
    // 表示単位がLbsの場合、_selectedWeightはLbs。これをKgに戻して比較するか、
    // あるいはMAX重量をLbsに変換して比較するか。
    // どちらにせよ比率は同じになるはず。
    
    // 単純化：MAX重量を表示単位に変換してから比較
    final double maxInDisplayUnit = _isLbs 
        ? convertWeightToDisplay(widget.currentMaxWeight, true) 
        : widget.currentMaxWeight;
        
    if (maxInDisplayUnit == 0) return; // 0除算回避
    
    final double ratio = (_selectedWeight / maxInDisplayUnit) * 100;

    // ゾーン判定
    IntensityZone zone;
    if (ratio >= 105) {
      zone = IntensityZone.reckless;
    } else if (ratio >= 102.5) {
      zone = IntensityZone.challenge;
    } else if (ratio >= 100) {
      zone = IntensityZone.close;
    } else if (ratio >= 95) {
      zone = IntensityZone.stagnation;
    } else {
      zone = IntensityZone.slump;
    }

    // アドバイス抽選
    // AppLocalizationsからデータを取得
    final coachingData = _getCoachingData(l10n);
    final List<String> advices = coachingData[zone]?[_selectedPosition!] ?? [l10n.msgDataError]; 
    final String advice = advices[Random().nextInt(advices.length)];

    _showResultDialog(zone, advice, ratio);
  }

  Map<IntensityZone, Map<FailPosition, List<String>>> _getCoachingData(AppLocalizations l10n) {
    return {
      IntensityZone.reckless: {
        FailPosition.bottom: [
          l10n.diagnosisRecklessBottom1, l10n.diagnosisRecklessBottom2, l10n.diagnosisRecklessBottom3
        ],
        FailPosition.middle: [
          l10n.diagnosisRecklessMiddle1, l10n.diagnosisRecklessMiddle2, l10n.diagnosisRecklessMiddle3
        ],
        FailPosition.top: [
          l10n.diagnosisRecklessTop1, l10n.diagnosisRecklessTop2, l10n.diagnosisRecklessTop3
        ],
      },
      IntensityZone.challenge: {
        FailPosition.bottom: [
          l10n.diagnosisChallengeBottom1, l10n.diagnosisChallengeBottom2, l10n.diagnosisChallengeBottom3
        ],
        FailPosition.middle: [
          l10n.diagnosisChallengeMiddle1, l10n.diagnosisChallengeMiddle2, l10n.diagnosisChallengeMiddle3
        ],
        FailPosition.top: [
          l10n.diagnosisChallengeTop1, l10n.diagnosisChallengeTop2, l10n.diagnosisChallengeTop3
        ],
      },
      IntensityZone.close: {
        FailPosition.bottom: [
          l10n.diagnosisCloseBottom1, l10n.diagnosisCloseBottom2, l10n.diagnosisCloseBottom3
        ],
        FailPosition.middle: [
          l10n.diagnosisCloseMiddle1, l10n.diagnosisCloseMiddle2, l10n.diagnosisCloseMiddle3
        ],
        FailPosition.top: [
          l10n.diagnosisCloseTop1, l10n.diagnosisCloseTop2, l10n.diagnosisCloseTop3
        ],
      },
      IntensityZone.stagnation: {
        FailPosition.bottom: [
          l10n.diagnosisStagnationBottom1, l10n.diagnosisStagnationBottom2, l10n.diagnosisStagnationBottom3
        ],
        FailPosition.middle: [
          l10n.diagnosisStagnationMiddle1, l10n.diagnosisStagnationMiddle2, l10n.diagnosisStagnationMiddle3
        ],
        FailPosition.top: [
          l10n.diagnosisStagnationTop1, l10n.diagnosisStagnationTop2, l10n.diagnosisStagnationTop3
        ],
      },
      IntensityZone.slump: {
        FailPosition.bottom: [
          l10n.diagnosisSlumpBottom1, l10n.diagnosisSlumpBottom2, l10n.diagnosisSlumpBottom3
        ],
        FailPosition.middle: [
          l10n.diagnosisSlumpMiddle1, l10n.diagnosisSlumpMiddle2, l10n.diagnosisSlumpMiddle3
        ],
        FailPosition.top: [
          l10n.diagnosisSlumpTop1, l10n.diagnosisSlumpTop2, l10n.diagnosisSlumpTop3
        ],
      },
    };
  }

  void _showResultDialog(IntensityZone zone, String advice, double ratio) {
    final l10n = AppLocalizations.of(context)!;
    String zoneTitle = "";
    switch (zone) {
      case IntensityZone.reckless: zoneTitle = l10n.zoneTitleReckless; break;
      case IntensityZone.challenge: zoneTitle = l10n.zoneTitleChallenge; break;
      case IntensityZone.close: zoneTitle = l10n.zoneTitleClose; break;
      case IntensityZone.stagnation: zoneTitle = l10n.zoneTitleStagnation; break;
      case IntensityZone.slump: zoneTitle = l10n.zoneTitleSlump; break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            Text(zoneTitle, style: TextStyle(color: _neonRed, fontWeight: FontWeight.bold, fontSize: 22)),
            Text("INTENSITY: ${ratio.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.grey),
            const SizedBox(height: 15),
            Text(
              advice,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("- Ghost Coach", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnBackToTraining, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  l10n.diagnosisIntroTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    shadows: [Shadow(color: _neonRed, blurRadius: 15)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.diagnosisIntroSubtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // FAILED WEIGHT
                _buildSectionTitle(l10n.labelFailedWeight),
                const SizedBox(height: 10),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: _weightOptions.isEmpty 
                    ? const Center(child: CircularProgressIndicator())
                    : CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark, 
                          textTheme: CupertinoTextThemeData(
                            pickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: _weightOptions.contains(_selectedWeight)
                                ? _weightOptions.indexOf(_selectedWeight) 
                                : 0
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedWeight = _weightOptions[index];
                            });
                          },
                          selectionOverlay: Container(
                             decoration: BoxDecoration(
                               color: _neonRed.withValues(alpha: 0.1),
                               border: Border.symmetric(
                                 horizontal: BorderSide(color: _neonRed.withValues(alpha: 0.3)),
                               ),
                             ),
                          ),
                          children: _weightOptions.map((w) {
                             final String text = _isLbs 
                                ? "${w.toInt()}" // lbsは整数表示が一般的だが、0.25stepなら小数点。ここでは一応format
                                : formatWeight(w);
                             return Center(
                               child: Text(
                                  "$text ${_isLbs ? 'lbs' : 'kg'}",
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                               ),
                             );
                          }).toList(),
                        ),
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Current MAX: ${widget.currentMaxWeight} kg",
                    style: TextStyle(color: _neonRed, fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),

                const SizedBox(height: 30),

                // FAILED POSITION
                _buildSectionTitle(l10n.labelFailedPosition),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildPositionButton(FailPosition.bottom, l10n.labelBottom, l10n.labelBottomJp, Icons.vertical_align_bottom), // bottomJp is just "Chest/Bottom" in local lang
                    const SizedBox(width: 10),
                    _buildPositionButton(FailPosition.middle, l10n.labelMiddle, l10n.labelMiddleJp, Icons.vertical_align_center),
                    const SizedBox(width: 10),
                    _buildPositionButton(FailPosition.top, l10n.labelTop, l10n.labelTopJp, Icons.vertical_align_top),
                  ],
                ),

                const SizedBox(height: 50),

                // ANALYZE BUTTON
                ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _neonRed,
                    disabledBackgroundColor: _neonRed.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 8,
                    shadowColor: _neonRed.withValues(alpha: 0.6),
                  ),
                  child: _isAnalyzing 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.analytics_outlined, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            l10n.btnAnalyze,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
    );
  }

  Widget _buildPositionButton(FailPosition position, String labelEn, String labelJp, IconData icon) {
    final bool isSelected = _selectedPosition == position;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPosition = position;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? _neonRed.withValues(alpha: 0.15) : _cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _neonRed : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: _neonRed.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _neonRed : Colors.grey, size: 28),
              const SizedBox(height: 10),
              Text(
                labelEn,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                labelJp,
                style: TextStyle(
                  color: isSelected ? _neonRed : Colors.grey.shade700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
