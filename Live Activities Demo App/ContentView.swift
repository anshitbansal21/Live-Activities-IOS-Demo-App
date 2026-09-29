//
//  ContentView.swift
//  The picker: every Live Activity design in the app, with a live preview and a
//  switch to put it on the Lock Screen.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = LiveActivityManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    intro

                    if !manager.areActivitiesEnabled {
                        banner(
                            symbol: "exclamationmark.triangle.fill",
                            tint: .orange,
                            text: "Live Activities are turned off for this app. Enable them in Settings to try the demos.",
                            actionTitle: "Open Settings",
                            action: openSettings
                        )
                    }

                    statusStrip

                    ForEach(LiveActivityDemo.allCases) { demo in
                        DemoCard(demo: demo, manager: manager)
                    }

                    footer
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 36)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Live Activities")
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { manager.refreshSystemActivityCount() }
            }
            .navigationDestination(for: LiveActivityDemo.self) { demo in
                DemoDetailView(demo: demo, manager: manager)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Stop all") { manager.stopAll() }
                        .disabled(manager.activeDemos.isEmpty && manager.systemActivityCount == 0)
                }
            }
        }
    }

    /// Permanent read-out of the two things that decide whether a start will
    /// work at all: the system switch, and how many activities iOS is holding.
    private var statusStrip: some View {
        HStack(spacing: 8) {
            Image(systemName: manager.areActivitiesEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(manager.areActivitiesEnabled ? .green : .red)
            Text(manager.areActivitiesEnabled ? "Live Activities allowed" : "Live Activities blocked in Settings")
                .font(.system(size: 13, weight: .medium))
            Spacer(minLength: 4)
            Text("\(manager.systemActivityCount) live in iOS")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Five patterns, one switch each")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text("Turn one on and it appears on the Lock Screen, in the Dynamic Island, on the Apple Watch Smart Stack and in the Mac menu bar. Each demo scripts itself through a few states so you can watch it update.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Swipe left on a Lock Screen activity to dismiss it — the toggle here follows along.", systemImage: "hand.draw")
            Label("Long-press the Dynamic Island to see the expanded layout.", systemImage: "iphone.gen3")
            Label("Alerts fire on a few steps, which is what pushes the update to your wrist.", systemImage: "applewatch")
            Label("Live Activities have no permission prompt — nothing to allow on first launch. The only switch is Settings › this app › Live Activities.", systemImage: "bell.badge.slash")
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private func banner(
        symbol: String,
        tint: Color,
        text: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 6) {
                Text(text).font(.system(size: 13))
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(tint.opacity(0.12)))
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Card

struct DemoCard: View {
    let demo: LiveActivityDemo
    @ObservedObject var manager: LiveActivityManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: demo.symbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(demo.accent)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(demo.accent.opacity(0.14)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(demo.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text(demo.tagline)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                Toggle("", isOn: Binding(
                    get: { manager.isRunning(demo) },
                    set: { manager.setRunning(demo, $0) }
                ))
                .labelsHidden()
                .tint(demo.accent)
            }

            LiveActivityPreview(demo: demo, manager: manager)

            if let failure = manager.failure(for: demo) {
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    Text(failure)
                        .font(.system(size: 12))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.orange.opacity(0.12)))
            }

            HStack {
                if manager.isRunning(demo) {
                    RunningBadge(demo: demo, manager: manager)
                } else {
                    Text("Runs for \(demo.runDurationText)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                NavigationLink(value: demo) {
                    HStack(spacing: 3) {
                        Text("Details")
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
    }
}

#Preview {
    ContentView()
}
