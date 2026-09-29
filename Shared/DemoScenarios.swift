//
//  DemoScenarios.swift
//  Sample content for each design, plus a scripted timeline so a started
//  activity actually *moves* instead of sitting on one frozen frame.
//

import Foundation

/// One scripted update: wait `delay`, then push `state` (optionally with an alert
/// so the update also buzzes the Lock Screen, the Watch and the Mac menu bar).
nonisolated struct ActivityStep<State: Codable & Hashable>: Hashable {
    var delay: TimeInterval
    var state: State
    var alertTitle: String?
    var alertBody: String?

    init(delay: TimeInterval, state: State, alertTitle: String? = nil, alertBody: String? = nil) {
        self.delay = delay
        self.state = state
        self.alertTitle = alertTitle
        self.alertBody = alertBody
    }
}

nonisolated struct Scenario<Attributes, State: Codable & Hashable> {
    var attributes: Attributes
    var initialState: State
    var steps: [ActivityStep<State>]
}

nonisolated enum DemoScenarios {

    // MARK: Flight

    static func flight(now: Date = Date()) -> Scenario<FlightActivityAttributes, FlightActivityAttributes.ContentState> {
        let attributes = FlightActivityAttributes(
            airline: "Air India",
            flightNumber: "AI 314",
            originCode: "DEL",
            destinationCode: "HKG",
            originCity: "Delhi",
            destinationCity: "Hong Kong"
        )
        let departure = now.addingTimeInterval(42 * 60)
        let arrival = departure.addingTimeInterval(4 * 3600 + 23 * 60)

        func state(
            _ status: FlightStatus,
            banner: String,
            target: Date?,
            gate: String = "13",
            progress: Double
        ) -> FlightActivityAttributes.ContentState {
            FlightActivityAttributes.ContentState(
                status: status,
                terminal: "Terminal 3",
                gate: gate,
                zone: "B",
                seat: "30A",
                bannerTitle: banner,
                bannerTarget: target,
                departure: departure,
                arrival: arrival,
                durationText: "4 hrs 23 m",
                progress: progress
            )
        }

        return Scenario(
            attributes: attributes,
            initialState: state(.onTime, banner: "Boarding will start in", target: now.addingTimeInterval(12 * 60), progress: 0.02),
            steps: [
                ActivityStep(
                    delay: 10,
                    state: state(.boarding, banner: "Gate closes in", target: now.addingTimeInterval(9 * 60), progress: 0.05),
                    alertTitle: "Boarding has started",
                    alertBody: "Zone B is boarding at Gate 13."
                ),
                ActivityStep(
                    delay: 10,
                    state: state(.finalCall, banner: "Final call · proceed to Gate 13", target: nil, progress: 0.08),
                    alertTitle: "Final call for AI 314",
                    alertBody: "The gate closes in a few minutes."
                ),
                ActivityStep(delay: 10, state: state(.inAir, banner: "Landing in", target: arrival, progress: 0.35)),
                ActivityStep(delay: 10, state: state(.inAir, banner: "Landing in", target: arrival, progress: 0.72)),
                ActivityStep(
                    delay: 10,
                    state: state(.landed, banner: "Arrived · Baggage belt 4", target: nil, progress: 1.0),
                    alertTitle: "Welcome to Hong Kong",
                    alertBody: "Bags arrive on belt 4."
                )
            ]
        )
    }

    // MARK: Delivery

    static func delivery(now: Date = Date()) -> Scenario<DeliveryActivityAttributes, DeliveryActivityAttributes.ContentState> {
        let attributes = DeliveryActivityAttributes(
            merchant: "Rasoi Kitchen",
            orderSummary: "Butter chicken · Garlic naan · Raita",
            orderNumber: "#48210"
        )
        let eta = now.addingTimeInterval(21 * 60)

        func state(
            _ stage: DeliveryStage,
            headline: String,
            detail: String,
            eta: Date,
            delivered: Bool = false
        ) -> DeliveryActivityAttributes.ContentState {
            DeliveryActivityAttributes.ContentState(
                stage: stage,
                headline: headline,
                detail: detail,
                eta: eta,
                courierName: "Imran",
                isDelivered: delivered
            )
        }

        return Scenario(
            attributes: attributes,
            initialState: state(.confirmed, headline: "Order confirmed", detail: "Rasoi Kitchen has your order", eta: eta),
            steps: [
                ActivityStep(delay: 8, state: state(.preparing, headline: "Your food is being cooked", detail: "Fresh off the tandoor", eta: eta)),
                ActivityStep(
                    delay: 9,
                    state: state(.pickedUp, headline: "Imran picked up your order", detail: "On the way to you", eta: now.addingTimeInterval(13 * 60)),
                    alertTitle: "Order picked up",
                    alertBody: "Imran is on the way with your order."
                ),
                ActivityStep(delay: 9, state: state(.nearby, headline: "Imran is 2 minutes away", detail: "Please meet at the gate", eta: now.addingTimeInterval(2 * 60))),
                ActivityStep(
                    delay: 9,
                    state: state(.delivered, headline: "Delivered · Enjoy your meal", detail: "Handed over at the gate", eta: now, delivered: true),
                    alertTitle: "Order delivered",
                    alertBody: "Enjoy your meal from Rasoi Kitchen."
                )
            ]
        )
    }

    // MARK: Ride

    static func ride(now: Date = Date()) -> Scenario<RideActivityAttributes, RideActivityAttributes.ContentState> {
        let attributes = RideActivityAttributes(
            serviceName: "Rideshare",
            driverName: "Anderson",
            plate: "7NLR004",
            carDescription: "Silver Honda Civic",
            pickupName: "Indiranagar 100ft Road",
            dropoffName: "Kempegowda Airport"
        )
        let dropoff = now.addingTimeInterval(52 * 60)

        func state(
            _ phase: RidePhase,
            lead: String,
            caption: String,
            subline: String,
            progress: Double
        ) -> RideActivityAttributes.ContentState {
            RideActivityAttributes.ContentState(
                phase: phase,
                leadValue: lead,
                leadCaption: caption,
                subline: subline,
                progress: progress,
                dropoffETA: dropoff
            )
        }

        return Scenario(
            attributes: attributes,
            initialState: state(.matching, lead: "Finding", caption: "you a driver", subline: "Usually takes under a minute", progress: 0.04),
            steps: [
                ActivityStep(delay: 7, state: state(.enRoute, lead: "6 min", caption: "until pickup", subline: "Anderson is on the way", progress: 0.16)),
                ActivityStep(
                    delay: 9,
                    state: state(.arrivingSoon, lead: "1 min", caption: "until pickup", subline: "Anderson is arriving soon", progress: 0.44),
                    alertTitle: "Anderson is arriving",
                    alertBody: "Silver Honda Civic · 7NLR004"
                ),
                ActivityStep(delay: 9, state: state(.waiting, lead: "Arrived", caption: "at your pickup", subline: "Anderson is waiting for you", progress: 0.52)),
                ActivityStep(delay: 9, state: state(.inTrip, lead: "48 min", caption: "to the airport", subline: "On the fastest route via NH 44", progress: 0.72)),
                ActivityStep(
                    delay: 9,
                    state: state(.completed, lead: "Arrived", caption: "at the airport", subline: "Thanks for riding with us", progress: 1.0),
                    alertTitle: "You've arrived",
                    alertBody: "Rate your trip with Anderson."
                )
            ]
        )
    }

    // MARK: Streak

    static func streak(now: Date = Date()) -> Scenario<StreakActivityAttributes, StreakActivityAttributes.ContentState> {
        let attributes = StreakActivityAttributes(appName: "Lingo", skillName: "Japanese")
        let deadline = Calendar.current.startOfDay(for: now).addingTimeInterval(24 * 3600 - 1)

        func state(_ minutes: Int, streak: Int, safe: Bool, motivation: String) -> StreakActivityAttributes.ContentState {
            StreakActivityAttributes.ContentState(
                currentStreak: streak,
                goalMinutes: 20,
                completedMinutes: minutes,
                deadline: deadline,
                isSafe: safe,
                motivation: motivation
            )
        }

        return Scenario(
            attributes: attributes,
            initialState: state(0, streak: 41, safe: false, motivation: "Finish a lesson to keep your streak"),
            steps: [
                ActivityStep(delay: 8, state: state(8, streak: 41, safe: false, motivation: "Nice start — 12 minutes to go")),
                ActivityStep(delay: 9, state: state(15, streak: 41, safe: false, motivation: "Almost there, 5 minutes left")),
                ActivityStep(
                    delay: 9,
                    state: state(20, streak: 42, safe: true, motivation: "Streak secured. See you tomorrow!"),
                    alertTitle: "42 day streak 🔥",
                    alertBody: "You hit today's 20 minute goal."
                )
            ]
        )
    }

    // MARK: Navigation

    static func navigation(now: Date = Date()) -> Scenario<NavigationActivityAttributes, NavigationActivityAttributes.ContentState> {
        let attributes = NavigationActivityAttributes(destinationName: "Cubbon Park", travelMode: "Driving")
        let arrival = now.addingTimeInterval(18 * 60)

        func state(
            _ maneuver: Maneuver,
            distance: String,
            instruction: String,
            then: Maneuver? = nil,
            thenText: String? = nil,
            remaining: String,
            progress: Double
        ) -> NavigationActivityAttributes.ContentState {
            NavigationActivityAttributes.ContentState(
                maneuver: maneuver,
                distanceText: distance,
                instruction: instruction,
                thenManeuver: then,
                thenInstruction: thenText,
                arrival: arrival,
                remainingDistanceText: remaining,
                routeProgress: progress,
                isRerouting: false
            )
        }

        return Scenario(
            attributes: attributes,
            initialState: state(.straight, distance: "700 m", instruction: "Continue on Old Airport Road", then: .right, thenText: "Turn right onto Trinity Circle", remaining: "9.4 km", progress: 0.08),
            steps: [
                ActivityStep(delay: 8, state: state(.right, distance: "250 m", instruction: "Turn right onto Trinity Circle", then: .slightLeft, thenText: "Keep left for MG Road", remaining: "8.1 km", progress: 0.22)),
                ActivityStep(delay: 8, state: state(.slightLeft, distance: "120 m", instruction: "Keep left for MG Road", then: .roundabout, thenText: "Take the 2nd exit", remaining: "6.3 km", progress: 0.38)),
                ActivityStep(delay: 8, state: state(.roundabout, distance: "400 m", instruction: "At the roundabout, take the 2nd exit", then: .left, thenText: "Turn left onto Kasturba Road", remaining: "4.0 km", progress: 0.58)),
                ActivityStep(delay: 8, state: state(.left, distance: "90 m", instruction: "Turn left onto Kasturba Road", then: .arrive, thenText: "Arrive at Cubbon Park", remaining: "1.2 km", progress: 0.82)),
                ActivityStep(
                    delay: 8,
                    state: state(.arrive, distance: "Now", instruction: "Arriving at Cubbon Park", remaining: "0 km", progress: 1.0),
                    alertTitle: "You've arrived",
                    alertBody: "Cubbon Park is on your right."
                )
            ]
        )
    }
}
