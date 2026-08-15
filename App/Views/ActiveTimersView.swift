import SwiftUI

/// The running timer(s) for a single step, shown right above that step so they're visible in-app
/// without checking the Lock Screen or Dynamic Island.
struct ActiveTimersView: View {
    let stepID: UUID

    private let manager = TimerManager.shared

    private var timers: [TimerManager.RunningTimer] {
        manager.runningTimers.filter { $0.stepID == stepID }
    }

    var body: some View {
        if !timers.isEmpty {
            VStack(spacing: 10) {
                ForEach(timers) { timer in
                    row(for: timer)
                }
            }
        }
    }

    private func row(for timer: TimerManager.RunningTimer) -> some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.accent)

            Text(timer.name)
                .lineLimit(1)

            Spacer()

            countdown(for: timer)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.accent)

            Button {
                manager.stopTimer(id: timer.id)
            } label: {
                Image(systemName: "stop.fill")
            }
            .buttonStyle(.borderless)
            .tint(.red)
        }
        .padding(20)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
    }

    @ViewBuilder
    private func countdown(for timer: TimerManager.RunningTimer) -> some View {
        if timer.fireDate > .now {
            Text(timerInterval: Date.now ... timer.fireDate, countsDown: true)
        } else {
            Text("Done")
        }
    }
}

#Preview {
    ActiveTimersView(stepID: UUID())
}
