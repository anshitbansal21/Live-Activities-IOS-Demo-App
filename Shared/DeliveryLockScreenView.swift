//
//  DeliveryLockScreenView.swift
//  The most common Live Activity pattern: a staged order tracker with an ETA.
//

import SwiftUI

struct DeliveryLockScreenView: View {
    let attributes: DeliveryActivityAttributes
    let state: DeliveryActivityAttributes.ContentState

    static let background = Color(red: 0.07, green: 0.07, blue: 0.09)
    static let accent = Color(red: 0.99, green: 0.44, blue: 0.20)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Self.accent)
                Text(attributes.merchant)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text(attributes.orderNumber)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer(minLength: 4)
                StatusPill(text: state.stage.title, tint: Self.accent, filled: state.stage == .delivered)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.headline)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                    Text(state.detail)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
                Spacer(minLength: 6)
                VStack(alignment: .trailing, spacing: 1) {
                    FieldLabel(text: state.isDelivered ? "HANDED OVER" : "ARRIVES IN", tint: .white.opacity(0.55))
                    if state.isDelivered {
                        Text(state.eta, style: .time)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                    } else {
                        Text(timerInterval: liveCountdownRange(to: state.eta), countsDown: true)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .frame(minWidth: 78, alignment: .trailing)
                    }
                }
            }

            StageTrack(stages: DeliveryStage.allCases, current: state.stage, tint: Self.accent)
                .padding(.horizontal, 2)

            HStack {
                ForEach(DeliveryStage.allCases, id: \.self) { stage in
                    Text(stage.shortTitle)
                        .font(.system(size: 9, weight: stage == state.stage ? .bold : .regular, design: .rounded))
                        .foregroundStyle(stage == state.stage ? .white : .white.opacity(0.42))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, -4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .foregroundStyle(.white)
    }
}

#Preview {
    let scenario = DemoScenarios.delivery()
    DeliveryLockScreenView(attributes: scenario.attributes, state: scenario.initialState)
        .background(DeliveryLockScreenView.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding()
}
