//
//  ContentView.swift
//  MIERUTE
//
//  Created by 本田輝 on 2025/10/18.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var showOnboarding = !OnboardingService.hasCompletedOnboarding()

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(onComplete: {
                    OnboardingService.completeOnboarding()
                    withAnimation {
                        showOnboarding = false
                    }
                })
            } else {
                CameraView(viewModel: cameraViewModel)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
