//
//  ContentView.swift
//  MIERUTE
//
//  Created by 本田輝 on 2025/10/18.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        CameraView(viewModel: cameraViewModel)
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
