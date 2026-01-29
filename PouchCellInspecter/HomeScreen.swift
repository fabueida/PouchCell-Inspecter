//
//  Homescreen.swift
//  PouchCellInspecter
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
        Group {
            if #available(iOS 17.0, *), hasSeenOnboarding {
                mainContent
                    .popoverTip(SpeechFeedbackTip())
                    .onAppear { announceSpeechTipOnceIfNeeded() }
            } else {
                mainContent
            }
        }
        .sheet(isPresented: $showMenu) { MenuView() }
        .sheet(isPresented: $showSafetyInfo) {
            InfoDetailView(
                title: "Safety Information",
                message: "This app provides a visual inspection only and does not replace professional battery testing."
            )
        }
    }

    // MARK: - UI
    private var mainContent: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 36) {

                    Text("PouchCell Inspector")
                        .font(.system(size: 32, weight: .bold))

                    Spacer()

                    Button {
                        cameraManager.requestPermission()
                    } label: {
                        Label("Scan", systemImage: "camera.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.accent)
                            .cornerRadius(18)
                    }
                    .padding(.horizontal, 32)

                    Button {
                        photoPermissionManager.requestPermission()
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showMenu = true } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                    .accessibilityLabel("Menu")
                }
            }
        }
        .onChange(of: cameraManager.permissionGranted) { _, granted in
            if granted { showCamera = true }
        }
        .onChange(of: photoPermissionManager.permissionGranted) { _, granted in
            if granted { showUIKitPicker = true }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                capturedImage = image
                showCamera = false
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
        .fullScreenCover(isPresented: $showResult) {
            DetectionResultScreen(result: prediction ?? "Unknown")
        }
    }

    // MARK: - VoiceOver (sync with tip; only once ever)
    private func announceSpeechTipOnceIfNeeded() {
        guard UIAccessibility.isVoiceOverRunning else { return }
        guard !didAnnounceSpeechTip else { return }

        UIAccessibility.post(
            notification: .announcement,
            argument: "Tip: You can enable speech feedback in Settings for spoken battery results."
        )
        didAnnounceSpeechTip = true
    }

    // MARK: - Classification
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
