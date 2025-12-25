class OneRmCalculator {
  /// Epley Formulaを用いて1RMを計算
  /// weight: 重量(kg/lbs)
  /// reps: 回数
  static double calculate(double weight, int reps) {
    if (reps == 0) return 0.0;
    if (reps == 1) return weight;

    // Epley formula: w * (1 + r/30)
    final oneRm = weight * (1 + (reps / 30.0));

    // 小数点第1位で丸める
    return double.parse(oneRm.toStringAsFixed(1));
  }
}
