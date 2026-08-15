import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI
import WidgetKit

/// Renders a running recipe timer on the Lock Screen, in the Dynamic Island, and in StandBy. AlarmKit
/// requires a widget extension for any alarm that uses a countdown presentation (see
/// `RecipeTimerManager`) — without one, the system can't display the live countdown and may not alert
/// at all.
struct RecipeTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<RecipeTimerMetadata>.self) { context in
            lockScreenView(attributes: context.attributes, state: context.state)
                .padding()
                .background(.black.opacity(0.9))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundStyle(context.attributes.tintColor)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    countdownText(for: context.state)
                        .font(.title2.monospacedDigit())
                        .foregroundStyle(context.attributes.tintColor)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(title(for: context.attributes))
                            .lineLimit(1)

                        Spacer()

                        stopButton(alarmID: context.state.alarmID)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(context.attributes.tintColor)
            } compactTrailing: {
                countdownText(for: context.state)
                    .foregroundStyle(context.attributes.tintColor)
                    .frame(width: 44)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(context.attributes.tintColor)
            }
            .keylineTint(context.attributes.tintColor)
        }
    }

    @ViewBuilder
    private func lockScreenView(attributes: AlarmAttributes<RecipeTimerMetadata>, state: AlarmPresentationState) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title(for: attributes))
                    .font(.headline)

                countdownText(for: state)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(attributes.tintColor)

            Spacer()

            stopButton(alarmID: state.alarmID)
        }
    }

    private func title(for attributes: AlarmAttributes<RecipeTimerMetadata>) -> LocalizedStringResource {
        attributes.presentation.countdown?.title ?? attributes.presentation.alert.title
    }

    @ViewBuilder
    private func countdownText(for state: AlarmPresentationState) -> some View {
        switch state.mode {
        case .countdown(let countdown):
            Text(timerInterval: countdown.startDate...countdown.fireDate, countsDown: true)
        case .alert:
            Text("Done")
        case .paused:
            Text("Paused")
        @unknown default:
            Text("Timer")
        }
    }

    private func stopButton(alarmID: Alarm.ID) -> some View {
        Button(intent: StopRecipeTimerIntent(alarmID: alarmID)) {
            Image(systemName: "stop.fill")
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

/// Lets the Stop button in the Dynamic Island / Lock Screen end the alarm directly, without opening
/// the app.
struct StopRecipeTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop Timer"

    @Parameter(title: "Alarm ID")
    var alarmID: String

    init(alarmID: UUID) {
        self.alarmID = alarmID.uuidString
    }

    init() {
        self.alarmID = ""
    }

    func perform() throws -> some IntentResult {
        if let id = UUID(uuidString: alarmID) {
            try AlarmManager.shared.stop(id: id)
        }

        return .result()
    }
}
