import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/workout_log.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [WorkoutLogSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // 記録を保存する
  Future<void> saveWorkout(WorkoutLog newLog) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.workoutLogs.put(newLog);
    });
  }

  // 過去最高の1RMを取得する（自己ベスト）
  Future<double> getBestMax() async {
    final isar = await db;
    // estimated1RMの大きい順に並べて、最初の1つを取る
    final bestLog = await isar.workoutLogs
        .where()
        .sortByEstimated1RMDesc()
        .findFirst();

    return bestLog?.estimated1RM ?? 0.0;
  }

  // 最新のトレーニング記録を取得する
  Future<WorkoutLog?> getLastWorkout() async {
    final isar = await db;
    return await isar.workoutLogs
        .where()
        .sortByDateDesc()
        .findFirst();
  }

  // 過去最高の重量を取得する (Raw Weight)
  Future<double> getBestWeight() async {
    final isar = await db;
    final bestLog = await isar.workoutLogs
        .where()
        .sortByWeightDesc()
        .findFirst();

    return bestLog?.weight ?? 0.0;
  }

  // 今日のトレーニング記録を取得する
  Future<List<WorkoutLog>> getTodaysWorkouts() async {
    final isar = await db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.workoutLogs
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .sortByDateDesc()
        .findAll();
  }

  // 記録を削除する
  Future<void> deleteLog(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.workoutLogs.delete(id);
    });
  }
}
