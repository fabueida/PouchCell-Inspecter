//
//  OnboardingView.swift.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 12/7/25.
//

import SwiftUI

struct OnboardingView: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 24) {

            Text("Welcome to Pouch Cell Inspector!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Use the camera to identify the status of your lithium ion battery.")
                .multilineTextAlignment(.center)

            Text("Simply take a picture of a lithium ion pouch battery and it will give you information to determine if your battery is in one of the following conditions, normal, bulging, unknown, etc. You can also save pictures of a lithium ion pouch battery, and then browse thru your photo library and also get a result in a similar fashion. Tap continue to get started.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                hasSeenOnboarding = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .padding()
    }
}

