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
import AVFoundation

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

    @StateObject private var embeddedCamera = EmbeddedCameraModel()

    @State private var showMenu = false
    @State private var showUIKitPicker = false

    @State private var capturedImage: UIImage?
    @State private var showLoading = false
    @State private var resultPayload: DetectionResultPayload?

    // ✅ FIX: Correct classifier type name
    @State private var cameraGranted = false

    private let classifier = DTImageClassifier()

    var body: some View {
        NavigationStack {
            ZStack {

                if cameraGranted {
                    EmbeddedCameraPreview(model: embeddedCamera)
                        .ignoresSafeArea()
                } else {
                    AppTheme.background
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                LinearGradient(
                    colors: [
                        Color.black.opacity(cameraGranted ? 0.55 : 0.0),
                        Color.black.opacity(cameraGranted ? 0.25 : 0.0),
                        Color.black.opacity(cameraGranted ? 0.55 : 0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                VStack(spacing: 18) {

                    VStack(spacing: 6) {
                        Text("PouchCell Inspector")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(cameraGranted ? .white : .primary)

                        Text("Capture a photo to assess pouch cell condition.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(cameraGranted ? .white.opacity(0.85) : .secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 22)

                    Spacer()

                    if !cameraGranted {
                        VStack(spacing: 12) {
                            Text("Camera access is required to scan a battery.")
                                .font(.system(size: 16, weight: .semibold))
                                .multilineTextAlignment(.center)

                            Button {
                                Task { await requestCameraPermissionAndStart(silentIfDenied: false) }
                            } label: {
                                Label("Enable Camera", systemImage: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppTheme.accent)
                                    .cornerRadius(16)
                            }
                            
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
                                    )
                            }
                            //.accessibilityHint("Choose an image of a lithium pouch cell battery from your library and get a result.")
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal, 24)

                    } else {

                        HStack(spacing: 28) {

                            // Flash / Torch
                            Button {
                                embeddedCamera.toggleFlash()
                            } label: {
                                Image(systemName: embeddedCamera.isTorchOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 54, height: 54)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel(embeddedCamera.isTorchOn ? "Flash on" : "Flash off")
                                                        .accessibilityHint("Double tap to toggle the camera flash.")

                            // Capture
                            Button {
                                embeddedCamera.capture()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 74, height: 74)

                                    Circle()
                                        .stroke(Color.black.opacity(0.25), lineWidth: 2)
                                        .frame(width: 74, height: 74)
                                }
                            }
                            .accessibilityLabel("Take picture")
                            .accessibilityHint("Double tap to take a picture of a lithium pouch cell battery.")
                            .popoverTip(SpeechFeedbackTip())

                            // Import
                            Button {
                                Task {
                                    let granted = await photoPermissionManager.requestPermissionAsync()
                                    if granted { showUIKitPicker = true }
                                }
                            } label: {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 54, height: 54)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Import from library")
                            .accessibilityHint("Choose an image of a lithium pouch cell battery from your library and get a result.")
                        }
                        .padding(.bottom, 8)

                        NavigationLink {
                            SafetyInfoView()
                        } label: {
                            Label("Safety Info", systemImage: "info.circle")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial)
                                .cornerRadius(14)
                        }
                        .padding(.bottom, 26)
                    }
                }
                .padding(.bottom, 10)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showMenu = true } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(cameraGranted ? .white : .primary)
                            .accessibilityLabel("Menu")
                    }
                }
            }
            .onAppear {
                embeddedCamera.onCapture = { image in
                    capturedImage = image
                    runClassification()
                }

                Task { await requestCameraPermissionAndStart(silentIfDenied: true) }
            }
            .onChange(of: cameraGranted) { _, granted in
                if granted {
                    embeddedCamera.startSessionIfNeeded()
                } else {
                    embeddedCamera.stopSessionIfNeeded()
                }
            }
            .onDisappear {
                embeddedCamera.stopSessionIfNeeded()
            }
        }
        .task { try? Tips.configure() }

        .sheet(isPresented: $showMenu) {
            MenuView()
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

        .sheet(item: $resultPayload) { payload in
            DetectionResultScreen(
                result: payload.result,
                scannedImage: payload.image,
                onScanAgain: { }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Permissions

    private func requestCameraPermissionAndStart(silentIfDenied: Bool) async {
        let granted = await cameraManager.requestPermissionAsync()
        await MainActor.run {
            self.cameraGranted = granted
        }

        if granted {
            embeddedCamera.startSessionIfNeeded()
        }
    }

    // MARK: - Classification

    private func runClassification() {
        guard let image = capturedImage else { return }
        showLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let result = try? classifier.classify(image)

            DispatchQueue.main.async {
                showLoading = false

                let resultString: String
                if let result = result {
                    let label = result.classLabel
                    let confidence = result.topK.first?.prob ?? 0.0
                    resultString = "\(label) - \(String(format: "%.2f", confidence * 100))"
                } else {
                    resultString = "Unable to analyze image"
                }

                self.resultPayload = DetectionResultPayload(result: resultString, image: image)
            }
        }
    }
}

