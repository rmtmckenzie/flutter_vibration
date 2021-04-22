package com.benjaminabel.vibration;

import android.os.Build;

import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class VibrationMethodChannelHandler implements MethodChannel.MethodCallHandler {
    private final Vibration vibration;

    VibrationMethodChannelHandler(Vibration vibrationPlugin) {
        assert (vibrationPlugin != null);
        this.vibration = vibrationPlugin;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "hasVibrator":
                result.success(vibration.getVibrator().hasVibrator());

                break;
            case "hasAmplitudeControl":
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    result.success(vibration.getVibrator().hasAmplitudeControl());
                } else {
                    // For earlier API levels, return false rather than raising a
                    // MissingPluginException in order to allow applications to handle
                    // non-existence gracefully.
                    result.success(false);
                }

                break;
            case "hasCustomVibrationsSupport":
                result.success(true);

                break;
            case "vibrate_duration": {
                int duration = max(1, defautValue((Integer) call.argument("duration"), 500));
                int intensity = max(1, min(255, defautValue((Integer) call.argument("intensity"), 255)));

                if (duration > 1000 & duration % 1000 == 0) {
                    int num = duration / 1000;

                    List<Integer> pattern = new ArrayList<>();
                    pattern.add(0);
                    List<Integer> intensities = new ArrayList<>();
                    intensities.add(0);
                    for(int i = 0; i < num; ++i) {
                        pattern.add(100);
                        intensities.add(intensity);
                        pattern.add(900);
                        intensities.add(0);
                    }

                    vibration.vibrate(pattern, -1, intensities);
                } else {
                    vibration.vibrate(duration, intensity);
                }

                result.success(null);
                break;
            }
            case "vibrate":
                int duration = call.argument("duration");
                List<Integer> pattern = call.argument("pattern");
                int repeat = call.argument("repeat");
                List<Integer> intensities = call.argument("intensities");
                int amplitude = call.argument("amplitude");

                if (pattern.size() > 0 && intensities.size() > 0) {
                    vibration.vibrate(pattern, repeat, intensities);
                } else if (pattern.size() > 0) {
                    vibration.vibrate(pattern, repeat);
                } else {
                    vibration.vibrate(duration, amplitude);
                }

                result.success(null);

                break;
            case "cancel":
                vibration.getVibrator().cancel();

                result.success(null);

                break;
            default:
                result.notImplemented();
        }
    }
}