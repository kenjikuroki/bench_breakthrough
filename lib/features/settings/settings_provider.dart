import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  static const _keyUnit = 'unit_system'; // 'kg' or 'lbs'

  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUnit) ?? 'kg';
  }

  Future<void> setUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnit, unit);
    state = AsyncData(unit);
  }

  Future<void> toggleUnit() async {
    final current = state.value ?? 'kg';
    final next = current == 'kg' ? 'lbs' : 'kg';
    await setUnit(next);
  }
}

@riverpod
class IsPremium extends _$IsPremium {
  static const _keyPremium = 'is_premium';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPremium) ?? false;
  }

  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremium, value);
    state = AsyncData(value);
  }
}

// Helpers for UI
@riverpod
bool isLbs(IsLbsRef ref) {
  final unitAsync = ref.watch(settingsProvider);
  return unitAsync.valueOrNull == 'lbs';
}

@riverpod
String unitString(UnitStringRef ref) {
  return ref.watch(isLbsProvider) ? 'lbs' : 'kg';
}

@riverpod
double targetWeight(TargetWeightRef ref) {
  return ref.watch(isLbsProvider) ? 225.0 : 100.0;
}

// ---------------------------------------------------------
// Helper Logic Functions (Non-Riverpod)
// ---------------------------------------------------------

// 表示用に変換 (内部kg -> 表示単位)
double convertWeightToDisplay(double kgValue, bool isLbs) {
  if (!isLbs) return kgValue;
  // 1kg = 2.20462lbs
  return kgValue * 2.20462; 
}

// 保存用に変換 (表示単位 -> 内部kg)
double convertWeightToStorage(double displayValue, bool isLbs) {
  if (!isLbs) return displayValue;
  return displayValue / 2.20462;
}

// 表示用文字列整形 (例: 100.0 -> "100", 100.5 -> "100.5")
String formatWeight(double value) {
  // 整数なら整数として表示
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  // 小数点以下があれば最大2桁まで表示し、末尾の0は消す（toStringAsFixedだと0が残るため単純化）
  // 0.25刻みに対応するため、必要な桁数だけ出す
  return value.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
}
