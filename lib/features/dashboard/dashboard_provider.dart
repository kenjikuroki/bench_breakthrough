import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/local/isar_service.dart';

part 'dashboard_provider.g.dart';

// Future<double> に変更 (データベースアクセスは時間がかかるため)
@riverpod
class CurrentMax extends _$CurrentMax {
  @override
  Future<double> build() async {
    final service = IsarService();
    return await service.getBestWeight();
  }
}


// -------------------------------------------------------------
// UI用モデルクラス
// -------------------------------------------------------------
class WorkoutHistoryItem {
  final int id; // Isar ID
  final String date;
  final String weight;
  final bool isPersonalBest;
  final int reps;
  final double estimated1RM;

  WorkoutHistoryItem({
    required this.id,
    required this.date,
    required this.weight,
    this.isPersonalBest = false,
    required this.reps,
    required this.estimated1RM,
  });

  double get weightValue {
    return double.tryParse(weight.replaceAll('kg', '')) ?? 0.0;
  }
}

// -------------------------------------------------------------
// 履歴リストのプロバイダー
// -------------------------------------------------------------
@riverpod
Stream<List<WorkoutHistoryItem>> workoutHistory(WorkoutHistoryRef ref) async* {
  final service = IsarService();
  
  // Isarから全データを監視
  await for (final logs in service.watchAllWorkouts()) {
    if (logs.isEmpty) {
      yield [];
      continue;
    }

    // 1. 自己ベスト(最大重量)を見つける
    // logsは日付降順などだが、全リストの中で最大のweightを探す
    double maxWeight = 0.0;
    for (final log in logs) {
      if (log.weight > maxWeight) {
        maxWeight = log.weight;
      }
    }

    // 2. UIモデルに変換
    final items = logs.map((log) {
      // 日付フォーマット: 2024.12.25
      final dateStr = "${log.date.year}.${log.date.month.toString().padLeft(2, '0')}.${log.date.day.toString().padLeft(2, '0')}";
      
      // 重量フォーマット: 小数点以下が0なら整数表示 (100.0 -> 100kg)
      final weightStr = (log.weight % 1 == 0) 
          ? "${log.weight.toInt()}kg" 
          : "${log.weight}kg";

      // 自己ベスト判定 (現在の最大値と同じならPBとする)
      // ※ 厳密には「その時点でのPB」かもしれないが、今回は「現在のMax」をハイライトする仕様とする
      final isPB = (log.weight == maxWeight) && (maxWeight > 0);

      // 1RM計算 (Epley公式: weight * (1 + reps/30))
      // 1回なら実重量そのまま
      double est1rm = log.weight;
      
      // Null安全対応: 古いデータなどでrepsがなければ1とする
      final int safeReps = log.reps ?? 1;

      if (safeReps > 1) {
        est1rm = log.weight * (1 + safeReps / 30.0);
      }
      
      // DBに値がある場合はそれを使う (後方互換性のため計算も入れておく)
      if (log.estimated1RM != null && log.estimated1RM! > 0) {
        est1rm = log.estimated1RM!;
      }

      return WorkoutHistoryItem(
        id: log.id,
        date: dateStr,
        weight: weightStr,
        isPersonalBest: isPB,
        reps: safeReps,
        estimated1RM: est1rm,
      );
    }).toList();

    yield items;
  }
}

// -------------------------------------------------------------
// AI予測ロジック (線形回帰)
// -------------------------------------------------------------
@riverpod
Future<List<FlSpot>> predictionSpots(PredictionSpotsRef ref) async {
  // 履歴を取得
  final history = await ref.watch(workoutHistoryProvider.future);
  
  // データ不足なら予測なし
  if (history.length < 2) return [];

  // 直近のデータ(最大10件)を使ってトレンドを計算
  // 履歴は新しい順(desc)で来る可能性が高いが、グラフは古い順(asc)で描画している
  // ここではグラフのX軸に合わせて「古い順」に直して計算する
  final sortedHistory = history.reversed.toList();
  final int n = sortedHistory.length;
  
  // 単回帰分析: y = ax + b
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
  
  for (int i = 0; i < n; i++) {
    double x = i.toDouble();
    double y = sortedHistory[i].weightValue;
    
    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumX2 += x * x;
  }

  final double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  final double intercept = (sumY - slope * sumX) / n;

  // 予測: 次の5回分、または100kgに達するまで
  List<FlSpot> spots = [];
  
  // 現在の最後のX座標
  int lastX = n - 1;
  
  // 次のポイントから予測
  for (int i = 1; i <= 10; i++) {
    double futureX = (lastX + i).toDouble();
    double futureY = slope * futureX + intercept;
    
    // 変な値(マイナスなど)は除外
    if (futureY < 0) futureY = 0;
    
    spots.add(FlSpot(futureX, futureY));

    // 100kg(または+α)を超えたら予測終了
    if (futureY >= 110) break;
  }

  return spots;
}
