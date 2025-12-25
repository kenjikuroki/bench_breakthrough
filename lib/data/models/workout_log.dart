import 'package:isar/isar.dart';

part 'workout_log.g.dart';

@collection
class WorkoutLog {
  Id id = Isar.autoIncrement;

  late DateTime date;
  late double weight;
  late int reps;
  late double estimated1RM;
}
