//
//  SafetyInfoView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 2/10/26.
//

import SwiftUI

struct SafetyInfoView: View {

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Top warning card
                    warningCard
                    
                    // Why it's dangerous
                    infoCard(
                        title: "Why a bulging battery is dangerous",
                        systemImage: "exclamationmark.triangle.fill",
                        bullets: [
                            "Swelling often means gas is building up inside the cell due to damage, overheating, overcharging, or internal failure.",
                            "Pressure can weaken the pouch casing — puncture or rupture can lead to venting hot gases and flammable electrolyte.",
                            "A failing lithium battery can enter thermal runaway, causing intense heat, smoke, or fire."
                        ]
                    )
                    
                    // Immediate actions
                    infoCard(
                        title: "Safest immediate actions",
                        systemImage: "checkmark.shield.fill",
                        bullets: [
                            "Stop using the device immediately.",
                            "Disconnect from the charger (do not continue charging).",
                            "Power off the device if you can do so safely.",
                            "Move it away from anything flammable and people/pets.",
                            "Place it on a non-flammable surface (like concrete, tile, or metal) in a well-ventilated area.",
                            "If you notice heat, smoke, hissing, or a strong chemical smell: evacuate the area and call local emergency services."
                        ]
                    )
                    
                    // Do / Don't
                    HStack(spacing: 12) {
                        doCard
                        dontCard
                    }
                    
                    // Disposal guidance (general)
                    infoCard(
                        title: "Disposal & next steps",
                        systemImage: "arrow.triangle.2.circlepath",
                        bullets: [
                            "Do not throw it in household trash or standard recycling.",
                            "Contact your local battery recycling program or hazardous waste drop-off.",
                            "If this is a device battery, consider contacting the manufacturer or a certified repair shop for safe replacement/disposal."
                        ]
                    )
                    
                    // Disclaimer
                    Text("This screen provides general safety guidance and is not a substitute for professional advice. If there is any immediate danger, prioritize safety and contact local emergency services.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                        .accessibilityLabel("Disclaimer. This screen provides general safety guidance and is not a substitute for professional advice. If there is any immediate danger, prioritize safety and contact local emergency services.")
                }
                .padding(16)
            }
            .navigationTitle("Safety Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    // MARK: - Components

    private var warningCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("If it’s hot, smoking, or smells like chemicals—move away and get help.", systemImage: "flame.fill")
                .font(.headline)
            Text("Bulging lithium batteries can become hazardous quickly. Treat swelling as a serious warning sign.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
        )
    }

    private func infoCard(title: String, systemImage: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(bullets, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 7)
                            .foregroundStyle(.secondary)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    private var doCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Do", systemImage: "checkmark.circle.fill")
                .font(.headline)
            bullet("Stop using it")
            bullet("Disconnect charger")
            bullet("Keep it away from flammables")
            bullet("Use a ventilated area")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Do. Stop using it. Disconnect charger. Keep it away from flammables. Use a ventilated area.")
    }

    private var dontCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Don’t", systemImage: "xmark.circle.fill")
                .font(.headline)
            bullet("Puncture or squeeze it")
            bullet("Keep charging it")
            bullet("Put it in the trash")
            bullet("Store it near heat")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Don't. Puncture or squeeze it. Keep charging it. Put it in the trash. Store it near heat.")
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .padding(.top, 7)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}
