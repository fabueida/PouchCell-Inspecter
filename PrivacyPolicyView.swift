//
//  PrivacyPolicyView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 3/7/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    private let privacyPolicyURL = URL(string: "https://github.com/fabueida/PouchCellInspector-PrivacyPolicy")!
    private let emailURL = URL(string: "mailto:pouchcellinspector@gmail.com")!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                introCard
                keyPointsCard
                fullPolicyCard
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PRIVACY POLICY")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Last updated, April 8, 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("""
This Privacy Policy for Pouch Cell Inspecter, conducted as part of a research project at the University of Michigan Dearborn, describes how and why we may access, process, and store information when you use our application (“Services”).
""")
            .font(.body)
            .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 12) {
                bullet("""
Use our mobile application, Pouch Cell Inspecter, to inspect or review pouch cells using your device camera
""")

                bullet("""
View previously scanned classifications that are stored locally on your device for your convenience
""")

                bullet("""
Adjust app features and preferences such as speech output, appearance, haptics, and photo-saving behavior
""")

                bullet("""
Contact us for support, feedback, or questions related to the app
""")
            }

            Text("""
Pouch Cell Inspecter is designed to keep your data private. At this time, the app does not rely on cloud storage for its core functionality. Inspection-related processing and previously scanned classifications are intended to remain on your device, helping reduce unnecessary data sharing and keeping you in control of your information.
""")
            .font(.body)
            .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("""
Questions or concerns? Reading this Privacy Policy will help you understand what information may be used by the app, how it is handled, and what choices you have through the app and iOS settings. For further questions or concerns, please feel free to email us at:
""")
                .font(.body)
                .foregroundStyle(.primary)

                Link("pouchcellinspector@gmail.com", destination: emailURL)
                    .font(.body)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var keyPointsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUMMARY OF KEY POINTS")
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Text("""
This summary provides a brief overview of our Privacy Policy. You can read the full policy below for more detail.
""")
            .font(.body)
            .foregroundStyle(.secondary)

            Text("""
Pouch Cell Inspecter is built to process core inspection data locally on your device.

Previously scanned classifications may be stored locally on your device so you can review past results, but this information is not collected by us.

The app does not use cloud storage for its core functionality at this time.

Captured images are only saved to your Photos library if you choose to enable that setting.

Saving classifications within the app and saving photos to your Photos library are different features: both are local to your device, and neither means we collect your data remotely.

App preferences such as speech, haptics, and appearance are stored locally on your device so your settings can be remembered.

We do not sell your data or use the app’s core inspection features for advertising purposes.
""")
            .font(.body)
            .foregroundStyle(.primary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var fullPolicyCard: some View {
        VStack(alignment: .leading, spacing: 22) {

            policySection(
                title: "What information do we process?",
                body: """
When you use Pouch Cell Inspecter, the app may process information such as images captured with your device camera, scan or inspection results generated by the app, previously scanned classifications saved for your later review, and app preferences you choose to enable or disable.

These preferences may include speech settings, appearance settings, haptic feedback settings, and whether captured images should be saved to your Photos library.
"""
            )

            policySection(
                title: "How do we process your information?",
                body: """
Pouch Cell Inspecter is designed so that core inspection-related processing happens locally on your device.

At this time, the app does not rely on cloud storage for core functionality. This means inspection images, classifications, and related results are intended to remain on-device unless you deliberately choose to save or share them using features provided by your device.
"""
            )

            policySection(
                title: "Do we collect or store personal data remotely?",
                body: """
At this time, Pouch Cell Inspecter does not use remote cloud storage for the app’s core inspection features.

Previously scanned classifications may be stored locally on your device within the app so you can access prior results, but we do not collect this information remotely.

App settings and preferences are also stored locally on your device so the app can remember how you want it to behave.
"""
            )

            policySection(
                title: "Previously scanned classifications and saved photos",
                body: """
Pouch Cell Inspecter may keep previously scanned classifications locally on your device so you can review earlier inspection outcomes inside the app.

This is different from the optional “Save to Photos” feature. If you enable that setting, captured images may be saved to your personal Photos library on your device. If that setting remains off, the app will not automatically save captured images to Photos.

In both cases, the information remains under your control on your device, and we do not collect it as user data for remote storage, advertising, or sale.
"""
            )

            policySection(
                title: "Camera and Photos access",
                body: """
The app may request access to your camera so that you can inspect pouch cells using your device.

If you enable the “Save to Photos” setting, captured images may be saved to your Photos library on your device. If that setting remains off, the app will not automatically save captured images to Photos.
"""
            )

            policySection(
                title: "Accessibility features",
                body: """
Pouch Cell Inspecter includes optional accessibility-related features, such as speech output and haptic feedback, to improve usability for people who are visually impaired.

If enabled, these features use capabilities available on your device. Your accessibility-related preferences are stored locally so they persist between app launches.
"""
            )

            policySection(
                title: "Data sharing",
                body: """
We do not sell, rent, or use your inspection-related information for advertising.

Because the app is designed around local on-device functionality, we aim to minimize unnecessary collection and sharing of user data. Previously scanned classifications and optionally saved photos are intended to stay on your device unless you choose to share them yourself.
"""
            )

            policySection(
                title: "Your choices",
                body: """
You can control important privacy-related behaviors through the app and through iOS Settings, including camera access, Photos access, speech settings, haptics, whether images are automatically saved, and how long previously scanned classifications remain available on your device if your app provides that option.

You may review or change permissions for Pouch Cell Inspecter at any time through your device settings.
"""
            )

            policySection(
                title: "Changes to this Privacy Policy",
                body: """
We may update this Privacy Policy from time to time to reflect changes to the app, its features, or legal requirements. When we do, we will revise the “Last updated” date shown at the top of this screen.
"""
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Contact and feedback")
                    .font(.headline)

                Text("If you have any questions or concerns about this Privacy Policy or the privacy practices of Pouch Cell Inspecter, you may contact us at:")
                    .font(.body)

                Link("pouchcellinspector@gmail.com", destination: emailURL)
                    .font(.body)

                Text("Or, if you'd like to read it in full:")
                    .font(.body)

                Link("Read our privacy policy online", destination: privacyPolicyURL)
                    .font(.body)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(body)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
