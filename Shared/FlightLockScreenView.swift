//
//  FlightLockScreenView.swift
//  The densest of the five designs: airline, flight, status, terminal, gate,
//  zone, seat, a live boarding countdown and the whole route — all in the
//  ~160pt the Lock Screen gives you.
//

import SwiftUI

struct FlightLockScreenView: View {
    let attributes: FlightActivityAttributes
    let state: FlightActivityAttributes.ContentState

    static let background = Color.black
    static let accent = Color(red: 0.89, green: 0.21, blue: 0.24)
    static let gold = Color(red: 0.86, green: 0.74, blue: 0.48)

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            header
            fields
            banner
            route
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .foregroundStyle(.white)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(attributes.airline.uppercased())
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(Self.accent)
            Image(systemName: "airplane.departure")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Self.gold)
            Spacer(minLength: 6)
            Text(attributes.flightNumber)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
            StatusPill(text: state.status.label, tint: state.status.tint)
        }
    }

    private var fields: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    FieldLabel(text: "TERMINAL", tint: Self.gold)
                    Text("|").font(.system(size: 10)).foregroundStyle(Self.gold.opacity(0.5))
                    FieldLabel(text: "GATE", tint: Self.gold)
                }
                HStack(spacing: 7) {
                    Text(state.terminal)
                    Text(state.gate)
                }
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            Spacer(minLength: 4)
            VStack(spacing: 1) {
                FieldLabel(text: "ZONE", tint: Self.gold)
                Text(state.zone).font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 1) {
                FieldLabel(text: "SEAT", tint: Self.gold)
                Text(state.seat).font(.system(size: 17, weight: .semibold, design: .rounded))
            }
        }
    }

    private var banner: some View {
        HStack(spacing: 5) {
            Spacer(minLength: 0)
            Text(state.bannerTitle)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            if let target = state.bannerTarget {
                Text(timerInterval: liveCountdownRange(to: target), countsDown: true)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(minWidth: 52, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(.white.opacity(0.16)))
    }

    private var route: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                Text(attributes.originCode)
                    .font(.system(size: 21, weight: .heavy, design: .rounded))
                Text(state.departure, style: .time)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            VStack(spacing: 0) {
                GlyphTrack(
                    progress: state.progress,
                    symbol: "airplane",
                    glyphTint: Self.accent,
                    travelledTint: Self.accent.opacity(0.45)
                )
                Text(state.durationText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .trailing, spacing: 0) {
                Text(attributes.destinationCode)
                    .font(.system(size: 21, weight: .heavy, design: .rounded))
                Text(state.arrival, style: .time)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    let scenario = DemoScenarios.flight()
    FlightLockScreenView(attributes: scenario.attributes, state: scenario.initialState)
        .background(FlightLockScreenView.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding()
}
