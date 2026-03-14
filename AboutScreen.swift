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
                    title: "Quick start (Home Screen)",
                    systemImage: "house.fill",
                    bullets: [
                        "Tap Take picture to capture a photo and scan.",
                                                "Or tap Import from library to scan a saved image.",
                        "You can use either option even if you don’t have a pouch cell in front of you (sample images work too)."
                    ]
                )

                infoCard(
                    title: "Scan with the camera (Take picture)",
                    systemImage: "camera.fill",
                    bullets: [
                        "From the Home Screen, tap Take picture (the large center capture button).",
                        "Point at the pouch cell (or any online reference image you want to test).",
                        "Keep it centered and in focus, then capture the photo.",
                        "You’ll get a result within seconds."
                    ]
                )

                infoCard(
                    title: "Import from Library (saved / online images)",
                    systemImage: "photo.on.rectangle",
                    bullets: [
                        "From the Home Screen, tap Import from library (photo icon).",
                        "Pick an image from Photos and the app will scan it right away.",
                        "To use an image from online: save it to Photos or take a screenshot, then import it here.",
                        "This is great for testing or scanning images shared by someone else."
                    ]
                )

                infoCard(
                    title: "Tips for best results",
                    systemImage: "wand.and.stars",
                    bullets: [
                        "Use good lighting and avoid strong glare.",
                        "Keep the pouch cell (or image) sharp and filling most of the frame.",
                        "Use the flash toggle if you’re in low light.",
                        "If a scan looks off, try a clearer photo or a different angle."
                    ]
                )

                infoCard(
                    title: "Accessibility features",
                    systemImage: "accessibility",
                    bullets: [
                        "Enable Speak results after scan in Menu → Accessibility to read results out loud.",
                        "Adjust speech rate, pitch, and voice, then use Test speech to preview settings.",
                        "Enable Haptics for vibration feedback on the results screen.",
                        "Buttons are labeled for VoiceOver (Menu, Take picture, Import from library)."
                    ]
                )

                Text("Note: This guide explains how to use the application. It does not replace professional inspection or safety procedures.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
                                }
            .padding(16)
        }
        .navigationTitle("How to Use")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Components

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("User Guide")
                .font(.title2.bold())

            Text("Scan a pouch cell using the camera, or import an image from your library and get a result within seconds.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Label("No pouch cell nearby? No problem — you can still scan from an online source using another device. Simply use either a laptop/another phone to find an image of a pouch cell or even a swollen phone battery and still get that immediate result.", systemImage: "checkmark.seal.fill")
                .font(.subheadline)
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
        "\(title). \(bullets.joined(separator: " "))"
    }
}

#Preview {
    NavigationStack {
        AboutScreen()
    }
}

