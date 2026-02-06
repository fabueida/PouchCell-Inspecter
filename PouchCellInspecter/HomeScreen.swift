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

// ✅ NEW: bundle result + scanned image together so result screen always has the correct image
private struct DetectionResultPayload: Identifiable {
    let id = UUID()
    let result: String
    let image: UIImage
}

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
    @State private var showLoading = false

    // ✅ NEW: present results via an item that contains BOTH image + result
    @State private var resultPayload: DetectionResultPayload?

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

        // ✅ NEW: result screen is driven by payload (image + result)
        .sheet(item: $resultPayload) { payload in
            DetectionResultScreen(
                result: payload.result,
                scannedImage: payload.image,
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
            let result = classifier.classify(image) ?? "Unable to analyze image"

            DispatchQueue.main.async {
                showLoading = false

                // ✅ NEW: set payload (guarantees result screen has the correct image)
                self.resultPayload = DetectionResultPayload(result: result, image: image)
            }
        }
    }
}

