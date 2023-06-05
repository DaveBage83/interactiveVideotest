//
//  DeviceRollReader.swift
//  VideoTester
//
//  Created by David Bage on 03/06/2023.
//

import SwiftUI
import CoreMotion

protocol MotionManagerProtocol {
    var deviceMotionUpdateInterval: TimeInterval { get set }
    func startDeviceMotionUpdates(to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler)
    func stopDeviceMotionUpdates()
}

extension CMMotionManager: MotionManagerProtocol {}

final class DeviceRollReader: ObservableObject {

    /// Value between 0 and 1 corresponding to the amount the device is tilted left or right.
    /// 0.5 is the midpoint (flat)
    @Published private(set) var roll = 0.0

    private var previousRoll = 0.0
    private var motionManager: MotionManagerProtocol
    private let inputRange: ClosedRange<Double>

    /// - Parameters:
    ///   - inputRange: The range, in radians, of what tilt inputs should be the lower and upper bound of accepted inputs.
    ///   Values outside of this range will be capped to either 0 or 1
    ///   - motionManager: The motion manager used to read the roll amount
    init(inputRange: ClosedRange<Double>,
         motionManager: MotionManagerProtocol = CMMotionManager()) {
        self.inputRange = inputRange
        self.motionManager = motionManager
        self.motionManager.deviceMotionUpdateInterval = 0.01
    }

    func startReading() {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, _) in
            guard let self, let attitude = motion?.attitude else { return }

            let rollProgression = self.mapInputToProgression(from: inputRange, value: attitude.roll)
            // use a low pass filter to remove any jerky movements
            self.roll = self.lowPassFilter(newValue: rollProgression, oldValue: self.previousRoll, alpha: 0.1)
            print("*** \(self.roll)")
            self.previousRoll = self.roll
        }
    }

    func stopReading() {
        motionManager.stopDeviceMotionUpdates()
    }

    private func mapInputToProgression(from inputRange: ClosedRange<Double>, value: Double) -> Double {
        let clampedValue = max(inputRange.lowerBound, min(value, inputRange.upperBound))
        let inputRangeSize = inputRange.upperBound - inputRange.lowerBound
        let normalizedValue = (clampedValue - inputRange.lowerBound) / inputRangeSize
        return normalizedValue
    }

    private func lowPassFilter(newValue: CGFloat, oldValue: CGFloat, alpha: CGFloat) -> CGFloat {
        return alpha * newValue + (1 - alpha) * oldValue
    }
}
