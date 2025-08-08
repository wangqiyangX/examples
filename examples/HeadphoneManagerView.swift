//
//  HeadphoneManagerView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import CoreMotion
import SwiftUI
import os.log

extension CMHeadphoneActivityManager.Status {
    var display: String {
        switch self {
        case .disconnected:
            String(localized: "Not connected")
        case .connected:
            String(localized: "Connected")
        @unknown default:
            String(localized: "Unknown")
        }
    }
}

extension CMMotionActivity {
    var deviceActivityType: String {
        if self.stationary {
            return String(localized: "Stationary")
        }
        if self.walking {
            return String(localized: "Walking")
        }
        if self.running {
            return String(localized: "Running")
        }
        if self.automotive {
            return String(localized: "Automotive")
        }
        if self.cycling {
            return String(localized: "Cycling")
        }
        if self.unknown {
            return String(localized: "Unknown")
        }
        return String(localized: "Other moving")
    }
}

extension CMMagneticFieldCalibrationAccuracy {
    var display: String {
        switch self {
        case .uncalibrated:
            String(localized: "Uncalibrated")
        case .low:
            String(localized: "Low")
        case .medium:
            String(localized: "Medium")
        case .high:
            String(localized: "High")
        @unknown default:
            String(localized: "Unknown")
        }
    }
}

extension CMDeviceMotion.SensorLocation {
    var display: String {
        switch self {
        case .default:
            String(localized: "Default")
        case .headphoneLeft:
            String(localized: "Headphone Left")
        case .headphoneRight:
            String(localized: "Headphone Right")
        @unknown default:
            String(localized: "Unknown")
        }
    }
}

class UnitMagneticField: Dimension, @unchecked Sendable {
    // 定义基本单位（特斯拉）
    static let tesla = UnitMagneticField(
        symbol: "T",
        converter: UnitConverterLinear(coefficient: 1.0)
    )
    static let millitesla = UnitMagneticField(
        symbol: "mT",
        converter: UnitConverterLinear(coefficient: 1e-3)
    )
    static let microtesla = UnitMagneticField(
        symbol: "μT",
        converter: UnitConverterLinear(coefficient: 1e-6)
    )
    static let gauss = UnitMagneticField(
        symbol: "G",
        converter: UnitConverterLinear(coefficient: 1e-4)
    )

    override class func baseUnit() -> Self {
        self.tesla as! Self
    }
}

@Observable
class HeadphoneManagerViewModel {
    fileprivate var headphoneActivityManager = CMHeadphoneActivityManager()
    fileprivate var headphoneMotionManager = CMHeadphoneMotionManager()

    var deviceActivity: CMMotionActivity?
    var deviceMotion: CMDeviceMotion?
    var deviceStatus: CMHeadphoneActivityManager.Status = .disconnected

    var isEnabledActivity: Bool = false {
        didSet {
            if self.isEnabledActivity {
                self.startUpdatingStatus()
                self.startUpdatingActivity()
            } else {
                self.stopUpdatingActivity()
            }
        }
    }

    var isEnabledMotion: Bool = false {
        didSet {
            if self.isEnabledMotion {
                self.startUpdatingMotion()
            } else {
                self.stopUpdatingMotion()
            }
        }
    }

    deinit {
        self.stopUpdatingActivity()
        self.stopUpdatingMotion()
    }

    // MARK: - Process Activity
    private func startUpdatingActivity() {
        guard self.headphoneActivityManager.isActivityAvailable else {
            os_log(.error, "Headphone activity is not available!")
            return
        }
        self.headphoneActivityManager.startActivityUpdates(
            to: .main
        ) {
            activity,
            error in
            if error != nil {
                os_log(
                    .error,
                    "Couldn't get activity update: %{public}",
                    error!.localizedDescription
                )
                return
            }
            self.deviceActivity = activity
        }
    }

    private func stopUpdatingActivity() {
        self.headphoneActivityManager.stopActivityUpdates()
    }

    // MARK: - Process Motion
    private func startUpdatingMotion() {
        guard self.headphoneMotionManager.isDeviceMotionAvailable else {
            os_log(.error, "Headphone motion is not available!")
            return
        }

        self.headphoneMotionManager.startDeviceMotionUpdates(to: .main) {
            motion,
            error in
            if let error = error {
                os_log(
                    .error,
                    "Couldn't get motion update: %{public}@",
                    error.localizedDescription
                )
                return
            }
            self.deviceMotion = motion
        }
    }

    private func stopUpdatingMotion() {
        self.headphoneMotionManager.stopDeviceMotionUpdates()
    }

    // MARK: - Process Status
    private func startUpdatingStatus() {
        guard self.headphoneActivityManager.isStatusAvailable else {
            os_log(.error, "Headphone status is not available!")
            return
        }
        self.headphoneActivityManager.startStatusUpdates(to: .main) {
            status,
            error in
            guard error == nil else {
                os_log(
                    .error,
                    "Couldn't get status update: %{public}@",
                    error!.localizedDescription
                )
                return
            }
            self.deviceStatus = status
        }
    }
}

enum ListContentType: CaseIterable, Identifiable {
    case demo
    case data

    var id: Self { self }

    var displayName: String {
        switch self {
        case .demo:
            String(localized: "Demo")
        case .data:
            String(localized: "Data")
        }
    }
}

struct HeadphoneManagerView: View {
    @State private var viewModel = HeadphoneManagerViewModel()
    @State private var selectedListType: ListContentType = .data

    var body: some View {
        List {
            Section("Activity") {
                if viewModel.headphoneActivityManager.isActivityAvailable {
                    Toggle(
                        "Enable Activity Monitoring",
                        isOn: $viewModel.isEnabledActivity
                    )
                    if viewModel.isEnabledActivity {
                        LabeledContent(
                            "Status",
                            value: viewModel.deviceStatus.display
                        )
                        if let activity = viewModel.deviceActivity {
                            LabeledContent(
                                "Activity Type",
                                value: activity.deviceActivityType
                            )
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Headphone Activity not Available",
                        systemImage: "exclamationmark.circle"
                    )
                }
            }

            Section {
                if viewModel.headphoneMotionManager.isDeviceMotionAvailable {
                    Toggle(
                        "Enable Motion Monitoring",
                        isOn: $viewModel.isEnabledMotion
                    )
                    if viewModel.isEnabledMotion && selectedListType == .demo {
                        if let motion = viewModel.deviceMotion {
                            Image(systemName: "face.smiling.inverse")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .frame(maxWidth: .infinity, alignment: .center)
                                // picth 绕 x 轴旋转，点头
                                .rotation3DEffect(
                                    .degrees(motion.attitude.pitch * 180),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                                // roll 绕 y 轴旋转，摇头
                                .rotation3DEffect(
                                    .degrees(motion.attitude.roll * 180),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                // yaw 绕 z 轴旋转，歪头
                                .rotation3DEffect(
                                    .degrees(motion.attitude.yaw * 180),
                                    axis: (x: 0, y: 0, z: 1)
                                )
                        }
                    }
                    if viewModel.isEnabledMotion && selectedListType == .data {
                        if let motion = viewModel.deviceMotion {
                            DisclosureGroup("Attitude") {
                                LabeledContent(
                                    "Roll",
                                    value: motion.attitude.roll,
                                    format: .number
                                )
                                LabeledContent(
                                    "Pitch",
                                    value: motion.attitude.pitch,
                                    format: .number
                                )
                                LabeledContent(
                                    "Yaw",
                                    value: motion.attitude.yaw,
                                    format: .number
                                )
                            }
                            DisclosureGroup("Rotation Rate") {
                                LabeledContent(
                                    "X-axis",
                                    value: motion.rotationRate.x,
                                    format: .number
                                )
                                LabeledContent(
                                    "Y-axis",
                                    value: motion.rotationRate.y,
                                    format: .number
                                )
                                LabeledContent(
                                    "Z-axis",
                                    value: motion.rotationRate.z,
                                    format: .number
                                )
                            }
                            DisclosureGroup("Gravity") {
                                LabeledContent(
                                    "X-axis",
                                    value: Measurement(
                                        value: motion.gravity.x,
                                        unit: UnitAcceleration.gravity
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Y-axis",
                                    value: Measurement(
                                        value: motion.gravity.y,
                                        unit: UnitAcceleration.gravity
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Z-axis",
                                    value: Measurement(
                                        value: motion.gravity.z,
                                        unit: UnitAcceleration.gravity
                                    ).formatted()
                                )
                            }
                            DisclosureGroup("User Acceleration") {
                                LabeledContent(
                                    "X-axis",
                                    value: Measurement(
                                        value: motion.userAcceleration.x,
                                        unit: UnitAcceleration
                                            .metersPerSecondSquared
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Y-axis",
                                    value: Measurement(
                                        value: motion.userAcceleration.y,
                                        unit: UnitAcceleration
                                            .metersPerSecondSquared
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Z-axis",
                                    value: Measurement(
                                        value: motion.userAcceleration.z,
                                        unit: UnitAcceleration
                                            .metersPerSecondSquared
                                    ).formatted()
                                )
                            }
                            DisclosureGroup("Magnetic Field") {
                                LabeledContent(
                                    "X-axis",
                                    value: Measurement(
                                        value: motion.magneticField.field.x,
                                        unit: UnitMagneticField.microtesla
                                    ).formatted()
                                )
                                LabeledContent(
                                    "X-axis",
                                    value: motion.magneticField.field.x,
                                    format: .number
                                )
                                LabeledContent(
                                    "Y-axis",
                                    value: Measurement(
                                        value: motion.magneticField.field.y,
                                        unit: UnitMagneticField.microtesla
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Z-axis",
                                    value: Measurement(
                                        value: motion.magneticField.field.z,
                                        unit: UnitMagneticField.microtesla
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Accuracy",
                                    value: motion.magneticField.accuracy.display
                                )
                            }
                            LabeledContent(
                                "Heading",
                                value: Measurement(
                                    value: motion.heading,
                                    unit: UnitAngle.degrees
                                ).formatted()
                            )
                            LabeledContent(
                                "Sensor Location",
                                value: motion.sensorLocation.display
                            )
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Headphone Motion not Available",
                        systemImage: "exclamationmark.circle"
                    )
                }
            } header: {
                HStack {
                    Text("Motion")
                    Spacer()
                    Picker("Type", selection: $selectedListType) {
                        ForEach(ListContentType.allCases) { type in
                            Text(type.displayName)
                        }
                    }
                }
            }
        }
        .navigationTitle("Headphone Manager")
    }
}

#Preview {
    HeadphoneManagerView()
}
