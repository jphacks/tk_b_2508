//
//  QRScannerOverlay.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct QRScannerOverlay: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .stroke(lineWidth: 10)
            .frame(width: 300, height: 300)
            .mask {
                RoundedRectangle(cornerRadius: 30)
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .frame(width: 200, height: 400)
                            .blendMode(.destinationOut)
                        RoundedRectangle(cornerRadius: 30)
                            .frame(width: 400, height: 200)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 200)
    }
}

#Preview {
    QRScannerOverlay()
}
