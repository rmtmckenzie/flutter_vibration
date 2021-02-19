import AudioToolbox
import CoreHaptics
import Flutter
import UIKit

@available(iOS 13.0, *)
public class SwiftVibrationPlugin: NSObject, FlutterPlugin {
    private let isDevice = TARGET_OS_SIMULATOR == 0

    public static var engine: CHHapticEngine!
  
    private var player: CHHapticPatternPlayer?
    private var timer: Timer?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vibration", binaryMessenger: registrar.messenger())
        let instance = SwiftVibrationPlugin()

        SwiftVibrationPlugin.createEngine()

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// - Tag: CreateEngine
    public static func createEngine() {
        // Create and configure a haptic engine.
        do {
            SwiftVibrationPlugin.engine = try CHHapticEngine()
        } catch {
            print("Engine creation error: \(error)")
            return
        }

        if SwiftVibrationPlugin.engine == nil {
            print("Failed to create engine!")
        }

        // The stopped handler alerts you of engine stoppage due to external causes.
        SwiftVibrationPlugin.engine.stoppedHandler = { reason in
            print("The engine stopped for reason: \(reason.rawValue)")

            switch reason {
            case .audioSessionInterrupt: print("Audio session interrupt")
            case .applicationSuspended: print("Application suspended")
            case .idleTimeout: print("Idle timeout")
            case .systemError: print("System error")
            case .notifyWhenFinished: print("Playback finished")
            case .engineDestroyed: print("Engine Destroyed")
            case .gameControllerDisconnect: print("Game Controller Disconnect")
            @unknown default:
                print("Unknown error")
            }
        }

        // The reset handler provides an opportunity for your app to restart the engine in case of failure.
        SwiftVibrationPlugin.engine.resetHandler = {
            // Try restarting the engine.
            print("The engine reset --> Restarting now!")

            do {
                try SwiftVibrationPlugin.engine.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }

    private func supportsHaptics() -> Bool {
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "hasVibrator":
            result(isDevice)
        case "hasAmplitudeControl":
            result(isDevice)
        case "hasCustomVibrationsSupport":
            result(supportsHaptics())
        case "vibrate_duration":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "no_args", message: "args are missing", details: nil))
                return
            }

            let durationArg = max(1, args["duration"] as? Int ?? 500)

            guard let engine = SwiftVibrationPlugin.engine else {
                let start = DispatchTime.now()

                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                    if (DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds)/1000000 > durationArg {
                      timer.invalidate()
                      return
                    }
                
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    AudioServicesPlaySystemSound(1520) // 'pop'
                }

                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesPlaySystemSound(1520) // 'pop'
                
                result(isDevice)
                return
            }
                        
            let intensityArg = max(1, min(255, args["intensity"] as? Int ?? 255))
          
            let duration = Double(durationArg) / 1000.0
          
            let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(Double(intensityArg) / 255.0))
            
            // Create haptic event
            let hapticEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensityParameter],
                relativeTime: 0.0,
                duration: duration
            )
            // Try to play engine
            do {
                let patternToPlay = try CHHapticPattern(events: [hapticEvent], parameters: [])
                player = try engine.makePlayer(with: patternToPlay)
                try engine.start()
                try player!.start(atTime: 0)
            } catch {
                result(FlutterError(code: "play_failed", message: error.localizedDescription, details: nil))
                print("Failed to play pattern: \(error.localizedDescription).")
                return
            }
            
        case "vibrate":
          
//            guard let args = call.arguments else {
//                result(isDevice)
//                return
//            }
//
//            guard let myArgs = args as? [String: Any] else {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                result(isDevice)
//                return
//            }
//
//            let pattern = myArgs["pattern"] as! [Int]
//            let intensities = myArgs["intensities"] as! [Int]
//            let repeatAmount = myArgs["repeat"] as? Int
//
//            let duration = myArgs["duration"] as? Int
//            let amplitude = myArgs["amplitude"] as? Int
//
//            if pattern.count > 0 {
//              assert(intensities.count == 0  || intensities.count == pattern.count / 2)
//
//            }
//
//            if let pattern = pattern {
//              assert(pattern.count % 2 == 0, "Pattern must have even number of elements!")
//              guard pattern.count != 0 else {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                result(isDevice)
//                return
//              }
//
//              if let intensities = intensities {
//                assert(intensities.count == pattern.count / 2)
//
//              }
//            }
//
//            guard let pattern = myArgs["pattern"] as? [Int] else {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                result(isDevice)
//                return
//            }
//
//            if pattern.count == 0 {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                result(isDevice)
//                return
//            }
//
//            assert(pattern.count % 2 == 0, "Pattern must have even number of elements!")
//
//            if !supportsHaptics() {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                result(isDevice)
//                return
//            }
//
//            // Get event parameters, if any
//            var params: [CHHapticEventParameter] = []
//
//            if let amplitudes = myArgs["intensities"] as? [Int] {
//                if amplitudes.count > 0 {
//                    // There should be half as many amplitudes as pattern
//                    // i.e. disregard all the wait times
//                    assert(amplitudes.count == pattern.count / 2)
//                }
//
//                for a in amplitudes {
//                    let p = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(Double(a) / 255.0))
//                    params.append(p)
//                }
//            }
//
//            // Create haptic events
//            var hapticEvents: [CHHapticEvent] = []
//            var i: Int = 0
//            var rel: Double = 0.0
//
//            while i < pattern.count {
//                // Get intensity parameter, if any
//                let j = i / 2
//                let p = j < params.count ? [params[j]] : []
//
//                // Get wait time and duration
//                let waitTime = Double(pattern[i]) / 1000.0
//                let duration = Double(pattern[i + 1]) / 1000.0
//
//                rel += waitTime
//                i += 2
//
//                // Create haptic event
//                let e = CHHapticEvent(
//                    eventType: .hapticContinuous,
//                    parameters: p,
//                    relativeTime: rel,
//                    duration: duration
//                )
//
//                hapticEvents.append(e)
//
//                // Add duration to relative time
//                rel += duration
//            }
//
//            // Try to play engine
//            do {
//                if let engine = SwiftVibrationPlugin.engine {
//                    let patternToPlay = try CHHapticPattern(events: hapticEvents, parameters: [])
//                    let player = try engine.makePlayer(with: patternToPlay)
//                    try engine.start()
//                    try player.start(atTime: 0)
//                }
//            } catch {
//                print("Failed to play pattern: \(error.localizedDescription).")
//            }

            result(isDevice)
        case "cancel":
            try? player?.cancel()
            player = nil
            timer?.invalidate()
            timer = nil
            result(nil)
          default:
            result(FlutterMethodNotImplemented)
        }
    }
  
  public func platform() -> String {
      var sysinfo = utsname()
      uname(&sysinfo)
      return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
  }

  public var hasHapticFeedback: Bool {
      return ["iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4"].contains(platform())
  }
}
