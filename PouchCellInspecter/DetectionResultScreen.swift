//
//  DetectionResultScreen.swift
//  PouchCellInspecter
//
//  Created by Oquba Khan on 12/16/25.
//

import SwiftUI
import UIKit

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

    var speechPhrase: String {
        switch self {
        case .normal:
            return "Battery is normal."
        case .bulging:
            return "Battery is bulging."
        case .unknown:
            return "Battery condition is unknown."
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
                    "Use protective packaging and avoid mechanical stress during handling or shipping."
                ],
                whenToEscalate: [
                    "If you notice heat, hissing, sweet or solvent odor, or rapid voltage drop, stop using the cell.",
                    "If the pouch begins to expand, treat it as bulging and follow the bulging guidance."
                ]
            )
        case .bulging:
            return SafetyTipContent(
                title: "Safety tips for: Bulging",
                whatItMeans: "Bulging can indicate internal gas generation from damage, overcharge, overheating, or aging. This increases the risk of venting, leaking, or thermal runaway.",
                whatToDoNow: [
                    "Stop using or charging the cell immediately.",
                    "Move it to a non-flammable, well-ventilated area away from people and valuables.",
                    "If available, place it in a fire-resistant container on a non-combustible surface.",
                    "Do not puncture, compress, or attempt to flatten the pouch.",
                    "If the cell is hot, smoking, or hissing, evacuate the area and follow local emergency guidance."
                ],
                prevention: [
                    "Prevent overcharge by using a charger or battery management system designed for the cell chemistry.",
                    "Avoid heat and keep operating and storage temperatures within specification.",
                    "Avoid mechanical damage from bending, crushing, or drops.",
                    "Retire cells that show repeated swelling, abnormal heat, or significant capacity loss."
                ],
                whenToEscalate: [
                    "Heat, smoke, hissing, or odor should be treated as urgent.",
                    "Visible leakage or a torn pouch should be isolated and handled carefully.",
                    "Follow local disposal rules for damaged lithium batteries."
                ]
            )
        case .unknown:
            return SafetyTipContent(
                title: "Safety tips for: Unknown",
                whatItMeans: "The scan couldn’t confidently determine the condition. This often happens with poor lighting, glare, heavy shadows, or the cell being too far away or out of focus.",
                whatToDoNow: [
                    "Re-scan with bright, even lighting and avoid harsh reflections.",
                    "Fill most of the frame with the pouch cell and keep it in focus.",
                    "Capture the side profile as well, since bulging is easier to see from an angle.",
                    "If you suspect swelling even without a confirmed result, follow the bulging precautions."
                ],
                prevention: [
                    "Keep cells away from heat and avoid charging unattended.",
                    "Inspect periodically for swelling, odor, discoloration, or damage.",
                    "Use appropriate chargers and avoid over-discharge."
                ],
                whenToEscalate: [
                    "If the cell feels warm at rest, smells unusual, looks swollen, or shows damage, stop use and isolate it.",
                    "If you are unsure, consult a professional battery technician or follow your organization’s safety procedures."
                ]
            )
        }
    }
}

struct DetectionResultScreen: View {
    let result: String
    let scannedImage: UIImage?
    var shouldAnnounceAccessibilityFeedback: Bool = true

    @Environment(\.dismiss) private var dismiss
    @State private var showSafetyTips = false

    @EnvironmentObject private var speechStore: SpeechSettingsStore
    @State private var didSpeakResult = false

    @AppStorage("pref_haptics") private var hapticsEnabled: Bool = false
    @State private var didPlayHaptic = false

    private var condition: BatteryCondition { BatteryCondition(from: result) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.86, green: 0.89, blue: 0.91)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
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

                    Text("Battery is \(condition.displayName)")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text("Short Explanation")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.black)

                    Text(condition.shortExplanation)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)

                    Spacer()

                    Button {
                        showSafetyTips = true
                    } label: {
                        Text("View Safety Tips")
                            .accessibilityHint("Shows an overview on what to do depending on clasification result.")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.73, green: 0.81, blue: 0.86))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 60)

                    Spacer(minLength: 24)
                }
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                guard shouldAnnounceAccessibilityFeedback else { return }
                guard !didSpeakResult else { return }

                didSpeakResult = true

                let phrase = condition.speechPhrase

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    SpeechManager.shared.speak(phrase, settings: speechStore.settings)
                }

                playResultHapticsIfNeeded()
            }
            .onDisappear {
                if shouldAnnounceAccessibilityFeedback {
                    SpeechManager.shared.stop()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showSafetyTips) {
                SafetyTipsSheet(content: SafetyTipContent.forCondition(condition))
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func playResultHapticsIfNeeded() {
        guard shouldAnnounceAccessibilityFeedback else { return }
        guard hapticsEnabled, !didPlayHaptic else { return }

        didPlayHaptic = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            switch condition {
            case .normal:
                let gen = UINotificationFeedbackGenerator()
                gen.prepare()
                gen.notificationOccurred(.success)

            case .bulging:
                let note = UINotificationFeedbackGenerator()
                note.prepare()
                note.notificationOccurred(.warning)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.prepare()
                    impact.impactOccurred()
                }

            case .unknown:
                let note = UINotificationFeedbackGenerator()
                note.prepare()
                note.notificationOccurred(.warning)
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
        DetectionResultScreen(result: "Normal", scannedImage: nil)
            .environmentObject(SpeechSettingsStore.shared)
            .environmentObject(ScanHistoryStore.shared)
    }
}
