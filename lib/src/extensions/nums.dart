import 'dart:core';

extension DoubleExtensions on double {
  double clampBetween(
      {required double value, required double min, required double max}) {
    if (value < min) {
      return min;
    } else if (value > max) {
      return max;
    }

    return value;
  }

  double clampRange({required double min, required double max}) {
    final decimalPercentage = this / 100;
    //finding x
    final x = (decimalPercentage * (max - min)) + min;
    return x;
  }
}
