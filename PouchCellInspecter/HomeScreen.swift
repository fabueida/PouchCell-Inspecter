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
    @AppStorage("pref_saveToPhotos") private var saveToPhotos: Bool = false

    @StateObject private var cameraManager = CameraPermissionManager()
    @StateObject private var photoPermissionManager = PhotoPermissionManager()
    @StateObject private var embeddedCamera = EmbeddedCameraModel()

    @State private var showMenu = false
    @State private var showUIKitPicker = false
    @State private var capturedImage: UIImage?
    @State private var showLoading = false
    @State private var resultPayload: DetectionResultPayload?
    @State private var cameraGranted = false
    @State private var showSaveToPhotosAlert = false

    private let classifier = DTImageClassifier()

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var historyStore: ScanHistoryStore

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
                            Text("Camera disabled.")
                            Text("Camera access is required to scan a battery.")
                                .font(.system(size: 16, weight: .semibold))
                                .multilineTextAlignment(.center)

                            Button {
                                Task { await requestCameraPermissionAndStart(silentIfDenied: false) }
                            } label: {
                                Label("Open Settings", systemImage: "camera.fill")
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
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal, 24)

                    } else {

                        HStack(spacing: 28) {

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

                        HStack(spacing: 10) {
                            NavigationLink {
                                HistoryView()
                            } label: {
                                Label("View Classification History", systemImage: "clock.arrow.circlepath")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(14)
                            }

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

                    if saveToPhotos {
                        Task { await saveScanToPhotosIfAllowed(image) }
                    }

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
            .onChange(of: scenePhase) {
                guard scenePhase == .active else { return }

                cameraManager.refreshStatus()
                photoPermissionManager.refreshStatus()

                if cameraManager.permissionGranted && !cameraGranted {
                    cameraGranted = true
                    embeddedCamera.startSessionIfNeeded()
                }

                if !cameraManager.permissionGranted && cameraGranted {
                    cameraGranted = false
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
                scannedImage: payload.image
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Photo Access Required", isPresented: $photoPermissionManager.showPermissionAlert) {
            Button("Open Settings") { photoPermissionManager.openSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable photo access in Settings to import an image.")
        }
        .alert("Can’t Save to Photos", isPresented: $showSaveToPhotosAlert) {
            Button("Open Settings") { openAppSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To save scans to your Photos library, allow Photos access in Settings.")
        }
    }

    private func requestCameraPermissionAndStart(silentIfDenied: Bool) async {
        let status = cameraManager.currentStatus()

        if status == .denied || status == .restricted {
            await MainActor.run { self.cameraGranted = false }
            if !silentIfDenied {
                await MainActor.run { cameraManager.openSettings() }
            }
            return
        }

        let granted = await cameraManager.requestPermissionAsync()
        await MainActor.run { self.cameraGranted = granted }

        if granted {
            embeddedCamera.startSessionIfNeeded()
        }
    }

    private func saveScanToPhotosIfAllowed(_ image: UIImage) async {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        if status == .authorized {
            await createPhotoAsset(image)
            return
        }

        if status == .denied || status == .restricted {
            await MainActor.run { showSaveToPhotosAlert = true }
            return
        }

        let granted = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                continuation.resume(returning: newStatus == .authorized)
            }
        }

        if granted {
            await createPhotoAsset(image)
        } else {
            await MainActor.run { showSaveToPhotosAlert = true }
        }
    }

    private func createPhotoAsset(_ image: UIImage) async {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { _, _ in
                continuation.resume()
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

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

                historyStore.add(resultText: resultString, image: image)
                self.resultPayload = DetectionResultPayload(result: resultString, image: image)
            }
        }
    }
}
