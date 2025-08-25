//
//  OnboardingView.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool//Binding so it can edit property on parent view
    @StateObject private var permissionManager = PermissionManager()
    @State private var showPermissionsSheet = false
    
    var onboardingMessage: String = "In order to work as intended, SoundByte Pictures needs to read your photo library, record your voice, and transcribe voice notes. When you click the button below, you will be asked to grant those permissions. If you change your mind later you can adjust these permissions in Settings"
    
    var body: some View {
            
         
                VStack {
                    Spacer()
                    Text(onboardingMessage)
                        .font(.title2)
                        .padding()
                    Spacer()
                    Button("Continue") {
                        showPermissionsSheet = true
                    }
                }
                .sheet(isPresented: $showPermissionsSheet) {
                    PermissionsList(permissionManager: permissionManager, hasSeenOnboarding: $hasSeenOnboarding, showPermissionsSheet: $showPermissionsSheet)
                }
           
            
        
    }
}

struct PermissionsList: View {
    @ObservedObject var permissionManager: PermissionManager
    @Binding var hasSeenOnboarding: Bool
    @Binding var showPermissionsSheet: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enable features")
                .font(.title2).bold()
            
            PermissionCard(title: "Photos", subtitle: "Attach images from your library", status: permissionManager.photosStatusLabel) {
                Task {
                    await permissionManager.requestPhotosRead()
                }
            }
            
            PermissionCard(title: "Microphone", subtitle: "Record voice notes", status: permissionManager.microphoneStatusLabel) {
                Task {
                    await permissionManager.requestMicrophone()
                }
            }
            
            PermissionCard(title: "Speech Recognition", subtitle: "Transcribe your recordings", status: permissionManager.speechStatusLabel) {
                Task {
                    await permissionManager.requestSpeech()
                }
            }
            
            Button(permissionManager.allCorePermissionsGranted ? "Finish" : "Skip for now") {
                hasSeenOnboarding = true
                showPermissionsSheet = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            .disabled(false)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
        .disabled(false)
    }
}

struct PermissionCard: View {
    let title: String
    let subtitle: String
    let status: String
    let action: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).foregroundStyle(.secondary)
            HStack {
                Text(status).font(.subheadline)
                Spacer()
                Button("Enable", action: action)
            }
        }
        .padding().background(.thinMaterial).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
