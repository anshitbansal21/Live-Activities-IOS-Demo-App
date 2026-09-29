//
//  LiveActivityWidgetsBundle.swift
//  Every Live Activity has to be declared by a widget extension, so all five
//  demo designs are registered here.
//

import ActivityKit
import SwiftUI
import WidgetKit

@main
struct LiveActivityWidgetsBundle: WidgetBundle {
    var body: some Widget {
        FlightActivityWidget()
        DeliveryActivityWidget()
        RideActivityWidget()
        StreakActivityWidget()
        NavigationActivityWidget()
    }
}
