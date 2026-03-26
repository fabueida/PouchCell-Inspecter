//
//  SafetyInfoView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 2/10/26.
//

import SwiftUI

struct SafetyInfoView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                warningCard

                infoCard(
                    title: "Why a bulging battery is dangerous",
                    systemImage: "exclamationmark.triangle.fill",
                    bullets: [
                        "Swelling can indicate gas buildup from damage, overheating, overcharging, or internal failure.",
                        "Pressure can weaken the pouch casing. A puncture or rupture can vent hot gases and flammable electrolyte.",
                        "A failing lithium battery can enter thermal runaway, causing intense heat, smoke, or fire."
                    ]
                )

                infoCard(
                    title: "Safest immediate actions",
                    systemImage: "checkmark.shield.fill",
                    bullets: [
                        "Stop using the device immediately.",
                        "Disconnect from the charger (do not continue charging).",
                        "Power off the device if you can do so safely.",
                        "Move it away from people, pets, and anything flammable.",
                        "Place it on a non-flammable surface (concrete, tile, or metal) in a well-ventilated area.",
                        "If you notice heat, smoke, hissing, or a strong chemical smell: evacuate and call local emergency services."
                    ]
                )

                doDontGrid

                infoCard(
                    title: "Disposal and next steps",
                    systemImage: "arrow.triangle.2.circlepath",
                    bullets: [
                        "Do not throw it in household trash or standard recycling.",
                        "Contact your local battery recycling program or hazardous waste drop-off site.",
                        "For device batteries, consider contacting the manufacturer or a certified repair shop for safe replacement and disposal."
                    ]
                )

                Text("This screen provides general safety guidance and is not a substitute for professional advice. If there is immediate danger, prioritize safety and contact local emergency services.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
                    .accessibilityLabel("Disclaimer. This screen provides general safety guidance and is not a substitute for professional advice. If there is immediate danger, prioritize safety and contact local emergency services.")
            }
            .padding(16)
        }
        .navigationTitle("Safety Info")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Components

    private var warningCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("If it’s hot, smoking, or smells like chemicals, move away and get help.", systemImage: "flame.fill")
                .font(.headline)

            Text("Bulging lithium batteries can become hazardous quickly. Treat swelling as a serious warning sign.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private func infoCard(title: String, systemImage: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(bullets, id: \.self) { item in
                    bulletRow(item)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityCardLabel(title: title, bullets: bullets))
    }

    private var doDontGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            actionCard(
                title: "Do",
                systemImage: "checkmark.circle.fill",
                bullets: [
                    "Stop using it.",
                    "Disconnect the charger.",
                    "Keep it away from flammables.",
                    "Use a ventilated area."
                ]
            )

            actionCard(
                title: "Don’t",
                systemImage: "xmark.circle.fill",
                bullets: [
                    "Puncture or squeeze it.",
                    "Keep charging it.",
                    "Put it in the trash.",
                    "Store it near heat."
                ]
            )
        }
    }

    private func actionCard(title: String, systemImage: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            ForEach(bullets, id: \.self) { item in
                bulletRow(item)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading) // ✅ equal height
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityCardLabel(title: title, bullets: bullets))
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .padding(.top, 7)
                .foregroundStyle(.secondary)

            Text(text)
                .font(.subheadline)
        }
    }

    private func accessibilityCardLabel(title: String, bullets: [String]) -> String {
        let joined = bullets.joined(separator: " ")
        return "\(title). \(joined)"
    }
}


