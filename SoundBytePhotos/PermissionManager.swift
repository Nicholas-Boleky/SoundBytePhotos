//
//  PermissionManager.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/25/25.
//

import Photos
import Speech
import UIKit

@MainActor
final class PermissionManager: NSObject, ObservableObject {
    
    var allCorePermissionsGranted: Bool { isPhotosGranted && isMicGranted && isSpeechGranted}
    
    var isPhotosGranted: Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
        default:
            return false
        }
    }
    
    var isMicGranted: Bool {
        AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    var isSpeechGranted: Bool {
        SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    @Published var photosStatusLabel = "Not requested"
    @Published var microphoneStatusLabel = "Not requested"
    @Published var speechStatusLabel = "Not requested"
    
    func requestPhotosRead() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            updatePhotosLabel(newStatus)
        case .denied, .restricted:
            openSettings(); updatePhotosLabel(status)
        default:
            updatePhotosLabel(status)
        }
    }
    
    func requestMicrophone() async {
        let audio = AVAudioSession.sharedInstance()
        switch audio.recordPermission {
        case .undetermined:
            let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
                audio.requestRecordPermission { cont.resume(returning: $0) }
            }
        case .denied:
            openSettings()
        case .granted:
            break
        @unknown default: break
        }
        refreshMicrophoneLabel()
    }
    
    func requestSpeech() async {
        let current = SFSpeechRecognizer.authorizationStatus()
        switch current {
        case .notDetermined:
            let newStatus = await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
                SFSpeechRecognizer.requestAuthorization { cont.resume(returning: $0) }
            }
            updateSpeechLabel(newStatus)
        case .denied, .restricted:
            openSettings(); updateSpeechLabel(current)
        default:
            updateSpeechLabel(current)
        }
    }
    
    func refreshAll() {
        refreshPhotosLabel()
        refreshMicrophoneLabel()
        refreshSpeechLabel()
    }
    
    private func refreshPhotosLabel() {
        updatePhotosLabel(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }
    
    private func refreshMicrophoneLabel() {
        microphoneStatusLabel = switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            "Not requested"
        case .denied:
            "Denied: Open Settings"
        case .granted:
            "Enabled"
        @unknown default: "Unknown"
        }
    }
    
    private func refreshSpeechLabel() {
        updateSpeechLabel(SFSpeechRecognizer.authorizationStatus())
    }
    
    private func updatePhotosLabel(_ status: PHAuthorizationStatus) {
        photosStatusLabel = switch status {
        case .authorized: "Enabled"
        case .limited: "Limited - can manage selection"
        case .denied, .restricted: "Denied - Open Settings"
        case .notDetermined: "Not requested"
        @unknown default: "Unknown"
        }
    }
    
    private func updateSpeechLabel(_ status: SFSpeechRecognizerAuthorizationStatus) {
        speechStatusLabel = switch status {
        case .authorized: "Enabled"
        case .denied, .restricted: "Denied - Open Settings"
        case .notDetermined: "Not requested"
        @unknown default: "Unknown"
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
