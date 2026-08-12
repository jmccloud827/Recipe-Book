import AlarmKit
import SwiftUI

/// Schedules AlarmKit timers for step durations, so a running timer shows up on the Lock Screen,
/// in the Dynamic Island, and in StandBy just like a timer started from the built-in Clock app.
@MainActor final class RecipeTimerManager {
    static let shared = RecipeTimerManager()

    enum TimerError: Error {
        case authorizationDenied
    }

    /// AlarmKit requires a metadata type even when there's nothing extra to attach to the alarm.
    private nonisolated struct Metadata: AlarmMetadata {}

    private init() {}

    func startTimer(named name: String, duration: TimeInterval) async throws {
        guard try await isAuthorized() else {
            throw TimerError.authorizationDenied
        }

        // As of iOS 26.1, the system supplies its own stop button, so there's no `stopButton` to pass.
        let alert = AlarmPresentation.Alert(
            title: "\(name) is ready!",
            secondaryButton: nil,
            secondaryButtonBehavior: nil
        )
        let countdown = AlarmPresentation.Countdown(title: "\(name)")
        let presentation = AlarmPresentation(alert: alert, countdown: countdown, paused: nil)
        let attributes = AlarmAttributes<Metadata>(presentation: presentation, metadata: nil, tintColor: .accent)

        _ = try await AlarmManager.shared.schedule(
            id: UUID(),
            configuration: .timer(duration: duration, attributes: attributes)
        )
    }

    private func isAuthorized() async throws -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .authorized:
            true
        case .notDetermined:
            try await AlarmManager.shared.requestAuthorization() == .authorized
        case .denied:
            false
        @unknown default:
            false
        }
    }
}
