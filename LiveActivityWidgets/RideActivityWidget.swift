import ActivityKit
import SwiftUI
import WidgetKit

struct RideActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RideActivityAttributes.self) { context in
            RideLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(RideLockScreenView.background)
                .activitySystemActionForegroundColor(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(context.state.leadValue)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(RideLockScreenView.accent)
                        Text(context.state.leadCaption)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(context.attributes.plate)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                        Text(context.attributes.carDescription)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.subline)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    DottedRouteTrack(
                        progress: context.state.progress,
                        tint: RideLockScreenView.accent,
                        inactiveTint: Color.white.opacity(0.25),
                        symbol: context.state.phase == .completed ? "flag.checkered" : "car.side.fill",
                        backdrop: .black
                    )
                    .padding(.horizontal, 6)
                }
            } compactLeading: {
                Image(systemName: "car.side.fill")
                    .foregroundStyle(RideLockScreenView.accent)
            } compactTrailing: {
                Text(context.state.leadValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(RideLockScreenView.accent)
                    .lineLimit(1)
            } minimal: {
                Image(systemName: "car.side.fill")
                    .foregroundStyle(RideLockScreenView.accent)
            }
            .keylineTint(RideLockScreenView.accent)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}
