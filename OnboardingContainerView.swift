//
//  OnboardingContainerView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/28/26.
//

import SwiftUI

struct OnboardingContainerView: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let lastPageIndex = 1

    var body: some View {
        VStack(spacing: 0) {

            header

            TabView(selection: $currentPage) {
                OnboardingPageView(
                    imageName: "OnboardingIcon",
                    welcomeText: "Welcome to Pouch Cell Inspector!",
                    title: "Know Your Battery’s Condition Instantly",
                    subtitle: "Check if a lithium-ion pouch battery is safe in seconds.",
                    features: []
                )
                .tag(0)

                OnboardingPageView(
                    imageName: "OnboardingIcon",
                    title: "How It Works",
                    subtitle: "",
                    features: [
                        "Take a photo of the battery",
                        "We analyze its condition",
                        "Classification results are returned within seconds",
                        "Save images and view past results"
                    ]
                )
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle()) // improves swipe hit-testing

            Button {
                if currentPage < lastPageIndex {
                    withAnimation(.easeInOut) { currentPage += 1 }
                } else {
                    hasSeenOnboarding = true
                }
            } label: {
                Text(currentPage < lastPageIndex ? "Continue" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            // Polished "app icon" treatment for the header
            Image("OnboardingIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
                )
                .background(
                    // This helps the icon look good on both light/dark backgrounds
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
                .accessibilityLabel("Pouch Cell Inspector")

            Text("Pouch Cell Inspector")
                .font(.headline)

            Spacer()

            Button("Skip Onboarding") {
                hasSeenOnboarding = true
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
                    }
        .padding(.horizontal)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }
}


