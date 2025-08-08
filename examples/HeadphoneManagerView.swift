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
            "Not connected"
        case .connected:
            "Connected"
        @unknown default:
            "Unknown"
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
            "Uncalibrated"
        case .low:
            "Low"
        case .medium:
            "Medium"
        case .high:
            "High"
        @unknown default:
            "Unknown"
        }
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
            "Demo"
        case .data:
            "Data"
        }
    }
}

struct HeadphoneManagerView: View {
    @State private var viewModel = HeadphoneManagerViewModel()
    @State private var selectedListType: ListContentType = .demo

    var body: some View {
        List {
            Section("Headphone Activity") {
                Toggle(
                    "Enable Activity Monitoring",
                    isOn: $viewModel.isEnabledActivity
                )
                if viewModel.isEnabledActivity
                    && viewModel.headphoneActivityManager.isActivityAvailable
                {
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
                } else {
                    ContentUnavailableView(
                        "Headphone Activity not Available",
                        systemImage: "xmark"
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
                            DisclosureGroup {
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
                            } label: {
                                Text("Attitude")
                            }
                            DisclosureGroup {
                                LabeledContent(
                                    "X",
                                    value: motion.rotationRate.x,
                                    format: .number
                                )
                                LabeledContent(
                                    "Y",
                                    value: motion.rotationRate.y,
                                    format: .number
                                )
                                LabeledContent(
                                    "Z",
                                    value: motion.rotationRate.z,
                                    format: .number
                                )
                            } label: {
                                Text("Rotation Rate")
                            }
                            DisclosureGroup {
                                LabeledContent(
                                    "X",
                                    value: Measurement(
                                        value: motion.gravity.x,
                                        unit: UnitAcceleration.gravity
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Y",
                                    value: Measurement(
                                        value: motion.gravity.y,
                                        unit: UnitAcceleration.gravity
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Z",
                                    value: Measurement(
                                        value: motion.gravity.z,
                                        unit: UnitAcceleration.gravity
                                    ).formatted()
                                )
                            } label: {
                                Text("Gravity")
                            }
                            DisclosureGroup("User Acceleration") {
                                LabeledContent(
                                    "X",
                                    value: Measurement(
                                        value: motion.userAcceleration.x,
                                        unit: UnitAcceleration
                                            .metersPerSecondSquared
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Y",
                                    value: Measurement(
                                        value: motion.userAcceleration.y,
                                        unit: UnitAcceleration
                                            .metersPerSecondSquared
                                    ).formatted()
                                )
                                LabeledContent(
                                    "Z",
                                    value: Measurement(
                                        value: motion.userAcceleration.z,
                                        unit: UnitAcceleration
                                            .metersPerSecondSquared
                                    ).formatted()
                                )
                            }
                            DisclosureGroup("Magnetic Field") {
                                LabeledContent(
                                    "X",
                                    value: motion.magneticField.field.x,
                                    format: .number
                                )
                                LabeledContent(
                                    "Y",
                                    value: motion.magneticField.field.y,
                                    format: .number
                                )
                                LabeledContent(
                                    "X",
                                    value: motion.magneticField.field.z,
                                    format: .number
                                )
                                LabeledContent(
                                    "Accuracy",
                                    value: motion.magneticField.accuracy.display
                                )
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Headphone Motion not Available",
                        systemImage: "xmark"
                    )
                }
            } header: {
                HStack {
                    Text("Headphone Motion")
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
