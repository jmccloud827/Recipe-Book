import SwiftUI

/// The recipe's running timer(s), meant to be pinned to the top of the screen (via `.safeAreaInset`)
/// so they stay visible no matter how far you scroll through the steps.
struct ActiveTimersView: View {
    let stepIDs: Set<UUID>

    private let manager = TimerManager.shared

    private var timers: [TimerManager.RunningTimer] {
        manager.runningTimers.filter { stepIDs.contains($0.stepID) }
    }

    var body: some View {
        if !timers.isEmpty {
            VStack(spacing: 10) {
                ForEach(timers) { timer in
                    row(for: timer)
                }
            }
            .padding(.horizontal)
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
    ActiveTimersView(stepIDs: [UUID()])
}
