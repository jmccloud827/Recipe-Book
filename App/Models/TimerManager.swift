import AlarmKit
import SwiftUI

/// Schedules AlarmKit timers for step durations, so a running timer shows up on the Lock Screen,
/// in the Dynamic Island, and in StandBy just like a timer started from the built-in Clock app —
/// and keeps a live, in-app list of them so they're visible without leaving the app either.
@Observable
@MainActor final class TimerManager {
    static let shared = TimerManager()

    enum TimerError: Error {
        case authorizationDenied
    }

    /// A timer this app started, kept around only for as long as AlarmKit still has a matching alarm
    /// scheduled. Timers started in a previous app launch won't reappear here after a relaunch — they
    /// still ring and show on the Lock Screen/Dynamic Island regardless, since that's managed by the
    /// system, not this list.
    struct RunningTimer: Identifiable {
        let id: UUID
        let name: String
        let fireDate: Date
        let stepID: UUID
    }

    private(set) var runningTimers: [RunningTimer] = []

    private init() {
        observeAlarms()
    }

    func startTimer(named name: String, duration: TimeInterval, stepID: UUID) async throws {
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
        let attributes = AlarmAttributes<TimerMetadata>(presentation: presentation, metadata: nil, tintColor: .accent)

        let id = UUID()
        _ = try await AlarmManager.shared.schedule(
            id: id,
            configuration: .timer(duration: duration, attributes: attributes)
        )

        runningTimers.append(RunningTimer(id: id, name: name, fireDate: Date.now.addingTimeInterval(duration), stepID: stepID))
    }

    func stopTimer(id: UUID) {
        try? AlarmManager.shared.stop(id: id)
        runningTimers.removeAll { $0.id == id }
    }

    /// Drops any timer from the list once AlarmKit no longer has a matching alarm — e.g. it was
    /// stopped from the Lock Screen/Dynamic Island instead of from here.
    private func observeAlarms() {
        Task {
            for await alarms in AlarmManager.shared.alarmUpdates {
                let activeIDs = Set(alarms.map(\.id))
                runningTimers.removeAll { !activeIDs.contains($0.id) }
            }
        }
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
