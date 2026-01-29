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
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    imageName: "onboardingIcon",
                    welcomeText: "Welcome to Pouch Cell Inspector!",
                    title: "Know Your Battery’s Condition Instantly",
                    subtitle: "Check if a lithium-ion pouch battery is safe in seconds.",
                    features: []
                )

                                .tag(0)
                
                OnboardingPageView(
                    imageName: "onboardingIcon",
                    title: "How It Works",
                    subtitle: "",
                    features: [
                        "Take a photo of the battery",
                        "We analyze its condition",
                        "Save images and view past results"
                    ]
                )
                .tag(1)
            }
            .tabViewStyle(.page)
            
            Button {
                if currentPage < 1 {
                    currentPage += 1
                } else {
                    hasSeenOnboarding = true
                }
            } label: {
                Text(currentPage < 1 ? "Continue" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
