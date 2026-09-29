import ActivityKit
import SwiftUI
import WidgetKit

struct NavigationActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NavigationActivityAttributes.self) { context in
            NavigationLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(NavigationLockScreenView.background)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 7) {
                        Image(systemName: context.state.maneuver.symbol)
                            .font(.system(size: 19, weight: .black))
                            .foregroundStyle(NavigationLockScreenView.accent)
                        Text(context.state.distanceText)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                    }
                    .padding(.leading, 5)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(context.state.arrival, style: .time)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                        Text(context.state.remainingDistanceText)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 5)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.destinationName)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.instruction)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                        if let thenInstruction = context.state.thenInstruction {
                            HStack(spacing: 5) {
                                Text("THEN")
                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.secondary)
                                if let thenManeuver = context.state.thenManeuver {
                                    Image(systemName: thenManeuver.symbol)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.secondary)
                                }
                                Text(thenInstruction)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5)
                }
            } compactLeading: {
                Image(systemName: context.state.maneuver.symbol)
                    .foregroundStyle(NavigationLockScreenView.accent)
            } compactTrailing: {
                Text(context.state.distanceText)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(1)
            } minimal: {
                Image(systemName: context.state.maneuver.symbol)
                    .foregroundStyle(NavigationLockScreenView.accent)
            }
            .keylineTint(NavigationLockScreenView.accent)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}
