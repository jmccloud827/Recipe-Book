import AlarmKit

/// Marker metadata for a recipe timer's alarm. AlarmKit requires a metadata type even when there's
/// nothing extra to attach — the display text the widget shows comes from `AlarmPresentation` itself
/// (see `TimerManager` and `TimerLiveActivity`).
///
/// This file is compiled into both the app target and the `TimerWidget` extension target: the
/// app schedules alarms as `AlarmAttributes<TimerMetadata>`, and the widget extension's Live
/// Activity has to use that exact same generic argument to render them.
nonisolated struct TimerMetadata: AlarmMetadata {}
