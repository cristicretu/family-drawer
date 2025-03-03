//
//  ContentView.swift
//  family-drawer
//
//  Created by John Doe on 03.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    var body: some View {
        ZStack {
            Button("Show Modal") {
                showModal = true
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(999)
            .font(.system(size: 20, weight: .semibold, design: .rounded))

            // Custom modal view
            if showModal {
                ModalView(isPresented: $showModal)
            }
        }
    }
}

struct ModalView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Modal content
            VStack(spacing: 24) {
                HStack {
                    Text("Options")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .padding(8)
                            .background(Color.black.opacity(0.03))
                            .foregroundColor(.gray)
                            .cornerRadius(24)
                    }
                }
                .padding(.top, 32)

                VStack(spacing: 12) {
                    Button(action: {
                        // View Private Key action
                    }) {
                        HStack {
                            Image(systemName: "lock")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Text("View Private Key")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.03))
                        .cornerRadius(16, antialiased: true)
                    }
                    .foregroundColor(.primary)

                    Button(action: {
                        // View Recovery Phrase action
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Text("View Recovery Phrase")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.03))
                        .cornerRadius(16, antialiased: true)
                    }
                    .foregroundColor(.primary)

                    Button(action: {
                        // Remove Wallet action
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Text("Remove Wallet")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16, antialiased: true)
                    }
                    .foregroundColor(.red)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(32)
        }
    }
}

#Preview {
    ContentView()
}
