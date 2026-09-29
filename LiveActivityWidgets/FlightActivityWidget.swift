import ActivityKit
import SwiftUI
import WidgetKit

struct FlightActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlightActivityAttributes.self) { context in
            FlightLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(FlightLockScreenView.background)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(context.attributes.flightNumber)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                        Text(context.state.status.label)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(context.state.status.tint)
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Gate \(context.state.gate)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                        Text("Seat \(context.state.seat)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.bannerTitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(context.attributes.originCode)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                        GlyphTrack(
                            progress: context.state.progress,
                            symbol: "airplane",
                            glyphTint: FlightLockScreenView.accent,
                            travelledTint: FlightLockScreenView.accent.opacity(0.45)
                        )
                        Text(context.attributes.destinationCode)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "airplane")
                    .foregroundStyle(FlightLockScreenView.accent)
            } compactTrailing: {
                if let target = context.state.bannerTarget {
                    Text(timerInterval: liveCountdownRange(to: target), countsDown: true)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .frame(maxWidth: 64)
                } else {
                    Text(context.state.gate)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
            } minimal: {
                Image(systemName: "airplane")
                    .foregroundStyle(FlightLockScreenView.accent)
            }
            .keylineTint(FlightLockScreenView.accent)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}
