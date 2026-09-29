//
//  LiveActivityManager.swift
//  Starts, scripts and ends each demo activity, and keeps the picker screen in
//  sync with what iOS is actually showing.
//

import ActivityKit
import Combine
import SwiftUI

@MainActor
final class LiveActivityManager: ObservableObject {

    @Published private(set) var activeDemos: Set<LiveActivityDemo> = []
    /// Index of the scripted state currently on screen, per demo.
    @Published private(set) var currentStep: [LiveActivityDemo: Int] = [:]
    /// Why the last start attempt for a given demo failed, if it did.
    @Published private(set) var failures: [LiveActivityDemo: String] = [:]
    @Published private(set) var areActivitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
    /// How many activities ActivityKit is holding for this app, including any
    /// this session didn't start. Surfaced in the UI because hitting the per-app
    /// limit is the one failure that looks like "the switch won't stay on".
    @Published private(set) var systemActivityCount = 0

    // Live copies of each state so the in-app preview mirrors the Lock Screen.
    @Published private(set) var flight = DemoScenarios.flight()
    @Published private(set) var delivery = DemoScenarios.delivery()
    @Published private(set) var ride = DemoScenarios.ride()
    @Published private(set) var streak = DemoScenarios.streak()
    @Published private(set) var navigation = DemoScenarios.navigation()

    @Published private(set) var flightState = DemoScenarios.flight().initialState
    @Published private(set) var deliveryState = DemoScenarios.delivery().initialState
    @Published private(set) var rideState = DemoScenarios.ride().initialState
    @Published private(set) var streakState = DemoScenarios.streak().initialState
    @Published private(set) var navigationState = DemoScenarios.navigation().initialState

    private var flightActivity: Activity<FlightActivityAttributes>?
    private var deliveryActivity: Activity<DeliveryActivityAttributes>?
    private var rideActivity: Activity<RideActivityAttributes>?
    private var streakActivity: Activity<StreakActivityAttributes>?
    private var navigationActivity: Activity<NavigationActivityAttributes>?

    private var timelines: [LiveActivityDemo: Task<Void, Never>] = [:]
    private var watchers: [LiveActivityDemo: Task<Void, Never>] = [:]
    private var enablementWatcher: Task<Void, Never>?

    init() {
        adoptRunningActivities()
        refreshSystemActivityCount()
        enablementWatcher = Task { [weak self] in
            for await enabled in ActivityAuthorizationInfo().activityEnablementUpdates {
                self?.areActivitiesEnabled = enabled
            }
        }
    }

    // MARK: - Public API

    func isRunning(_ demo: LiveActivityDemo) -> Bool { activeDemos.contains(demo) }

    func failure(for demo: LiveActivityDemo) -> String? { failures[demo] }

    func setRunning(_ demo: LiveActivityDemo, _ running: Bool) {
        if running { start(demo) } else { stop(demo) }
    }

    func start(_ demo: LiveActivityDemo) {
        guard !activeDemos.contains(demo) else { return }
        failures[demo] = nil

        guard areActivitiesEnabled else {
            failures[demo] = "iOS has Live Activities switched off for this app. Turn them on in Settings › Live Activities Demo App › Live Activities. (This is not the notifications permission — Live Activities never show a permission prompt.)"
            return
        }

        switch demo {
        case .flight:
            let scenario = DemoScenarios.flight()
            flight = scenario
            flightState = scenario.initialState
            launch(demo, scenario: scenario) { [weak self] in self?.flightActivity = $0 } onState: { [weak self] in self?.flightState = $0 }
        case .delivery:
            let scenario = DemoScenarios.delivery()
            delivery = scenario
            deliveryState = scenario.initialState
            launch(demo, scenario: scenario) { [weak self] in self?.deliveryActivity = $0 } onState: { [weak self] in self?.deliveryState = $0 }
        case .ride:
            let scenario = DemoScenarios.ride()
            ride = scenario
            rideState = scenario.initialState
            launch(demo, scenario: scenario) { [weak self] in self?.rideActivity = $0 } onState: { [weak self] in self?.rideState = $0 }
        case .streak:
            let scenario = DemoScenarios.streak()
            streak = scenario
            streakState = scenario.initialState
            launch(demo, scenario: scenario) { [weak self] in self?.streakActivity = $0 } onState: { [weak self] in self?.streakState = $0 }
        case .navigation:
            let scenario = DemoScenarios.navigation()
            navigation = scenario
            navigationState = scenario.initialState
            launch(demo, scenario: scenario) { [weak self] in self?.navigationActivity = $0 } onState: { [weak self] in self?.navigationState = $0 }
        }
    }

    func stop(_ demo: LiveActivityDemo) {
        timelines[demo]?.cancel()
        timelines[demo] = nil
        watchers[demo]?.cancel()
        watchers[demo] = nil
        activeDemos.remove(demo)
        currentStep[demo] = nil

        Task {
            switch demo {
            case .flight:
                flightActivity = nil
                await endEvery(FlightActivityAttributes.self)
            case .delivery:
                deliveryActivity = nil
                await endEvery(DeliveryActivityAttributes.self)
            case .ride:
                rideActivity = nil
                await endEvery(RideActivityAttributes.self)
            case .streak:
                streakActivity = nil
                await endEvery(StreakActivityAttributes.self)
            case .navigation:
                navigationActivity = nil
                await endEvery(NavigationActivityAttributes.self)
            }
            refreshSystemActivityCount()
        }
    }

    /// Ends everything, including activities this session never started — which
    /// is what gets you out of a stuck "the switch won't stay on" state.
    func stopAll() {
        for demo in LiveActivityDemo.allCases {
            timelines[demo]?.cancel()
            timelines[demo] = nil
            watchers[demo]?.cancel()
            watchers[demo] = nil
        }
        activeDemos.removeAll()
        currentStep.removeAll()
        failures.removeAll()
        flightActivity = nil
        deliveryActivity = nil
        rideActivity = nil
        streakActivity = nil
        navigationActivity = nil

        Task {
            await endEvery(FlightActivityAttributes.self)
            await endEvery(DeliveryActivityAttributes.self)
            await endEvery(RideActivityAttributes.self)
            await endEvery(StreakActivityAttributes.self)
            await endEvery(NavigationActivityAttributes.self)
            refreshSystemActivityCount()
        }
    }

    func stepCount(for demo: LiveActivityDemo) -> Int { demo.timeline.count }

    func refreshSystemActivityCount() {
        systemActivityCount =
            Activity<FlightActivityAttributes>.activities.count
            + Activity<DeliveryActivityAttributes>.activities.count
            + Activity<RideActivityAttributes>.activities.count
            + Activity<StreakActivityAttributes>.activities.count
            + Activity<NavigationActivityAttributes>.activities.count
    }

    // MARK: - Plumbing

    private func launch<A: ActivityAttributes>(
        _ demo: LiveActivityDemo,
        scenario: Scenario<A, A.ContentState>,
        store: @escaping (Activity<A>?) -> Void,
        onState: @escaping (A.ContentState) -> Void
    ) {
        do {
            let activity = try Activity.request(
                attributes: scenario.attributes,
                content: ActivityContent(state: scenario.initialState, staleDate: nil),
                pushType: nil
            )
            store(activity)
            activeDemos.insert(demo)
            currentStep[demo] = 0
            refreshSystemActivityCount()

            watchers[demo] = Task { [weak self] in
                for await state in activity.activityStateUpdates {
                    guard state == .dismissed || state == .ended else { continue }
                    self?.handleSystemDismissal(demo)
                    return
                }
            }

            timelines[demo] = Task { [weak self] in
                for (index, step) in scenario.steps.enumerated() {
                    try? await Task.sleep(for: .seconds(step.delay))
                    if Task.isCancelled { return }
                    await activity.update(
                        ActivityContent(state: step.state, staleDate: nil),
                        alertConfiguration: Self.alertConfiguration(for: step)
                    )
                    if Task.isCancelled { return }
                    onState(step.state)
                    self?.currentStep[demo] = index + 1
                }
            }
        } catch {
            failures[demo] = Self.explain(error)
            refreshSystemActivityCount()
        }
    }

    /// Ends every activity of a given type, not just the one we're tracking.
    /// Extras accumulate if the app is force-quit while an activity is live, and
    /// they keep counting against the per-app limit until something ends them.
    private func endEvery<A: ActivityAttributes>(_ type: A.Type) async {
        for activity in Activity<A>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private static func alertConfiguration<State: Codable & Hashable>(
        for step: ActivityStep<State>
    ) -> AlertConfiguration? {
        guard let title = step.alertTitle, let body = step.alertBody else { return nil }
        return AlertConfiguration(
            title: LocalizedStringResource(stringLiteral: title),
            body: LocalizedStringResource(stringLiteral: body),
            sound: .default
        )
    }

    /// `localizedDescription` on ActivityKit's errors is close to useless, so
    /// spell out what actually went wrong and what to do about it.
    private static func explain(_ error: Error) -> String {
        guard let error = error as? ActivityAuthorizationError else {
            return "Couldn't start the activity: \(error.localizedDescription)"
        }
        switch error {
        case .denied:
            return "iOS denied the request. Live Activities are switched off for this app in Settings › Live Activities Demo App."
        case .unsupported:
            return "This device or OS build doesn't support Live Activities."
        case .unentitled:
            return "The app isn't allowed to run Live Activities — NSSupportsLiveActivities is missing from Info.plist."
        case .targetMaximumExceeded:
            return "This app already has the maximum number of Live Activities running. Tap “Stop all” to clear them, then try again."
        case .globalMaximumExceeded:
            return "iOS is showing the maximum number of Live Activities system-wide. Dismiss a few from the Lock Screen and try again."
        case .attributesTooLarge:
            return "The activity payload is over ActivityKit's 4 KB limit."
        case .visibility:
            return "iOS only allows starting a Live Activity while the app is in the foreground."
        case .persistenceFailure:
            return "ActivityKit failed to persist the activity. Try again."
        default:
            return "Couldn't start the activity: \(error.localizedDescription)"
        }
    }

    private func handleSystemDismissal(_ demo: LiveActivityDemo) {
        timelines[demo]?.cancel()
        timelines[demo] = nil
        watchers[demo] = nil
        activeDemos.remove(demo)
        currentStep[demo] = nil
        refreshSystemActivityCount()
    }

    /// If the app was relaunched while activities were still on screen, pick them
    /// back up so the toggles tell the truth.
    private func adoptRunningActivities() {
        adopt(.flight, FlightActivityAttributes.self) { [weak self] in
            self?.flightActivity = $0
        } onState: { [weak self] in self?.flightState = $0 }

        adopt(.delivery, DeliveryActivityAttributes.self) { [weak self] in
            self?.deliveryActivity = $0
        } onState: { [weak self] in self?.deliveryState = $0 }

        adopt(.ride, RideActivityAttributes.self) { [weak self] in
            self?.rideActivity = $0
        } onState: { [weak self] in self?.rideState = $0 }

        adopt(.streak, StreakActivityAttributes.self) { [weak self] in
            self?.streakActivity = $0
        } onState: { [weak self] in self?.streakState = $0 }

        adopt(.navigation, NavigationActivityAttributes.self) { [weak self] in
            self?.navigationActivity = $0
        } onState: { [weak self] in self?.navigationState = $0 }
    }

    private func adopt<A: ActivityAttributes>(
        _ demo: LiveActivityDemo,
        _ type: A.Type,
        store: (Activity<A>) -> Void,
        onState: (A.ContentState) -> Void
    ) {
        let running = Activity<A>.activities
        guard let current = running.first else { return }
        store(current)
        onState(current.content.state)
        activeDemos.insert(demo)

        // Anything past the first is a leftover from an earlier run. Ending it
        // frees a slot against the per-app activity limit.
        let extras = Array(running.dropFirst())
        guard !extras.isEmpty else { return }
        Task {
            for activity in extras {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            refreshSystemActivityCount()
        }
    }
}
