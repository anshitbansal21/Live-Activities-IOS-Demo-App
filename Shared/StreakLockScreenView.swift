//
//  StreakLockScreenView.swift
//  The gamified nudge: how long you've got left before today's streak breaks.
//

import SwiftUI

struct StreakLockScreenView: View {
    let attributes: StreakActivityAttributes
    let state: StreakActivityAttributes.ContentState

    static let background = Color(red: 0.11, green: 0.06, blue: 0.16)
    static let accent = Color(red: 1.0, green: 0.55, blue: 0.16)
    static let safeAccent = Color(red: 0.42, green: 0.84, blue: 0.45)

    private var tint: Color { state.isSafe ? Self.safeAccent : Self.accent }

    private var goalProgress: Double {
        guard state.goalMinutes > 0 else { return 1 }
        return min(1, Double(state.completedMinutes) / Double(state.goalMinutes))
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                ProgressRing(progress: goalProgress, tint: tint)
                VStack(spacing: -2) {
                    Text("\(state.currentStreak)")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                    Text("days")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(width: 66, height: 66)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Image(systemName: state.isSafe ? "checkmark.seal.fill" : "flame.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(tint)
                    Text("\(attributes.appName) · \(attributes.skillName)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Spacer(minLength: 0)
                }

                Text(state.motivation)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        FieldLabel(text: state.isSafe ? "SAFE UNTIL" : "ENDS IN", tint: .white.opacity(0.55))
                        Text(timerInterval: liveCountdownRange(to: state.deadline), countsDown: true)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .frame(minWidth: 76, alignment: .leading)
                    }
                    Text("\(state.completedMinutes)/\(state.goalMinutes) min")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .foregroundStyle(.white)
    }
}

#Preview {
    let scenario = DemoScenarios.streak()
    StreakLockScreenView(attributes: scenario.attributes, state: scenario.initialState)
        .background(StreakLockScreenView.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding()
}
