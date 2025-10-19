//
//  AppState.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation

enum AppState {
    case scanning
    case loading
    case capture
    case displayingInstructions(currentIndex: Int)
    case completed
}

extension AppState {
    var isScanning: Bool {
        if case .scanning = self {
            return true
        }
        return false
    }

    var isDisplayingInstructions: Bool {
        if case .displayingInstructions = self {
            return true
        }
        return false
    }

    var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}
