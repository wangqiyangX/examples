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

@Observable
class HeadphoneManagerViewModel {
    fileprivate var headphoneActivityManager = CMHeadphoneActivityManager()
    fileprivate var headphoneMotionManager = CMHeadphoneMotionManager()

    var activity: String = "Not started"
    var status: String = "--"
    var motionData: String = "No motion data"

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
            activity = "Activity not avilable!"
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
            self.activity = self.activityHumanReadableDescription(activity!)
        }
    }

    private func stopUpdatingActivity() {
        self.headphoneActivityManager.stopActivityUpdates()
        self.activity = "Not started"
    }

    private func activityHumanReadableDescription(_ activity: CMMotionActivity)
        -> String
    {
        if activity.unknown {
            return "Unknown"
        }
        if activity.stationary {
            return "Stationary"
        }
        if activity.walking {
            return "Walking"
        }
        if activity.running {
            return "Running"
        }
        if activity.automotive {
            return "Automotive"
        }
        // Check if we're on a platform that supports cycling
        #if os(iOS) || os(watchOS)
            if activity.cycling {
                return "Cycling"
            }
        #endif
        return "Other Moving"
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

            if let motion = motion {
                // Format motion data for display
                self.motionData = String(
                    format:
                        "Roll: %.2f, Pitch: %.2f, Yaw: %.2f",
                    motion.attitude.roll,
                    motion.attitude.pitch,
                    motion.attitude.yaw
                )
            }
        }
    }

    private func stopUpdatingMotion() {
        self.headphoneMotionManager.stopDeviceMotionUpdates()
        self.motionData = "No motion data"
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
            self.status = self.statusHumanReadableDescription(status)
            self.deviceStatus = status
        }
    }

    private func statusHumanReadableDescription(
        _ status: CMHeadphoneActivityManager.Status
    )
        -> String
    {
        switch status {
        case .disconnected:
            return "Disconnected"
        case .connected:
            return "Connected"
        @unknown default:
            return "Disconnected"
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
                if viewModel.headphoneActivityManager.isActivityAvailable {
                    LabeledContent(
                        "Status",
                        value: viewModel.deviceStatus.display
                    )

                    Toggle(
                        "Enable Activity",
                        isOn: $viewModel.isEnabledActivity
                    )
                } else {
                    ContentUnavailableView(
                        "Headphone Activity not Available",
                        systemImage: "xmark"
                    )
                }
            }

            Section {
                Toggle("Headphone Motion", isOn: $viewModel.isEnabledMotion)
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
                                    unit: UnitAcceleration
                                        .metersPerSecondSquared
                                ).formatted()
                            )
                            LabeledContent(
                                "Y",
                                value: Measurement(
                                    value: motion.gravity.y,
                                    unit: UnitAcceleration
                                        .metersPerSecondSquared
                                ).formatted()
                            )
                            LabeledContent(
                                "Z",
                                value: Measurement(
                                    value: motion.gravity.z,
                                    unit: UnitAcceleration
                                        .metersPerSecondSquared
                                ).formatted()
                            )
                        } label: {
                            Text("Gravity")
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Enable Headphone Motion")
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
