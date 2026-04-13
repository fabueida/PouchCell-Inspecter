//
//  HistoryView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 4/2/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @State private var selectedItem: ScanHistoryItem?
    @State private var showDeleteAllConfirmation = false

    private var groupedItems: [(String, [ScanHistoryItem])] {
        let grouped = Dictionary(grouping: historyStore.items) { item in
            item.createdAt.formatted(.dateTime.month(.wide).year())
        }

        return grouped
            .map { ($0.key, $0.value.sorted { $0.createdAt > $1.createdAt }) }
            .sorted { lhs, rhs in
                guard let leftDate = lhs.1.first?.createdAt,
                      let rightDate = rhs.1.first?.createdAt else {
                    return lhs.0 > rhs.0
                }
                return leftDate > rightDate
            }
    }

    var body: some View {
        List {
            if historyStore.items.isEmpty {
                emptyState
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 28, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.clear)
            } else {
                summaryCard
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)

                ForEach(groupedItems, id: \.0) { sectionTitle, sectionItems in
                    Section {
                        ForEach(sectionItems) { item in
                            Button {
                                selectedItem = item
                            } label: {
                                HistoryRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                        }
                        .onDelete { offsets in
                            deleteItems(offsets, from: sectionItems)
                        }
                    } header: {
                        Text(sectionTitle)
                            .accessibilityAddTraits(.isHeader)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Scan History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if historyStore.hasHistory {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteAllConfirmation = true
                    } label: {
                        Text("Clear History")
                    }
                    .accessibilityLabel("Clear history")
                    .accessibilityHint("Removes all saved classification results from this device.")
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            DetectionResultScreen(
                result: item.resultText,
                scannedImage: item.image,
                shouldAnnounceAccessibilityFeedback: false
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Clear history?", isPresented: $showDeleteAllConfirmation) {
            Button("Clear", role: .destructive) {
                historyStore.clearAll()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This removes saved classification results from this device. This action cannot be undone.")
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Classification History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.headline)

            Text("Review previous scan results and reopen them without rescanning.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let latest = historyStore.items.first {
                Text("Last scan: \(latest.relativeTimestamp)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(summaryAccessibilityLabel)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("No scans saved yet")
                .font(.title3.weight(.semibold))

            Text("After a battery is analyzed, its classification result will appear here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityElement(children: .combine)
            }

    private var summaryAccessibilityLabel: String {
        if let latest = historyStore.items.first {
            return "Classification history. Last scan \(latest.relativeTimestamp)."
        } else {
            return "Classification history."
        }
    }

    private func deleteItems(_ offsets: IndexSet, from sectionItems: [ScanHistoryItem]) {
        let idsToDelete = offsets.map { sectionItems[$0].id }
        let globalOffsets = IndexSet(
            historyStore.items.enumerated().compactMap { index, item in
                idsToDelete.contains(item.id) ? index : nil
            }
        )
        historyStore.delete(at: globalOffsets)
    }
}

private struct HistoryRow: View {
    let item: ScanHistoryItem

    var body: some View {
        HStack(spacing: 14) {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.condition.displayName)
                    .font(.headline)
                    .foregroundStyle(primaryColor(for: item.condition))

                Text(item.resultText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(item.fullTimestamp)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Opens this saved classification result.")
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityLabel: String {
        if item.image != nil {
            return "\(item.condition.displayName). Saved result \(item.resultText). Scanned on \(item.fullTimestamp)."
        } else {
            return "\(item.condition.displayName). Saved result \(item.resultText). No saved image. Scanned on \(item.fullTimestamp)."
        }
    }

    private func primaryColor(for condition: BatteryCondition) -> Color {
        switch condition {
        case .normal:
            return .green
        case .bulging:
            return .red
        case .unknown:
            return .orange
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(ScanHistoryStore.shared)
    }
}
