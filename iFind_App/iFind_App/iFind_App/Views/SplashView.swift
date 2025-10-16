//
//  SplashView.swift
//  iFind_App
//
//  Created by Josiah Green on 10/15/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                DashboardView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                Image("splashView_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: isActive)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                isActive = true
            }
        }
    }
}

#Preview("Landscape", traits: .landscapeLeft) {
    SplashView()
}
