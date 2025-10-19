//
//  MIERUTEApp.swift
//  MIERUTE
//
//  Created by 本田輝 on 2025/10/18.
//

import SwiftUI
import FirebaseCore

@main
struct MIERUTEApp: App {
    init() {
        // Configure Firebase only if GoogleService-Info.plist exists
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("✅ Found GoogleService-Info.plist at: \(path)")
            FirebaseApp.configure()
        } else {
            print("⚠️ GoogleService-Info.plist not found. Firebase features will use mock data.")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
