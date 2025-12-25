import 'package:riverpod_annotation/riverpod_annotation.dart';
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
