//
//  OnboardingService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation

enum OnboardingService {
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private static let hasDetectedGoodSignKey = "hasDetectedGoodSign"

    static func hasCompletedOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }

    static func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
    }

    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
    }

    static func hasDetectedGoodSign() -> Bool {
        UserDefaults.standard.bool(forKey: hasDetectedGoodSignKey)
    }

    static func completeGoodSignDetection() {
        UserDefaults.standard.set(true, forKey: hasDetectedGoodSignKey)
    }
}
