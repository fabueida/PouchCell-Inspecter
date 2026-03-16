import AVFoundation
import Combine
import UIKit

final class CameraPermissionManager: ObservableObject {
    @Published var permissionGranted = false

    init() {
        refreshStatus()
    }

    /// Returns the current system camera authorization status.
    func currentStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// Updates `permissionGranted` based on current Settings.
    func refreshStatus() {
        let status = currentStatus()
        DispatchQueue.main.async {
            self.permissionGranted = (status == .authorized)
        }
    }

    /// Requests permission only when status is `.notDetermined`.
    /// If `.denied` / `.restricted`, this returns false (because iOS won't re-prompt).
    func requestPermissionAsync() async -> Bool {
        let status = currentStatus()

        if status == .authorized {
            DispatchQueue.main.async { self.permissionGranted = true }
            return true
        }

        if status == .denied || status == .restricted {
            DispatchQueue.main.async { self.permissionGranted = false }
            return false
        }

        // .notDetermined -> request
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


