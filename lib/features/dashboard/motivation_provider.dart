import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ランダムに「ドSな格言」のID(1-21)を返すプロバイダー

// 文字列そのものではなく、AppLocalizationsのキーに対応するIDを返す
final motivationMessageIdProvider = Provider.autoDispose<int>((ref) {
  final random = Random();
  // 1/3の確率で 0 を返す (姉妹アプリPR用)
  if (random.nextInt(3) == 0) {
    return 0;
  }
  // それ以外は motivation1 ~ motivation21
  return random.nextInt(21) + 1;
});
