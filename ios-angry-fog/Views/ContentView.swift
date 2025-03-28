//
//  ContentView.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.3.2025.
//

import SwiftUI
struct ContentView: View {
    @ObservedObject var viewModel: FrogViewModel

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text("Angry Frog")
                    .font(.largeTitle)
                    .bold()

                Image(viewModel.isScreaming ? "frog_screaming" : "frog_calm")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .onTapGesture {
                        viewModel.triggerScream()
                    }

                Button("Request Permissions") {
                    viewModel.showFakePermissions()
                }
            }
        }
    }
}
