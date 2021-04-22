import 'dart:async';

import 'package:flutter/services.dart';

/// Platform-independent vibration methods.
class Vibration {
  /// Method channel to communicate with native code.
  static const MethodChannel _channel = const MethodChannel('vibration');

  /// Check if vibrator is available on device.
  ///
  /// ```dart
  /// if (await Vibration.hasVibrator()) {
  ///   Vibration.vibrate();
  /// }
  /// ```
  static Future<bool?> hasVibrator() => _channel.invokeMethod("hasVibrator");

  /// Check if the vibrator has amplitude control.
  ///
  /// ```dart
  /// if (await Vibration.hasAmplitudeControl()) {
  ///   Vibration.vibrate(amplitude: 128);
  /// }
  /// ```
  static Future<bool?> hasAmplitudeControl() =>
      _channel.invokeMethod("hasAmplitudeControl");

  /// Check if the device is able to vibrate with a custom
  /// [duration], [pattern] or [intensities].
  /// May return `true` even if the device has no vibrator.
  ///
  /// ```dart
  /// if (await Vibration.hasCustomVibrationsSupport()) {
  ///   Vibration.vibrate(duration: 1000);
  /// } else {
  ///   Vibration.vibrate();
  ///   await Future.delayed(Duration(milliseconds: 500));
  ///   Vibration.vibrate();
  /// }
  /// ```
  static Future<bool?> hasCustomVibrationsSupport() =>
      _channel.invokeMethod("hasCustomVibrationsSupport");

  /// Vibrate with [duration] at [amplitude] or [pattern] at [intensities].
  ///
  /// The default vibration duration is 500ms.
  /// Amplitude is a range from 1 to 255, if supported.
  ///
  /// ```dart
  /// Vibration.vibrate(duration: 1000);
  ///
  /// if (await Vibration.hasAmplitudeControl()) {
  ///   Vibration.vibrate(duration: 1000, amplitude: 1);
  ///   Vibration.vibrate(duration: 1000, amplitude: 255);
  /// }
  /// ```
  static Future<void> vibrate(
          {int duration = 500,
          List<int> pattern = const [],
          int repeat = -1,
          List<int> intensities = const [],
          int amplitude = -1}) =>
      _channel.invokeMethod(
        "vibrate",
        {
          "duration": duration,
          "pattern": pattern,
          "repeat": repeat,
          "amplitude": amplitude,
          "intensities": intensities
        },
      );

  static Future<void> forDuration(Duration duration, {int amplitude = 255}) {
    assert(amplitude > 0 && amplitude < 256);
    return _channel.invokeMethod("vibrate_duration", {"duration": duration.inMilliseconds, "intensity": amplitude});
  }

  /// Cancel ongoing vibration.
  ///
  /// ```dart
  /// Vibration.vibrate(duration: 10000);
  /// Vibration.cancel();
  /// ```
  static Future<void> cancel() => _channel.invokeMethod("cancel");
}

enum PatternElementType { vibration, pause }

class Intensity {
  final int _intensity;

  const Intensity._(this._intensity);

  const Intensity.custom(int intensity) : _intensity = intensity;

  static const high = Intensity._(255);
  static const med = Intensity._(128);
  static const low = Intensity._(64);
  static const off = Intensity._(0);

  int get asInt => _intensity;
}

class PatternElement {
  final Duration duration;
  final Intensity intensity;

  PatternElement(this.duration, {this.intensity = Intensity.high});
}