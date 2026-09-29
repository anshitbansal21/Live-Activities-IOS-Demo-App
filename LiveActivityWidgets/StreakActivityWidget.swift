import ActivityKit
import SwiftUI
import WidgetKit

struct StreakActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StreakActivityAttributes.self) { context in
            StreakLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(StreakLockScreenView.background)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let tint = context.state.isSafe ? StreakLockScreenView.safeAccent : StreakLockScreenView.accent
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 5) {
                        Image(systemName: context.state.isSafe ? "checkmark.seal.fill" : "flame.fill")
                            .foregroundStyle(tint)
                        Text("\(context.state.currentStreak)")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                    }
                    .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(timerInterval: liveCountdownRange(to: context.state.deadline), countsDown: true)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .frame(maxWidth: 74)
                        Text(context.state.isSafe ? "safe until" : "streak ends")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.motivation)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 3) {
                        ProgressView(
                            value: Double(context.state.completedMinutes),
                            total: Double(max(context.state.goalMinutes, 1))
                        )
                        .tint(tint)
                        Text("\(context.state.completedMinutes) of \(context.state.goalMinutes) minutes of \(context.attributes.skillName)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 6)
                }
            } compactLeading: {
                Image(systemName: context.state.isSafe ? "checkmark.seal.fill" : "flame.fill")
                    .foregroundStyle(tint)
            } compactTrailing: {
                Text("\(context.state.completedMinutes)/\(context.state.goalMinutes)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(tint)
            } minimal: {
                Image(systemName: context.state.isSafe ? "checkmark.seal.fill" : "flame.fill")
                    .foregroundStyle(tint)
            }
            .keylineTint(tint)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}
