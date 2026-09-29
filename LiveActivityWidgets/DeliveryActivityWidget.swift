import ActivityKit
import SwiftUI
import WidgetKit

struct DeliveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryActivityAttributes.self) { context in
            DeliveryLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(DeliveryLockScreenView.background)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.stage.symbol)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(DeliveryLockScreenView.accent)
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        if context.state.isDelivered {
                            Text("Delivered")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                        } else {
                            Text(timerInterval: liveCountdownRange(to: context.state.eta), countsDown: true)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                                .frame(maxWidth: 70)
                        }
                        Text(context.state.isDelivered ? "enjoy!" : "to arrive")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.headline)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    StageTrack(
                        stages: DeliveryStage.allCases,
                        current: context.state.stage,
                        tint: DeliveryLockScreenView.accent
                    )
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                Image(systemName: context.state.stage.symbol)
                    .foregroundStyle(DeliveryLockScreenView.accent)
            } compactTrailing: {
                if context.state.isDelivered {
                    Image(systemName: "checkmark")
                        .foregroundStyle(DeliveryLockScreenView.accent)
                } else {
                    Text(timerInterval: liveCountdownRange(to: context.state.eta), countsDown: true)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .frame(maxWidth: 64)
                }
            } minimal: {
                Image(systemName: context.state.stage.symbol)
                    .foregroundStyle(DeliveryLockScreenView.accent)
            }
            .keylineTint(DeliveryLockScreenView.accent)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}
