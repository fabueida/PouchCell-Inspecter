//
//  BatteryEducationView.swift
//  PouchCellInspecter
//
//  Created by Codex on 5/14/26.
//

import SwiftUI

struct BatteryEducationView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                introCard

                educationCard(
                    title: "What are lithium-ion batteries?",
                    systemImage: "battery.100percent",
                    body: "Lithium-ion batteries are rechargeable batteries used in phones, laptops, tablets, tools, electric vehicles, and many portable devices."
                )

                educationCard(
                    title: "Why are they important?",
                    systemImage: "bolt.fill",
                    body: "They store a lot of energy in a compact size, recharge efficiently, and power many modern devices that people use every day."
                )

                educationCard(
                    title: "What is a pouch cell?",
                    systemImage: "rectangle.roundedtop.fill",
                    body: "A pouch cell is a type of lithium-ion battery packaged in a soft, flexible outer pouch instead of a hard metal case."
                )

                educationCard(
                    title: "Why can batteries bulge?",
                    systemImage: "arrow.up.left.and.arrow.down.right",
                    body: "Bulging can happen when gas builds up inside the cell due to age, damage, overcharging, overheating, manufacturing defects, or internal failure."
                )

                educationCard(
                    title: "Why bulging matters",
                    systemImage: "exclamationmark.triangle.fill",
                    body: "A bulging battery may be unsafe. It should not be pressed, punctured, charged, bent, or continued to use."
                )

                resultsCard

                educationCard(
                    title: "Privacy and on-device processing",
                    systemImage: "lock.shield.fill",
                    body: "Pouch Cell Inspector processes images on the device using on-device machine learning. Classification does not require uploading images to a server."
                )

                educationCard(
                    title: "Safety reminder",
                    systemImage: "checkmark.shield.fill",
                    body: "The app is an assistive screening tool, not a replacement for professional inspection. If a battery looks damaged, swollen, hot, leaking, or unsafe, stop using it and follow proper disposal or professional guidance."
                )
            }
            .padding(16)
        }
        .navigationTitle("Battery Education")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Battery Education")
                .font(.title2.bold())

            Text("Learn what pouch-cell swelling can mean and how to interpret app results before reviewing action-focused safety guidance.")
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
    }

    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Understanding results", systemImage: "list.bullet.rectangle.fill")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                resultRow(title: "Normal", text: "The app did not detect obvious visual swelling.")
                resultRow(title: "Bulging", text: "The app detected signs that may indicate swelling or deformation.")
                resultRow(title: "Unknown", text: "The app could not confidently detect a pouch cell or classify the image.")
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
    }

    private func educationCard(title: String, systemImage: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            Text(body)
                .font(.subheadline)
                .foregroundStyle(.primary)
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
    }

    private func resultRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.subheadline.bold())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        BatteryEducationView()
    }
}
