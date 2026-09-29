//
//  DemoDetailView.swift
//  One design at a time: the preview, the notes on the pattern, and the
//  scripted timeline so you can follow along while it runs.
//

import SwiftUI

struct DemoDetailView: View {
    let demo: LiveActivityDemo
    @ObservedObject var manager: LiveActivityManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LiveActivityPreview(demo: demo, manager: manager)

                Button {
                    manager.setRunning(demo, !manager.isRunning(demo))
                } label: {
                    Label(
                        manager.isRunning(demo) ? "Stop this activity" : "Start on the Lock Screen",
                        systemImage: manager.isRunning(demo) ? "stop.fill" : "play.fill"
                    )
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(manager.isRunning(demo) ? Color.red : demo.accent)
                )

                section(title: "Why apps use it", body: demo.useCase)
                section(title: "In the Dynamic Island", body: demo.islandNote)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Scripted timeline")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(demo.timeline.enumerated()), id: \.offset) { index, label in
                            timelineRow(index: index, label: label)
                            if index < demo.timeline.count - 1 {
                                Divider().padding(.leading, 34)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 36)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(demo.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(title: String, body text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func timelineRow(index: Int, label: String) -> some View {
        let active = manager.isRunning(demo) && manager.currentStep[demo] == index
        let past = manager.isRunning(demo) && (manager.currentStep[demo] ?? 0) > index
        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(active ? demo.accent : (past ? demo.accent.opacity(0.35) : Color.secondary.opacity(0.18)))
                    .frame(width: 20, height: 20)
                if past {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(active ? .white : .secondary)
                }
            }
            Text(label)
                .font(.system(size: 14, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? .primary : .secondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }
}
