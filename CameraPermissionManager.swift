import AVFoundation
import Combine

final class CameraPermissionManager: ObservableObject {
    @Published var permissionGranted = false

    func requestPermissionAsync() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}

