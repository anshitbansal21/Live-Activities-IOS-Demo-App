//
//  LiveActivityAttributes.swift
//  Shared between the app and the LiveActivityWidgets extension.
//
//  One ActivityAttributes type per demo. Everything that can change while the
//  activity is on screen lives in ContentState; everything fixed for the whole
//  lifetime of the activity lives on the attributes themselves.
//

import ActivityKit
import Foundation
import SwiftUI

// MARK: - 1. Flight (inspired by Air India's boarding activity)

nonisolated enum FlightStatus: String, Codable, Hashable, CaseIterable {
    case onTime
    case boarding
    case finalCall
    case delayed
    case inAir
    case landed

    var label: String {
        switch self {
        case .onTime: "On Time"
        case .boarding: "Boarding"
        case .finalCall: "Final Call"
        case .delayed: "Delayed"
        case .inAir: "In Air"
        case .landed: "Landed"
        }
    }

    var tint: Color {
        switch self {
        case .onTime: Color(red: 0.22, green: 0.73, blue: 0.40)
        case .boarding: Color(red: 0.18, green: 0.55, blue: 0.95)
        case .finalCall: Color(red: 0.97, green: 0.62, blue: 0.13)
        case .delayed: Color(red: 0.89, green: 0.27, blue: 0.24)
        case .inAir: Color(red: 0.38, green: 0.70, blue: 0.95)
        case .landed: Color(white: 0.55)
        }
    }
}

nonisolated struct FlightActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var status: FlightStatus
        var terminal: String
        var gate: String
        var zone: String
        var seat: String
        /// Text shown inside the capsule banner, e.g. "Boarding will start in".
        var bannerTitle: String
        /// When set, a live countdown is rendered next to `bannerTitle`.
        var bannerTarget: Date?
        var departure: Date
        var arrival: Date
        var durationText: String
        /// 0…1 position of the aircraft glyph along the route line.
        var progress: Double
    }

    var airline: String
    var flightNumber: String
    var originCode: String
    var destinationCode: String
    var originCity: String
    var destinationCity: String
}

// MARK: - 2. Delivery (the classic time-sensitive order tracker)

nonisolated enum DeliveryStage: Int, Codable, Hashable, CaseIterable {
    case confirmed
    case preparing
    case pickedUp
    case nearby
    case delivered

    var title: String {
        switch self {
        case .confirmed: "Order placed"
        case .preparing: "Preparing"
        case .pickedUp: "On the way"
        case .nearby: "Almost there"
        case .delivered: "Delivered"
        }
    }

    var shortTitle: String {
        switch self {
        case .confirmed: "Placed"
        case .preparing: "Cooking"
        case .pickedUp: "Riding"
        case .nearby: "Nearby"
        case .delivered: "Done"
        }
    }

    var symbol: String {
        switch self {
        case .confirmed: "checkmark"
        case .preparing: "flame.fill"
        case .pickedUp: "bicycle"
        case .nearby: "mappin.and.ellipse"
        case .delivered: "checkmark.circle.fill"
        }
    }

    var progress: Double {
        guard DeliveryStage.allCases.count > 1 else { return 1 }
        return Double(rawValue) / Double(DeliveryStage.allCases.count - 1)
    }
}

nonisolated struct DeliveryActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var stage: DeliveryStage
        var headline: String
        var detail: String
        /// Arrival estimate; drives the "arrives in x min" countdown.
        var eta: Date
        var courierName: String
        var isDelivered: Bool
    }

    var merchant: String
    var orderSummary: String
    var orderNumber: String
}

// MARK: - 3. Ride (inspired by Uber's pickup activity)

nonisolated enum RidePhase: Int, Codable, Hashable, CaseIterable {
    case matching
    case enRoute
    case arrivingSoon
    case waiting
    case inTrip
    case completed

    var isPickupPhase: Bool { rawValue <= RidePhase.waiting.rawValue }
}

nonisolated struct RideActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var phase: RidePhase
        /// Leading emphasised value, e.g. "1 min" or "Arrived".
        var leadValue: String
        /// Text that follows the emphasised value, e.g. "until pickup".
        var leadCaption: String
        var subline: String
        var progress: Double
        var dropoffETA: Date
    }

    var serviceName: String
    var driverName: String
    var plate: String
    var carDescription: String
    var pickupName: String
    var dropoffName: String
}

// MARK: - 4. Streak (the gamified "don't lose your progress" nudge)

nonisolated struct StreakActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var currentStreak: Int
        var goalMinutes: Int
        var completedMinutes: Int
        /// When the streak breaks. Drives the countdown.
        var deadline: Date
        var isSafe: Bool
        var motivation: String
    }

    var appName: String
    var skillName: String
}

// MARK: - 5. Navigation (turn-by-turn, the Maps pattern)

nonisolated enum Maneuver: String, Codable, Hashable, CaseIterable {
    case straight
    case slightRight
    case right
    case sharpRight
    case slightLeft
    case left
    case uTurn
    case roundabout
    case arrive

    var symbol: String {
        switch self {
        case .straight: "arrow.up"
        case .slightRight: "arrow.up.right"
        case .right: "arrow.turn.up.right"
        case .sharpRight: "arrow.turn.right.up"
        case .slightLeft: "arrow.up.left"
        case .left: "arrow.turn.up.left"
        case .uTurn: "arrow.uturn.down"
        case .roundabout: "arrow.triangle.turn.up.right.circle"
        case .arrive: "flag.checkered"
        }
    }
}

nonisolated struct NavigationActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var maneuver: Maneuver
        var distanceText: String
        var instruction: String
        var thenManeuver: Maneuver?
        var thenInstruction: String?
        var arrival: Date
        var remainingDistanceText: String
        var routeProgress: Double
        var isRerouting: Bool
    }

    var destinationName: String
    var travelMode: String
}
