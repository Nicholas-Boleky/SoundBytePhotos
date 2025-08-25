//
//  SoundBytePhotosApp.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/25/25.
//

import SwiftUI

@main
struct SoundBytePhotosApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                PictureGridView()
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}
