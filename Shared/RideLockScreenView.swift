//
//  RideLockScreenView.swift
//  Inspired by the ride-hailing pickup card: one number you actually care about,
//  the car you're looking for, and a dotted route with the vehicle on it.
//

import SwiftUI

struct RideLockScreenView: View {
    let attributes: RideActivityAttributes
    let state: RideActivityAttributes.ContentState

    static let background = Color(red: 0.96, green: 0.97, blue: 0.98)
    static let accent = Color(red: 0.16, green: 0.38, blue: 0.95)

    private var textColor: Color { Color(red: 0.06, green: 0.07, blue: 0.09) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(attributes.serviceName)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                Spacer(minLength: 6)
                HStack(spacing: -8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(textColor.opacity(0.75))
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(textColor.opacity(0.9))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(.white))
                        .overlay(Circle().strokeBorder(textColor.opacity(0.1), lineWidth: 1))
                }
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(state.leadValue)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Self.accent)
                        Text(state.leadCaption)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    Text(state.subline)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(textColor.opacity(0.6))
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 1) {
                    Text(attributes.plate)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text(attributes.carDescription)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(textColor.opacity(0.6))
                        .lineLimit(1)
                }
            }

            DottedRouteTrack(
                progress: state.progress,
                tint: Self.accent,
                inactiveTint: textColor.opacity(0.22),
                symbol: state.phase == .completed ? "flag.checkered" : "car.side.fill",
                backdrop: Self.background
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .foregroundStyle(textColor)
    }
}

#Preview {
    let scenario = DemoScenarios.ride()
    RideLockScreenView(attributes: scenario.attributes, state: scenario.initialState)
        .background(RideLockScreenView.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding()
}
