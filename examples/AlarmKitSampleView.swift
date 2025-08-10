//
//  AlarmKitSampleView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/9.
//

import AlarmKit
import AppIntents
import OSLog
import SwiftUI

struct PauseIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.pause(id: UUID(uuidString: alarmID)!)
        return .result()
    }

    static let title: LocalizedStringResource = "Pause"
    static let description = IntentDescription("Pause a countdown")

    @Parameter(title: "alarmID")
    var alarmID: String

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    init() {
        self.alarmID = ""
    }
}

struct RepeatIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.countdown(id: UUID(uuidString: alarmID)!)
        return .result()
    }

    static let title: LocalizedStringResource = "Repeat"
    static let description = IntentDescription("Repeat a countdown")

    @Parameter(title: "alarmID")
    var alarmID: String

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    init() {
        self.alarmID = ""
    }
}

struct ResumeIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.resume(id: UUID(uuidString: alarmID)!)
        return .result()
    }

    static let title: LocalizedStringResource = "Resume"
    static let description = IntentDescription("Resume a countdown")

    @Parameter(title: "alarmID")
    var alarmID: String

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    init() {
        self.alarmID = ""
    }
}

struct OpenAlarmAppIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.stop(id: UUID(uuidString: alarmID)!)
        return .result()
    }

    static let title: LocalizedStringResource = "Open App"
    static let description = IntentDescription("Opens the Sample app")
    static let supportedModes = IntentModes.foreground(.immediate)
    static let isDiscoverable = false

    @Parameter(title: "alarmID")
    var alarmID: String

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    init() {
        self.alarmID = ""
    }
}

struct StopIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.stop(id: UUID(uuidString: alarmID)!)
        return .result()
    }

    static let title: LocalizedStringResource = "Stop"
    static let description = IntentDescription("Stop an alert")

    @Parameter(title: "alarmID")
    var alarmID: String

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    init() {
        self.alarmID = ""
    }
}

struct CustomData: AlarmMetadata {
    var createdAt: Date = .now
}

extension Alarm.Schedule {
    static var tenSecondsFromNow: Self {
        let tenSecondsFromNow = Date.now.addingTimeInterval(10)
        let time = Alarm.Schedule.Relative.Time(
            hour: Calendar.current.component(.hour, from: tenSecondsFromNow),
            minute: Calendar.current.component(.minute, from: tenSecondsFromNow)
        )
        return .relative(.init(time: time))
    }
}

extension Alarm.State {
    var display: String {
        switch self {
        case .scheduled:
            String(localized: "Scheduled")
        case .countdown:
            String(localized: "Countdown")
        case .paused:
            String(localized: "Paused")
        case .alerting:
            String(localized: "Alerting")
        @unknown default:
            String(localized: "Unknown")
        }
    }
}

extension Alarm {
    var alertingTime: Date? {
        guard let schedule else { return nil }

        switch schedule {
        case .fixed(let date):
            return date
        case .relative(let relative):
            var components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: Date()
            )
            components.hour = relative.time.hour
            components.minute = relative.time.minute
            return Calendar.current.date(from: components)
        @unknown default:
            return nil
        }
    }
}

extension AlarmButton {
    static var openAppButton: Self {
        AlarmButton(text: "Open", textColor: .black, systemImageName: "swift")
    }

    static var pauseButton: Self {
        AlarmButton(
            text: "Pause",
            textColor: .black,
            systemImageName: "pause.fill"
        )
    }

    static var resumeButton: Self {
        AlarmButton(
            text: "Start",
            textColor: .black,
            systemImageName: "play.fill"
        )
    }

    static var repeatButton: Self {
        AlarmButton(
            text: "Repeat",
            textColor: .black,
            systemImageName: "repeat.circle"
        )
    }

    static var snoozeButton: Self {
        AlarmButton(
            text: "Snooze",
            textColor: .black,
            systemImageName: "zzz"
        )
    }

    static var stopButton: Self {
        AlarmButton(
            text: "Done",
            textColor: .white,
            systemImageName: "stop.circle"
        )
    }
}

extension Locale {
    var orderedWeekdays: [Locale.Weekday] {
        let days: [Locale.Weekday] = [
            .sunday, .monday, .tuesday, .wednesday, .thursday, .friday,
            .saturday,
        ]
        if let firstDayIdx = days.firstIndex(of: firstDayOfWeek),
            firstDayIdx != 0
        {
            return Array(days[firstDayIdx...] + days[0..<firstDayIdx])
        }
        return days
    }

}

extension Locale.Weekday {
    var weekdayNumber: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        @unknown default:
            fatalError()
        }
    }

    func localizedFullName(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        // weekdaySymbols 数组索引是 weekdayNumber-1
        return formatter.weekdaySymbols[self.weekdayNumber - 1]
    }

    func localizedShortName(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.shortWeekdaySymbols[self.weekdayNumber - 1]
    }
}

struct AlarmData {
    var id: UUID
    var alarm: Alarm
    var label: LocalizedStringResource
    var type: AlarmDataType
    var enable: Bool

    init(
        id: UUID,
        alarm: Alarm,
        label: LocalizedStringResource,
        type: AlarmDataType,
        enable: Bool = true
    ) {
        self.id = id
        self.alarm = alarm
        self.label = label
        self.type = type
        self.enable = enable
    }
}

@Observable
class AlarmKitSampleViewModel {
    fileprivate let logger = Logger(
        subsystem: "com.wangqiyang.examples",
        category: "AlamKitSampleViewModel"
    )

    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CustomData>
    typealias AlarmsMap = [UUID: (Alarm, LocalizedStringResource)]

    @MainActor var alarmDataList: [AlarmData] = []
    @MainActor var alarmsMap = AlarmsMap()
    @MainActor var hasUpcomingAlerts: Bool {
        //        !alarmsMap.isEmpty
        !alarmDataList.isEmpty
    }
    @ObservationIgnored let alarmManager = AlarmManager.shared

    init() {
        observeAlarms()
    }

    private func observeAlarms() {
        Task {
            for await incomingAlarms in alarmManager.alarmUpdates {
                logger.debug("IncomingAlarms: \(incomingAlarms.count)")
                updateAlarmState(with: incomingAlarms)
            }
        }
    }

    private func updateAlarmState(with remoteAlarms: [Alarm]) {
        Task { @MainActor in

            // Update existing alarm states.
            remoteAlarms.forEach { updated in
                if let targetID = alarmDataList.firstIndex(where: { data in
                    data.id == updated.id
                }) {
                    logger.debug("Updated Alarm.")
                    alarmDataList[targetID].alarm = updated
                } else {
                    logger.debug("Added Alarm.")
                    alarmDataList.append(
                        .init(
                            id: updated.id,
                            alarm: updated,
                            label: "Alarm (Old Session)",
                            type: .alarm
                        )
                    )
                }
                //                alarmsMap[
                //                    updated.id,
                //                    default: (updated, "Alarm (Old Session)")
                //                ]
                //                .0 = updated
            }
            //            let knownAlarmIDs = Set(alarmsMap.keys)
            //            let incomingAlarmIDs = Set(remoteAlarms.map(\.id))
        }
    }

    private func secondaryIntent(alarmID: UUID, userInput: AlarmForm) -> (
        any LiveActivityIntent
    )? {
        guard let behavior = userInput.secondaryButtonBehavior else {
            return nil
        }

        switch behavior {
        case .countdown:
            return RepeatIntent(alarmID: alarmID.uuidString)
        case .custom:
            return OpenAlarmAppIntent(alarmID: alarmID.uuidString)
        @unknown default:
            return nil
        }
    }

    func requestAuthorization() async {
        do {
            _ = try await alarmManager.requestAuthorization()
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }

    func scheduleAlertOnlyExample() {
        let alertContent = AlarmPresentation.Alert(
            title: "Wake Up",
            stopButton: AlarmButton(
                text: "Done",
                textColor: .white,
                systemImageName: "stop.circle"
            )
        )
        let attributes = AlarmAttributes<CustomData>(
            presentation: AlarmPresentation(alert: alertContent),
            tintColor: Color.accentColor
        )

        let alarmConfiguration = AlarmManager.AlarmConfiguration<CustomData>(
            schedule: .tenSecondsFromNow,
            attributes: attributes
        )

        scheduleAlarm(
            id: UUID(),
            label: "Wake Up",
            alarmConfiguration: alarmConfiguration
        )
    }

    private func alarmPresentation(with userInput: AlarmForm)
        -> AlarmPresentation
    {
        let secondaryButtonBehavior = userInput.secondaryButtonBehavior
        let secondaryButton: AlarmButton? =
            switch secondaryButtonBehavior {
            case .countdown: .snoozeButton
            case .custom: .openAppButton
            default: nil
            }

        let alertContent = AlarmPresentation.Alert(
            title: userInput.localizedLabel,
            stopButton: .stopButton,
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: secondaryButtonBehavior
        )

        guard userInput.countdownDuration != nil else {
            print("An alarm without a countdown only specifies an alert state.")
            return AlarmPresentation(alert: alertContent)
        }

        // With countdown enabled, a presentation appears for both a countdown and paused state.
        let countdownContent = AlarmPresentation.Countdown(
            title: userInput.localizedLabel,
            pauseButton: .pauseButton
        )

        let pausedContent = AlarmPresentation.Paused(
            title: "Paused",
            resumeButton: .resumeButton
        )

        return AlarmPresentation(
            alert: alertContent,
            countdown: countdownContent,
            paused: pausedContent
        )
    }

    func scheduleAlarm(with userInput: AlarmForm) {
        let attributes = AlarmAttributes(
            presentation: alarmPresentation(with: userInput),
            metadata: CustomData(),
            tintColor: Color.accentColor
        )

        let id = UUID()

        let alarmConfiguration = AlarmConfiguration(
            countdownDuration: userInput.countdownDuration,
            schedule: userInput.schedule,
            attributes: attributes,
            stopIntent: StopIntent(alarmID: id.uuidString),
            secondaryIntent: OpenAlarmAppIntent(alarmID: id.uuidString)
        )

        scheduleAlarm(
            id: id,
            label: userInput.localizedLabel,
            alarmConfiguration: alarmConfiguration
        )
    }

    func scheduleAlarm(
        id: UUID,
        label: LocalizedStringResource,
        alarmConfiguration: AlarmConfiguration
    ) {
        Task {
            do {
                guard alarmManager.authorizationState == .authorized else {
                    return
                }
                let alarm = try await alarmManager.schedule(
                    id: id,
                    configuration: alarmConfiguration
                )
                await MainActor.run {
                    //                    alarmsMap[id] = (alarm, label)
                    //                    alarmDataList.append(
                    //                        .init(
                    //                            id: id,
                    //                            alarm: alarm,
                    //                            label: label,
                    //                            type: .alarm
                    //                        )
                    //                    )
                    if let targetID = alarmDataList.firstIndex(where: { data in
                        data.id == id
                    }) {
                        logger.debug("Updated Alarm.")
                        alarmDataList[targetID].alarm = alarm
                        alarmDataList[targetID].label = label
                    } else {
                        logger.debug("Added Alarm.")
                        alarmDataList.append(
                            .init(
                                id: id,
                                alarm: alarm,
                                label: label,
                                type: .alarm
                            )
                        )
                    }
                }
            } catch {
                print("Error encountered when scheduling alarm: \(error)")
            }
        }
    }

    func unscheduleAlarm(with alarmID: UUID) {
        do {
            try alarmManager.cancel(id: alarmID)
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
}

extension AlarmManager.AuthorizationState {
    var display: String {
        switch self {
        case .notDetermined:
            String(localized: "Not determined")
        case .denied:
            String(localized: "Denied")
        case .authorized:
            String(localized: "Authorized")
        @unknown default:
            String(localized: "Unknown")
        }
    }
}

struct AlarmKitSampleView: View {
    @State private var viewModel = AlarmKitSampleViewModel()
    @State private var showAddSheet = false
    @State private var selectedAlarmType: AlarmDataType = .alarm

    var body: some View {
        content
            .navigationSubtitle(
                viewModel.alarmManager.authorizationState.display
            )
            .toolbar {
                EditButton()
                Button {
                    withAnimation {
                        showAddSheet.toggle()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AlarmAddView()
            }
            .task {
                await viewModel.requestAuthorization()
            }
            .environment(viewModel)
    }

    @ViewBuilder
    var content: some View {
        if viewModel.hasUpcomingAlerts {
            List {
                Picker("Type", selection: $selectedAlarmType) {
                    ForEach(AlarmDataType.allCases, id: \.self) { type in
                        Text(type.display)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Section {
                    ForEach(viewModel.alarmDataList, id: \.id) { data in
                        AlarmCellView(alarm: data.alarm, label: data.label)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { idx in
                            viewModel.unscheduleAlarm(
                                with: viewModel.alarmDataList[idx].id
                            )
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "No Alarms",
                systemImage: "clock.badge.exclamationmark",
                description: Text("Add a new alarm by tapping + button.")
            )
        }
    }
}

struct AlarmCellView: View {
    let alarm: Alarm
    let label: LocalizedStringResource

    @State private var enable: Bool = true

    var body: some View {
        LabeledContent {
            Toggle("", isOn: $enable)
                .labelsHidden()
        } label: {
            if let alertingTime = alarm.alertingTime {
                Text(alertingTime, style: .time)
                    .font(.title)
                    .bold()
            }
            HStack {
                Text(label)
                Text(alarm.state.display)
            }
        }
    }
}

enum AlarmDataType: String, CaseIterable {
    case alarm = "Alarm"
    case timer = "Timer"

    var display: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: self.rawValue)
    }
}

struct AlarmForm {
    var selectedAlarmType: AlarmDataType = .alarm

    var label = ""
    var selectedDate = Date.now
    var selectedDays = Set<Locale.Weekday>()

    var formattedWeekdaysList: String {
        let names = self.selectedDays.map { $0.localizedShortName() }
        switch names.count {
        case 0:
            return "Never"
        case 1:
            return names[0]
        case 2:
            return names.joined(separator: " and ")
        case 7:
            return "Every day"
        default:
            let allButLast = names.dropLast().joined(separator: ", ")
            let last = names.last!
            return "\(allButLast), and \(last)"
        }
    }

    func isSelected(day: Locale.Weekday) -> Bool {
        selectedDays.contains(day)
    }
    var postAlertEnabled = false
    var showPreAlertPicker: Bool = false
    var showPostAlertPicker: Bool = false
    var selectedPreAlert = CountdownInterval()
    var selectedPostAlert = CountdownInterval()

    var schedule: Alarm.Schedule? {
        let dateComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: selectedDate
        )

        guard let hour = dateComponents.hour, let minute = dateComponents.minute
        else { return nil }

        let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
        return .relative(
            .init(
                time: time,
                repeats: selectedDays.isEmpty
                    ? .never : .weekly(Array(selectedDays))
            )
        )
    }

    var localizedLabel: LocalizedStringResource {
        label.isEmpty
            ? LocalizedStringResource("Alarm")
            : LocalizedStringResource(stringLiteral: label)
    }

    struct CountdownInterval {
        var hour = 0
        var min = 5
        var sec = 0

        var interval: TimeInterval {
            TimeInterval(hour * 60 * 60 + min * 60 + sec)
        }
    }

    var countdownDuration: Alarm.CountdownDuration? {
        let preAlertCountdown: TimeInterval? =
            if selectedAlarmType == .timer {
                selectedPreAlert.interval
            } else { nil }

        let postAlertCountdown: TimeInterval? =
            if secondaryButtonBehavior == .countdown {
                selectedPostAlert.interval
            } else { nil }

        guard preAlertCountdown != nil || postAlertCountdown != nil else {
            return nil
        }

        return .init(preAlert: preAlertCountdown, postAlert: postAlertCountdown)
    }

    enum SecondaryButtonOption: String, CaseIterable {
        case none = "None"
        case countdown = "Countdown"
        case openApp = "Open App"

        var display: LocalizedStringResource {
            LocalizedStringResource(stringLiteral: self.rawValue)
        }
    }

    var selectedSecondaryButton: SecondaryButtonOption = .none
    var secondaryButtonBehavior:
        AlarmPresentation.Alert.SecondaryButtonBehavior?
    {
        selectedAlarmType == .alarm && postAlertEnabled ? .countdown : nil
    }
}

struct AlarmAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AlarmKitSampleViewModel.self) private var viewModel
    @State private var userInput = AlarmForm()

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $userInput.selectedAlarmType) {
                    ForEach(AlarmDataType.allCases, id: \.self) { type in
                        Text(type.display)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)

                if userInput.selectedAlarmType == .alarm {
                    DatePicker(
                        "",
                        selection: $userInput.selectedDate,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                    NavigationLink {
                        List {
                            ForEach(
                                Locale.autoupdatingCurrent.orderedWeekdays,
                                id: \.self
                            ) {
                                weekday in
                                Button(action: {
                                    if userInput.isSelected(day: weekday) {
                                        userInput.selectedDays.remove(weekday)
                                    } else {
                                        userInput.selectedDays.insert(weekday)
                                    }
                                }) {
                                    HStack {
                                        Text(
                                            "Every \(weekday.localizedFullName())"
                                        )
                                        Spacer()
                                        if userInput.isSelected(day: weekday) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                .contentShape(.rect)
                                .tint(.primary)
                            }
                        }
                        .navigationTitle("Repeat")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        LabeledContent(
                            "Repeat",
                            value: userInput.formattedWeekdaysList
                        )
                    }
                    LabeledContent("Label") {
                        TextField("Alarm", text: $userInput.label)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Snooze", isOn: $userInput.postAlertEnabled)
                    if userInput.postAlertEnabled {
                        LabeledContent(
                            "Snooze Duration",
                            value: userInput.selectedPostAlert.min,
                            format: .number
                        )
                        .contentShape(.rect)
                        .onTapGesture {
                            withAnimation {
                                userInput.showPostAlertPicker.toggle()
                            }
                        }
                        if userInput.showPostAlertPicker {
                            Picker(
                                "",
                                selection: $userInput.selectedPostAlert.min
                            ) {
                                ForEach(0...15, id: \.self) {
                                    Text("\($0) min")
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                    }
                } else {
                    TimePickerView(
                        hour: $userInput.selectedPreAlert.hour,
                        min: $userInput.selectedPreAlert.min,
                        sec: $userInput.selectedPreAlert.sec
                    )
                }

                //                Toggle(
                //                    "Countdown (Pre-Alert)",
                //                    isOn: $userInput.preAlertEnabled
                //                )
                //                .onTapGesture {
                //                    withAnimation {
                //                        userInput.showPreAlertPicker.toggle()
                //                    }
                //                }
                //                if userInput.preAlertEnabled && userInput.showPreAlertPicker {
                //                    TimePickerView(
                //                        hour: $userInput.selectedPreAlert.hour,
                //                        min: $userInput.selectedPreAlert.min,
                //                        sec: $userInput.selectedPreAlert.sec
                //                    )
                //                }

                //                Section {
                //                    Picker(
                //                        "Secondary Button",
                //                        selection: $userInput.selectedSecondaryButton
                //                    ) {
                //                        ForEach(
                //                            AlarmForm.SecondaryButtonOption.allCases,
                //                            id: \.self
                //                        ) { button in
                //                            Text(button.display)
                //                                .tag(button)
                //                        }
                //                    }
                //                    if userInput.selectedSecondaryButton == .countdown {
                //                        TimePickerView(
                //                            hour: $userInput.selectedPostAlert.hour,
                //                            min: $userInput.selectedPostAlert.min,
                //                            sec: $userInput.selectedPostAlert.sec
                //                        )
                //                    }
                //                } footer: {
                //                    let callout =
                //                        switch userInput.selectedSecondaryButton {
                //                        case .none:
                //                            "Only the Stop button is displayed in the alarm alert."
                //                        case .countdown:
                //                            "Displays the Repeat option when the alarm is triggered."
                //                        case .openApp:
                //                            "Displays the Open App button when the alarm is triggered."
                //                        }
                //                    Text(callout)
                //                }
            }
            .navigationTitle("Add Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.scheduleAlarm(with: userInput)
                        dismiss()
                    } label: {
                        Label("Add", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    //                    .disabled(!userInput.isValidAlarm)
                }
            }
        }
    }
}

struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var min: Int
    @Binding var sec: Int

    private let labelOffset = 40.0

    var body: some View {
        HStack(spacing: 0) {
            pickerRow(title: "Hr", range: 0..<24, selection: $hour)
                .padding(.trailing, -labelOffset)
                .clipped()
            pickerRow(title: "Min", range: 0..<60, selection: $min)
                .padding(.horizontal, -labelOffset)
                .clipped()
            pickerRow(title: "Sec", range: 0..<60, selection: $sec)
                .padding(.leading, -labelOffset)
                .clipped()
        }
    }

    func pickerRow(title: String, range: Range<Int>, selection: Binding<Int>)
        -> some View
    {
        Picker("", selection: selection) {
            ForEach(range, id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.wheel)
        .overlay {
            Text(title)
                .font(.caption)
                .frame(width: labelOffset, alignment: .leading)
                .offset(x: labelOffset)
        }
    }
}

#Preview {
    NavigationStack {
        AlarmKitSampleView()
    }
}
