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
                        "Pressure can weaken the pouch casing. A puncture or rupture can release hot gases or battery chemicals.",
                        "Continued use may increase the risk of device damage, overheating, or battery failure."
                    ]
                )

                infoCard(
                    title: "Safest immediate actions",
                    systemImage: "checkmark.shield.fill",
                    bullets: [
                        "Stop using the device if the battery appears swollen, damaged, hot, leaking, or unsafe.",
                        "Disconnect from the charger and do not continue charging a visibly swollen battery.",
                        "Power off the device if you can do so safely.",
                        "Move it away from people, pets, and anything flammable.",
                        "Place it on a non-flammable surface, such as concrete, tile, or metal, in a well-ventilated area."
                    ]
                )

                doDontGrid

                infoCard(
                    title: "When Batteries Should Be Replaced",
                    systemImage: "battery.25percent",
                    bullets: [
                        "Replace or professionally service a battery that appears swollen or physically deformed.",
                        "Seek replacement if the device screen, trackpad, back cover, or casing is lifting or separating.",
                        "Treat unusual overheating, expanding over time, abnormal charging behavior, leakage, odor, smoke, discoloration, punctures, or impact damage as warning signs."
                    ]
                )

                infoCard(
                    title: "General Replacement Guidance",
                    systemImage: "wrench.and.screwdriver.fill",
                    bullets: [
                        "Avoid puncturing, bending, crushing, pressing, or trying to flatten a swollen battery.",
                        "Use a qualified technician, authorized repair provider, or manufacturer guidance when possible.",
                        "Use manufacturer-approved or reputable replacement parts that match the device requirements.",
                        "Do not try to remove or replace a swollen pouch cell yourself unless you are properly trained and have the right safety equipment.",
                        "Keep the device away from heat, flammable materials, and direct sunlight while you arrange service."
                    ]
                )

                infoCard(
                    title: "Warning Signs",
                    systemImage: "eye.trianglebadge.exclamationmark.fill",
                    bullets: [
                        "Visible swelling, bubbling, or a soft pouch that looks inflated.",
                        "A screen, case, keyboard, or panel lifting away from the device body.",
                        "Unusual heat during use, storage, or charging.",
                        "Leaking fluid, strong odor, smoke, discoloration, or new physical damage."
                    ]
                )

                infoCard(
                    title: "When to Escalate",
                    systemImage: "phone.fill",
                    bullets: [
                        "Move away and seek immediate help if you see smoke, rapid swelling, leaking fluid, or signs of burning.",
                        "If the device becomes excessively hot or gives off a burning or chemical smell, stop handling it and contact local emergency or hazardous waste guidance.",
                        "Do not transport a battery that appears actively overheating, leaking, smoking, or rapidly swelling unless local safety guidance tells you how to do so."
                    ]
                )

                infoCard(
                    title: "Disposal and Recycling",
                    systemImage: "arrow.triangle.2.circlepath",
                    bullets: [
                        "Do not throw damaged lithium-ion batteries in household trash.",
                        "Use an approved battery recycling, e-waste, or hazardous waste drop-off location.",
                        "For device batteries, consider contacting the manufacturer or a certified repair shop for safe replacement and disposal."
                    ]
                )

                infoCard(
                    title: "Important Reminder",
                    systemImage: "info.circle.fill",
                    bullets: [
                        "Pouch Cell Inspector is designed as an assistive screening and educational tool.",
                        "If a battery appears damaged or unsafe, follow professional repair and safety guidance.",
                        "If there is immediate danger, prioritize personal safety and contact local emergency services."
                    ]
                )
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

