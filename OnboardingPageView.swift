//
//  OnboardingPageView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/28/26.
//

import SwiftUI

struct OnboardingPageView: View {
    
    var imageName: String
    var welcomeText: String? = nil   // 👈 NEW
    var title: String
    var subtitle: String
    var features: [String]
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
            
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
                        Text(feature)
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
    }
}

