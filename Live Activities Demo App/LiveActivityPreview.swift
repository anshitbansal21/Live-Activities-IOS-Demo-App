//
//  LiveActivityPreview.swift
//  Renders the *same* Lock Screen views the widget extension uses, so the
//  picker screen shows each design without you having to lock the phone.
//

import SwiftUI

struct LiveActivityPreview: View {
    let demo: LiveActivityDemo
    @ObservedObject var manager: LiveActivityManager

    var body: some View {
        design
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(demo.background)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }

    @ViewBuilder
    private var design: some View {
        switch demo {
        case .flight:
            FlightLockScreenView(attributes: manager.flight.attributes, state: manager.flightState)
        case .delivery:
            DeliveryLockScreenView(attributes: manager.delivery.attributes, state: manager.deliveryState)
        case .ride:
            RideLockScreenView(attributes: manager.ride.attributes, state: manager.rideState)
        case .streak:
            StreakLockScreenView(attributes: manager.streak.attributes, state: manager.streakState)
        case .navigation:
            NavigationLockScreenView(attributes: manager.navigation.attributes, state: manager.navigationState)
        }
    }
}

/// The little "3 of 6" pill that shows how far through the scripted run we are.
struct RunningBadge: View {
    let demo: LiveActivityDemo
    @ObservedObject var manager: LiveActivityManager

    var body: some View {
        let step = (manager.currentStep[demo] ?? 0) + 1
        HStack(spacing: 5) {
            Circle()
                .fill(demo.accent)
                .frame(width: 7, height: 7)
            Text("Live · step \(step) of \(manager.stepCount(for: demo))")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(demo.accent)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(demo.accent.opacity(0.14)))
    }
}
