//
//  HomeScreen.swift
//  PouchCellInspector
//
//  Created by Firas Abueida on 11/26/25.
//

import SwiftUI
import Photos
import UIKit
import TipKit

struct HomeScreen: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("didAnnounceSpeechTip") private var didAnnounceSpeechTip = false

    @StateObject private var cameraManager = CameraPermissionManager()
    @StateObject private var photoPermissionManager = PhotoPermissionManager()

    @State private var showMenu = false
    @State private var showSafetyInfo = false
    @State private var showCamera = false
    @State private var showUIKitPicker = false
    @State private var capturedImage: UIImage?
    @State private var prediction: String?
    @State private var showLoading = false
    @State private var showResult = false

    private let classifier = ImageClassifier()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 36) {

                    Text("PouchCell Inspector")
                        .font(.system(size: 32, weight: .bold))

                    Spacer()

                                        Button {
                        Task {
                            let granted = await cameraManager.requestPermissionAsync()
                            if granted { showCamera = true }
                        }
                    } label: {
                        Label("Scan", systemImage: "camera.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.accent)
                            .cornerRadius(18)
                            .accessibilityHint("Double tap to open the camera and take a picture of a lithium pouch cell battery.")
                    }
                    .padding(.horizontal, 32)
                    .popoverTip(SpeechFeedbackTip())

                                        Button {
                        Task {
                            let granted = await photoPermissionManager.requestPermissionAsync()
                            if granted { showUIKitPicker = true }
                        }
                    } label: {
                        Label("Import from Library", systemImage: "photo.on.rectangle")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.accent, lineWidth: 2)
                                    .accessibilityHint("Choose an image of a lithium pouch cell battery that you've saved and get a result.")
                            )
                    }
                    .padding(.horizontal, 64)

                                        Button {
                        showSafetyInfo = true
                    } label: {
                        Label("Safety Info", systemImage: "info.circle")
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showMenu = true } label: {
                        Image(systemName: "line.3.horizontal")
                            .accessibilityLabel("Menu")
                    }
                }
            }
        }
        .task { try? Tips.configure() }

        .sheet(isPresented: $showMenu) {
            MenuView()
        }

        // ✅ Safety Info sheet now has a close button
        .sheet(isPresented: $showSafetyInfo) {
            NavigationStack {
                InfoDetailView(
                    title: "Safety Information",
                    message: "This app provides a visual inspection only and does not replace professional battery testing."
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSafetyInfo = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("Close")
                    }
                }
            }
        }

        .sheet(isPresented: $showCamera) {
            CameraView { image in
                capturedImage = image
                runClassification()
            }
        }

        .sheet(isPresented: $showUIKitPicker) {
            ImagePicker { image in
                capturedImage = image
                runClassification()
            }
        }

        .fullScreenCover(isPresented: $showLoading) {
            AnalysisLoadingScreen()
        }

        // Result is presented as a dismissible sheet so users can close and return to main page.
        .sheet(isPresented: $showResult) {
            DetectionResultScreen(
                result: prediction ?? "Unknown",
                onScanAgain: {
                    Task {
                        let granted = await cameraManager.requestPermissionAsync()
                        if granted { showCamera = true }
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private func runClassification() {
        guard let image = capturedImage else { return }
        showLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let result = classifier.classify(image)
            DispatchQueue.main.async {
                showLoading = false
                prediction = result ?? "Unable to analyze image"
                showResult = true
            }
        }
    }
}

