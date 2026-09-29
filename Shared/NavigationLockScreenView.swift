//
//  NavigationLockScreenView.swift
//  Turn-by-turn: the maneuver dominates, everything else is supporting detail.
//

import SwiftUI

struct NavigationLockScreenView: View {
    let attributes: NavigationActivityAttributes
    let state: NavigationActivityAttributes.ContentState

    static let background = Color(red: 0.05, green: 0.11, blue: 0.09)
    static let accent = Color(red: 0.31, green: 0.80, blue: 0.47)

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Self.accent.opacity(0.18))
                    Image(systemName: state.maneuver.symbol)
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(Self.accent)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 1) {
                    Text(state.distanceText)
                        .font(.system(size: 21, weight: .heavy, design: .rounded))
                    Text(state.instruction)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            if let thenInstruction = state.thenInstruction {
                HStack(spacing: 6) {
                    Text("THEN")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(0.7)
                        .foregroundStyle(.white.opacity(0.45))
                    if let thenManeuver = state.thenManeuver {
                        Image(systemName: thenManeuver.symbol)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Text(thenInstruction)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(.white.opacity(0.09)))
            }

            GlyphTrack(
                progress: state.routeProgress,
                symbol: "location.north.fill",
                glyphTint: Self.accent,
                travelledTint: Self.accent.opacity(0.5),
                glyphSize: 12
            )

            HStack(spacing: 14) {
                metric(label: "ARRIVES", value: Text(state.arrival, style: .time))
                metric(label: "IN", value: Text(timerInterval: liveCountdownRange(to: state.arrival), countsDown: true).monospacedDigit())
                metric(label: "LEFT", value: Text(state.remainingDistanceText))
                Spacer(minLength: 0)
                Text(attributes.destinationName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Self.accent)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .foregroundStyle(.white)
    }

    private func metric(label: String, value: Text) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldLabel(text: label, tint: .white.opacity(0.5))
            value
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .frame(minWidth: 46, alignment: .leading)
        }
    }
}

#Preview {
    let scenario = DemoScenarios.navigation()
    NavigationLockScreenView(attributes: scenario.attributes, state: scenario.initialState)
        .background(NavigationLockScreenView.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding()
}
