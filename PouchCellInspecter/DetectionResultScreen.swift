//
//  DetectionResultScreen.swift
//  PouchCellInspecter
//
//  Created by Oquba Khan on 12/16/25.
//

import SwiftUI
import UIKit

// MARK: - Domain

enum BatteryCondition: Equatable {
    case normal
    case bulging
    case unknown

    init(from rawResult: String) {
        let s = rawResult.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if s.contains("bulg") {
            self = .bulging
        } else if s.contains("normal") {
            self = .normal
        } else {
            self = .unknown
        }
    }

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .bulging: return "Bulging"
        case .unknown: return "Unknown"
        }
    }

    var shortExplanation: String {
        switch self {
        case .normal:
            return "No obvious swelling detected. Continue to handle and store the cell safely."
        case .bulging:
            return "Swelling may indicate gas buildup and elevated risk. Treat as potentially unsafe."
        case .unknown:
            return "The image couldn’t be confidently classified. Try again with better lighting and focus."
        }
    }
}

struct SafetyTipContent {
    let title: String
    let whatItMeans: String
    let whatToDoNow: [String]
    let prevention: [String]
    let whenToEscalate: [String]

    static func forCondition(_ condition: BatteryCondition) -> SafetyTipContent {
        switch condition {
        case .normal:
            return SafetyTipContent(
                title: "Safety tips for: Normal",
                whatItMeans: "The scan didn’t detect visible swelling. This does not guarantee the cell is healthy—visual checks can miss internal damage.",
                whatToDoNow: [
                    "Avoid puncturing, crushing, or bending the pouch cell.",
                    "Store at room temperature in a dry, ventilated area.",
                    "Keep away from metal objects that could short the terminals.",
                    "If the cell was recently stressed (impact/overheat), monitor it for warmth or odor."
                ],
                prevention: [
                    "Use the correct charger and charge profile (avoid overcharge).",
                    "Avoid high heat (car dashboards, direct sun, near heaters).",
                    "Don’t discharge below the manufacturer’s recommended cutoff.",
                    "Use protective packaging and avoid mechanical stress during handling/shipping."
                ],
                whenToEscalate: [
                    "If you notice heat, hissing, sweet/solvent odor, or rapid voltage drop, stop using the cell.",
                    "If the pouch begins to expand, treat it as bulging and follow the bulging guidance."
                ]
            )

        case .bulging:
            return SafetyTipContent(
                title: "Safety tips for: Bulging",
                whatItMeans: "Bulging can indicate internal gas generation (from damage, overcharge, overheating, or aging). This increases the risk of venting, leaking, or thermal runaway.",
                whatToDoNow: [
                    "Stop using/charging the cell immediately.",
                    "Move it to a non-flammable, well-ventilated area away from people and valuables.",
                    "If available, place it in a fire-resistant container (e.g., LiPo-safe bag/metal box) on a non-combustible surface.",
                    "Do NOT puncture, compress, or attempt to ‘flatten’ the pouch.",
                    "If the cell is hot, smoking, or hissing: evacuate the area and contact local emergency guidance."
                ],
                prevention: [
                    "Prevent overcharge: use a charger/BMS designed for the cell chemistry.",
                    "Avoid heat: keep operating and storage temps within spec.",
                    "Avoid mechanical damage: protect from bending, crushing, drops.",
                    "Retire cells that show repeated swelling, abnormal heat, or significant capacity loss."
                ],
                whenToEscalate: [
                    "Heat, smoke, hissing, or odor → treat as urgent.",
                    "Visible leakage or torn pouch → handle with gloves, avoid inhalation, and isolate.",
                    "Follow local disposal rules for damaged lithium batteries (many areas require special drop-off)."
                ]
            )

        case .unknown:
            return SafetyTipContent(
                title: "Safety tips for: Unknown",
                whatItMeans: "The scan couldn’t confidently determine the condition—this often happens with poor lighting, glare, heavy shadows, or the cell being too far/too close.",
                whatToDoNow: [
                    "Re-scan with bright, even lighting (avoid harsh reflections).",
                    "Fill most of the frame with the pouch cell and keep it in focus.",
                    "Capture the side profile as well—bulging is easier to see from an angle.",
                    "If you suspect swelling even without a confirmed result, follow the bulging precautions."
                ],
                prevention: [
                    "Keep cells away from heat and avoid charging unattended.",
                    "Inspect periodically for swelling, odor, discoloration, or damage.",
                    "Use appropriate chargers and avoid over-discharge."
                ],
                whenToEscalate: [
                    "If the cell feels warm at rest, smells unusual, looks swollen, or shows damage, stop use and isolate it.",
                    "If you are unsure, consult a professional battery technician or follow your organization’s safety SOP."
                ]
            )
        }
    }
}

struct DetectionResultScreen: View {
    let result: String

    // ✅ NEW: scanned/imported image
    let scannedImage: UIImage?

    let onScanAgain: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showSafetyTips = false

    private var condition: BatteryCondition { BatteryCondition(from: result) }

    init(result: String, scannedImage: UIImage? = nil, onScanAgain: @escaping () -> Void) {
        self.result = result
        self.scannedImage = scannedImage
        self.onScanAgain = onScanAgain
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background (same as other screens)
                Color(red: 0.86, green: 0.89, blue: 0.91)
                    .ignoresSafeArea()

                VStack(spacing: 24) {

                    // ✅ UPDATED: show image if available, otherwise show existing placeholder
                    Group {
                        if let uiImage = scannedImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(20)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.73, green: 0.81, blue: 0.86))
                                .frame(height: 180)
                                .overlay(
                                    Image(systemName: "camera")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(40)
                                        .foregroundColor(.black)
                                )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 6)

                    // Result text
                    Text("Battery is \(condition.displayName)")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Short explanation label
                    Text("Short Explanation")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.black)

                    Text(condition.shortExplanation)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)

                    Spacer()

                    // Buttons
                    VStack(spacing: 20) {
                        Button {
                            dismiss()
                            DispatchQueue.main.async {
                                onScanAgain()
                            }
                        } label: {
                            Text("Scan Again")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.73, green: 0.81, blue: 0.86))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 60)

                        Button {
                            showSafetyTips = true
                        } label: {
                            Text("View Safety Tips")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.73, green: 0.81, blue: 0.86))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 60)
                    }

                    Spacer(minLength: 24)
                }
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .sheet(isPresented: $showSafetyTips) {
                SafetyTipsSheet(content: SafetyTipContent.forCondition(condition))
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct SafetyTipsSheet: View {
    let content: SafetyTipContent
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(content.whatItMeans)
                        .font(.body)
                        .foregroundColor(.primary)

                    tipsSection("What to do now", bullets: content.whatToDoNow)
                    tipsSection("Prevention", bullets: content.prevention)
                    tipsSection("When to escalate", bullets: content.whenToEscalate)

                    Text("Note: This is general safety guidance and not a substitute for professional evaluation or local regulations.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .navigationTitle(content.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func tipsSection(_ title: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            ForEach(bullets.indices, id: \.self) { idx in
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                        .font(.body)
                    Text(bullets[idx])
                        .font(.body)
                }
            }
        }
    }
}

struct DetectionResultScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetectionResultScreen(result: "Normal", scannedImage: nil, onScanAgain: {})
    }
}
