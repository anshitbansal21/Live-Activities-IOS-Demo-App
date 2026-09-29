//
//  ActivityDesignKit.swift
//  Small building blocks reused by every Live Activity design.
//

import Foundation
import SwiftUI

// MARK: - Countdown helper

/// `Text(timerInterval:)` traps on an inverted range, which is easy to hit once a
/// deadline has passed. This always hands back a valid, forward-facing range.
nonisolated func liveCountdownRange(to target: Date, from reference: Date = Date()) -> ClosedRange<Date> {
    let start = min(reference, target)
    let end = max(target, start.addingTimeInterval(1))
    return start...end
}

// MARK: - Labels & badges

/// Small all-caps caption used above a value, the way boarding passes label fields.
struct FieldLabel: View {
    let text: String
    var tint: Color = .secondary

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .tracking(0.6)
            .foregroundStyle(tint)
            .fixedSize()
    }
}

struct StatusPill: View {
    let text: String
    let tint: Color
    var filled: Bool = true

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(filled ? .white : tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 3.5)
            .background {
                Capsule().fill(filled ? AnyShapeStyle(tint) : AnyShapeStyle(tint.opacity(0.18)))
            }
    }
}

// MARK: - Progress tracks

/// Continuous line with a glyph riding along it — the flight route treatment.
struct GlyphTrack: View {
    let progress: Double
    let symbol: String
    let glyphTint: Color
    var trackTint: Color = Color.white.opacity(0.28)
    var travelledTint: Color? = nil
    var glyphSize: CGFloat = 15

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let travel = max(0, min(1, progress))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackTint)
                    .frame(height: 2)
                if let travelledTint {
                    Capsule()
                        .fill(travelledTint)
                        .frame(width: width * travel, height: 2)
                }
                Image(systemName: symbol)
                    .font(.system(size: glyphSize, weight: .black))
                    .foregroundStyle(glyphTint)
                    .offset(x: (width - glyphSize * 1.6) * travel)
            }
            .frame(height: geo.size.height, alignment: .center)
        }
        .frame(height: glyphSize + 3)
    }
}

/// Dotted route with a vehicle marker — the ride-hailing treatment.
struct DottedRouteTrack: View {
    let progress: Double
    let tint: Color
    var inactiveTint: Color = Color.secondary.opacity(0.28)
    var symbol: String = "car.fill"
    /// Colour painted behind the stop nodes and the vehicle so the dots don't
    /// show through. Callers pass their own card background.
    var backdrop: Color = .black
    var dotCount: Int = 13

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let travel = max(0, min(1, progress))
            ZStack(alignment: .leading) {
                HStack(spacing: 5) {
                    ForEach(0..<dotCount, id: \.self) { index in
                        let threshold = Double(index) / Double(max(dotCount - 1, 1))
                        Circle()
                            .fill(threshold <= travel ? tint : inactiveTint)
                            .frame(height: 5)
                    }
                }
                Circle()
                    .strokeBorder(tint, lineWidth: 3)
                    .background(Circle().fill(backdrop))
                    .frame(width: 10, height: 10)
                    .offset(x: (width - 10) * 0.52)
                Circle()
                    .strokeBorder(inactiveTint, lineWidth: 3)
                    .background(Circle().fill(backdrop))
                    .frame(width: 10, height: 10)
                    .offset(x: width - 10)
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 3)
                    .background(Capsule().fill(backdrop))
                    .offset(x: (width - 34) * travel)
            }
            .frame(height: geo.size.height, alignment: .center)
        }
        .frame(height: 18)
    }
}

/// Node-and-rail stage indicator — the delivery treatment.
struct StageTrack: View {
    let stages: [DeliveryStage]
    let current: DeliveryStage
    let tint: Color

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stages.enumerated()), id: \.element) { index, stage in
                let reached = stage.rawValue <= current.rawValue
                if index > 0 {
                    Rectangle()
                        .fill(reached ? tint : Color.secondary.opacity(0.25))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
                ZStack {
                    Circle()
                        .fill(reached ? tint : Color.secondary.opacity(0.22))
                        .frame(width: stage == current ? 20 : 14, height: stage == current ? 20 : 14)
                    if stage == current {
                        Image(systemName: stage.symbol)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

/// Ring used by the streak design.
struct ProgressRing: View {
    let progress: Double
    let tint: Color
    var lineWidth: CGFloat = 6
    var trackTint: Color = Color.white.opacity(0.2)

    var body: some View {
        ZStack {
            Circle().stroke(trackTint, lineWidth: lineWidth)
            if progress > 0 {
                Circle()
                    .trim(from: 0, to: min(1, progress))
                    .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}
