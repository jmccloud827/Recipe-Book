import AlarmKit

/// Marker metadata for a recipe timer's alarm. AlarmKit requires a metadata type even when there's
/// nothing extra to attach — the display text the widget shows comes from `AlarmPresentation` itself
/// (see `RecipeTimerManager` and `RecipeTimerLiveActivity`).
///
/// This file is compiled into both the app target and the `RecipeTimerWidget` extension target: the
/// app schedules alarms as `AlarmAttributes<RecipeTimerMetadata>`, and the widget extension's Live
/// Activity has to use that exact same generic argument to render them.
nonisolated struct RecipeTimerMetadata: AlarmMetadata {}
