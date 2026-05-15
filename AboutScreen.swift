//
//  AboutScreen.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 2/27/26.
//

import SwiftUI

struct AboutScreen: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                introCard

                infoCard(
                    title: "Scan with Camera",
                    systemImage: "camera.fill",
                    bullets: [
                        "From the Home Screen, tap Take picture.",
                        "Position the pouch cell clearly in the frame with good lighting.",
                        "Capture the photo and wait for the app to analyze it."
                    ]
                )

                infoCard(
                    title: "Import from Photos",
                    systemImage: "photo.on.rectangle",
                    bullets: [
                        "From the Home Screen, tap Import from library.",
                        "Choose an image from Photos and the app will process it automatically.",
                        "For best results, use a sharp image where the pouch cell is visible and not blocked."
                    ]
                )

                infoCard(
                    title: "Share from Another App",
                    systemImage: "square.and.arrow.up",
                    bullets: [
                        "Share an image from apps like Photos, Messages, WhatsApp, Safari, or Files.",
                        "Tap Share, then select Pouch Cell Inspector.",
                        "The app opens and processes the shared image automatically."
                    ]
                )

                infoCard(
                    title: "View Results",
                    systemImage: "doc.text.magnifyingglass",
                    bullets: [
                        "After analysis, the results screen shows whether the image appears Normal, Bulging, or Unknown.",
                        "Review the short explanation shown with the classification.",
                        "If the result does not look right, try another clear photo from a different angle."
                    ]
                )

                infoCard(
                    title: "Safety Tips",
                    systemImage: "checkmark.shield.fill",
                    bullets: [
                        "Open Safety Info from the Home Screen or results screen for action-focused safety guidance.",
                        "Use Safety Info when you need to know what to do after a result or when a battery appears unsafe."
                    ]
                )

                infoCard(
                    title: "Scan History",
                    systemImage: "clock.arrow.circlepath",
                    bullets: [
                        "Open History from the Home Screen to review available past scan results.",
                        "Use history to compare recent classifications that are stored locally on your device."
                    ]
                )

                infoCard(
                    title: "Settings and Preferences",
                    systemImage: "gearshape.fill",
                    bullets: [
                        "Open Settings to adjust speech feedback, haptics, appearance, and photo-saving behavior.",
                        "Use Test speech to preview result readouts when speech feedback is enabled.",
                        "Settings also includes privacy information, this guide, and battery education."
                    ]
                )

                Text("Note: This guide explains how to use the application. It does not replace professional inspection or safety procedures.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
            .padding(16)
        }
        .navigationTitle("Quick Start Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Components

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Start Guide")
                .font(.title2.bold())

            Text("Learn the main ways to scan a pouch cell, review results, and adjust app preferences.")
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
}

#Preview {
    NavigationStack {
        AboutScreen()
    }
}
