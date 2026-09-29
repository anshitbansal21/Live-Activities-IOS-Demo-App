//
//  LiveActivityDemo.swift
//  The catalog that drives the picker screen — one entry per design, with the
//  notes on why that pattern exists in the wild.
//

import SwiftUI

enum LiveActivityDemo: String, CaseIterable, Identifiable, Hashable {
    case flight
    case delivery
    case ride
    case streak
    case navigation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .flight: "Flight & boarding pass"
        case .delivery: "Order delivery"
        case .ride: "Ride pickup"
        case .streak: "Daily streak"
        case .navigation: "Turn-by-turn directions"
        }
    }

    var tagline: String {
        switch self {
        case .flight: "Everything you need at the airport, without unlocking"
        case .delivery: "The classic staged tracker with a live ETA"
        case .ride: "One number that matters, plus the car to look for"
        case .streak: "A countdown to losing something you've built"
        case .navigation: "The next maneuver, large and unmissable"
        }
    }

    var symbol: String {
        switch self {
        case .flight: "airplane.departure"
        case .delivery: "takeoutbag.and.cup.and.straw.fill"
        case .ride: "car.side.fill"
        case .streak: "flame.fill"
        case .navigation: "arrow.triangle.turn.up.right.diamond.fill"
        }
    }

    var accent: Color {
        switch self {
        case .flight: FlightLockScreenView.accent
        case .delivery: DeliveryLockScreenView.accent
        case .ride: RideLockScreenView.accent
        case .streak: StreakLockScreenView.accent
        case .navigation: NavigationLockScreenView.accent
        }
    }

    var background: Color {
        switch self {
        case .flight: FlightLockScreenView.background
        case .delivery: DeliveryLockScreenView.background
        case .ride: RideLockScreenView.background
        case .streak: StreakLockScreenView.background
        case .navigation: NavigationLockScreenView.background
        }
    }

    /// Why real apps reach for this pattern.
    var useCase: String {
        switch self {
        case .flight:
            "The densest use of the space of anything I looked at. Terminal, gate, zone, seat, status, both airport codes, both local times, flight duration and a live boarding countdown all fit in one glance — which is exactly what you want when you're walking through an airport with a bag in each hand."
        case .delivery:
            "The pattern most apps start with. A small number of named stages plus a countdown, so the question \"where is my order\" is answered before you even pick the phone up."
        case .ride:
            "Pared all the way down: how long until pickup, and the plate and colour of the car you're scanning the kerb for. The dotted route gives you a sense of motion without pretending to be a map."
        case .streak:
            "Loss aversion as a UI. The countdown is the whole point — it turns \"I'll do it later\" into a number that keeps shrinking on your Lock Screen."
        case .navigation:
            "Maps-style guidance where one element dominates the card: the maneuver arrow and the distance to it. Everything else — the next turn, ETA, distance left — is deliberately secondary."
        }
    }

    /// What the Dynamic Island shows for this design.
    var islandNote: String {
        switch self {
        case .flight:
            "Compact: aircraft glyph plus the boarding countdown. Expanded: flight number and status, gate and seat, and the DEL → HKG route line."
        case .delivery:
            "Compact: the current stage icon plus the ETA countdown. Expanded: headline, ETA and the full stage rail."
        case .ride:
            "Compact: a car and the minutes-until-pickup. Expanded: the pickup line, plate, car description and the dotted route."
        case .streak:
            "Compact: flame plus the time left today. Expanded: streak count, minutes-to-goal progress bar and the deadline."
        case .navigation:
            "Compact: the maneuver arrow and distance. Expanded: adds the full instruction, the \"then\" step, arrival time and distance remaining."
        }
    }

    /// Names for each scripted state the demo walks through.
    var timeline: [String] {
        switch self {
        case .flight:
            ["On time · boarding countdown", "Boarding · gate closing", "Final call", "In air · 35%", "In air · 72%", "Landed · belt 4"]
        case .delivery:
            ["Order confirmed", "Being cooked", "Picked up", "2 minutes away", "Delivered"]
        case .ride:
            ["Matching a driver", "6 min until pickup", "1 min until pickup", "Driver arrived", "In trip to airport", "Arrived"]
        case .streak:
            ["0 of 20 minutes", "8 of 20 minutes", "15 of 20 minutes", "Goal hit · streak secured"]
        case .navigation:
            ["Continue straight", "Turn right", "Keep left", "Roundabout", "Turn left", "Arriving"]
        }
    }

    /// Roughly how long the scripted run takes, for the UI copy.
    var runDurationText: String {
        switch self {
        case .flight: "about 50 seconds"
        case .delivery: "about 35 seconds"
        case .ride: "about 45 seconds"
        case .streak: "about 26 seconds"
        case .navigation: "about 40 seconds"
        }
    }
}
