//
//  AlarmKitSampleLiveActivity.swift
//  AlarmKitSample
//
//  Created by wangqiyang on 2025/8/10.
//

import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI
import WidgetKit

struct AlarmKitSampleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CustomData>.self) {
            context in
            // The Lock Screen presentation.
            lockScreenView(attributes: context.attributes, state: context.state)
        } dynamicIsland: { context in
            // The presentations that appear in the Dynamic Island.
            DynamicIsland {
                // The expanded Dynamic Island presentation.
                DynamicIslandExpandedRegion(.leading) {
                    alarmTitle(
                        attributes: context.attributes,
                        state: context.state
                    )
                }
                DynamicIslandExpandedRegion(.trailing) {
//                    cookingMethod(metadata: context.attributes.metadata)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    bottomView(
                        attributes: context.attributes,
                        state: context.state
                    )
                }
            } compactLeading: {
                // The compact leading presentation.
                countdown(state: context.state, isCompactView: true)
                    .foregroundStyle(context.attributes.tintColor)
            } compactTrailing: {
                // The compact trailing presentation.
                AlarmProgressView(
                    mode: context.state.mode,
                    tint: context.attributes.tintColor
                )
            } minimal: {
                // The minimal presentation.
                AlarmProgressView(
                    mode: context.state.mode,
                    tint: context.attributes.tintColor
                )
            }
            .keylineTint(context.attributes.tintColor)
        }
    }

    func lockScreenView(
        attributes: AlarmAttributes<CustomData>,
        state: AlarmPresentationState
    ) -> some View {
        VStack {
            HStack(alignment: .top) {
                alarmTitle(attributes: attributes, state: state)
                Spacer()
            }

            bottomView(attributes: attributes, state: state)
        }
        .padding(.all, 12)
    }

    func bottomView(
        attributes: AlarmAttributes<CustomData>,
        state: AlarmPresentationState
    ) -> some View {
        HStack {
            countdown(state: state, isCompactView: false)
                .font(.system(size: 40, design: .rounded))
            Spacer()
            AlarmControls(presentation: attributes.presentation, state: state)
        }
    }

    func countdown(state: AlarmPresentationState, isCompactView: Bool)
        -> some View
    {
        Group {
            switch state.mode {
            case .countdown(let countdown):
                Text(
                    timerInterval: Date.now...countdown.fireDate,
                    countsDown: true
                )
            case .paused(let state):
                let remaining = Duration.seconds(
                    state.totalCountdownDuration
                        - state.previouslyElapsedDuration
                )
                let pattern: Duration.TimeFormatStyle.Pattern =
                    remaining > .seconds(60 * 60)
                    ? .hourMinuteSecond : .minuteSecond
                Text(remaining.formatted(.time(pattern: pattern)))
            default:
                if isCompactView {
                    EmptyView()
                } else {
                    Text("Alert")
                }
            }
        }
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: isCompactView ? 44 : 150, alignment: .leading)
    }

    @ViewBuilder func alarmTitle(
        attributes: AlarmAttributes<CustomData>,
        state: AlarmPresentationState
    ) -> some View {
        let title: LocalizedStringResource? =
            switch state.mode {
            case .countdown:
                attributes.presentation.countdown?.title
            case .paused:
                attributes.presentation.paused?.title
            default:
                attributes.presentation.alert.title
            }

        Text(title ?? "")
            .font(.title3)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.leading, 6)
    }
}

struct AlarmProgressView: View {
//    var cookingMethod: CookingData.Method?
    var mode: AlarmPresentationState.Mode
    var tint: Color
    
    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                ProgressView(
                    timerInterval: Date.now ... countdown.fireDate,
                    countsDown: true,
                    label: { EmptyView() },
                    currentValueLabel: {
//                        Image(systemName: cookingMethod?.rawValue ?? "")
//                            .scaleEffect(0.9)
                    })
            case .paused(let pausedState):
                let remaining = pausedState.totalCountdownDuration - pausedState.previouslyElapsedDuration
                ProgressView(value: remaining,
                             total: pausedState.totalCountdownDuration,
                             label: { EmptyView() },
                             currentValueLabel: {
                    Image(systemName: "pause.fill")
                        .scaleEffect(0.8)
                })
            default:
                EmptyView()
            }
        }
        .progressViewStyle(.circular)
        .foregroundStyle(tint)
        .tint(tint)
    }
}

struct AlarmControls: View {
    var presentation: AlarmPresentation
    var state: AlarmPresentationState

    var body: some View {
        HStack(spacing: 4) {
            switch state.mode {
            case .countdown:
                ButtonView(
                    config: presentation.countdown?.pauseButton,
                    intent: PauseIntent(alarmID: state.alarmID.uuidString),
                    tint: .orange
                )
            case .paused:
                ButtonView(
                    config: presentation.paused?.resumeButton,
                    intent: ResumeIntent(alarmID: state.alarmID.uuidString),
                    tint: .orange
                )
            default:
                EmptyView()
            }

            ButtonView(
                config: presentation.alert.stopButton,
                intent: StopIntent(alarmID: state.alarmID.uuidString),
                tint: .red
            )
        }
    }
}

struct ButtonView<I>: View where I: AppIntent {
    var config: AlarmButton
    var intent: I
    var tint: Color

    init?(config: AlarmButton?, intent: I, tint: Color) {
        guard let config else { return nil }
        self.config = config
        self.intent = intent
        self.tint = tint
    }

    var body: some View {
        Button(intent: intent) {
            Label(config.text, systemImage: config.systemImageName)
                .lineLimit(1)
        }
        .tint(tint)
        .buttonStyle(.borderedProminent)
        .frame(width: 96, height: 30)
    }
}
