//
//  OnboardingPageView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/28/26.
//

import SwiftUI

struct OnboardingPageView: View {

    var imageName: String
    var welcomeText: String? = nil
    var title: String
    var subtitle: String
    var features: [String]

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.primary.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 8)
                .accessibilityHidden(true)

            if let welcomeText = welcomeText {
                Text(welcomeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            if !features.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                                .accessibilityHidden(true)

                            Text(feature)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}

