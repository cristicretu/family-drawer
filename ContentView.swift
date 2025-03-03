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
    @State private var showPrivateKey = false
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    if showPrivateKey {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showPrivateKey = false
                        }
                    } else {
                        isPresented = false
                    }
                }

            // Modal content
            VStack(spacing: 0) {
                if !showPrivateKey {
                    // Options View
                    VStack(spacing: 16) {
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
                        .padding(.top, 24)

                        VStack(spacing: 10) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showPrivateKey = true
                                }
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
                        .padding(.bottom, 24)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: AnyTransition.opacity.combined(with: .move(edge: .leading))
                        ))
                } else {
                    // Private Key View
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "creditcard")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showPrivateKey = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(8)
                                    .background(Color.black.opacity(0.03))
                                    .foregroundColor(.gray)
                                    .cornerRadius(24)
                            }
                        }
                        .padding(.top, 24)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Private Key")
                                .font(.system(size: 22, weight: .bold, design: .rounded))

                            Text(
                                "Your Private Key is the key used to back up your wallet. Keep it secret and secure at all times."
                            )
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)

                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.shield")
                                        .foregroundColor(.secondary)
                                    Text("Keep your private key safe")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                }

                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle.badge.xmark")
                                        .foregroundColor(.secondary)
                                    Text("Don't share it with anyone else")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                }

                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.secondary)
                                    Text("If you lose it we can't recover it")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer(minLength: 16)

                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showPrivateKey = false
                                }
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.black.opacity(0.05))
                                    .foregroundColor(.primary)
                                    .cornerRadius(16)
                            }

                            Button(action: {
                                // Reveal action
                            }) {
                                HStack {
                                    Image(systemName: "eye")
                                    Text("Reveal")
                                }
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .transition(
                        .asymmetric(
                            insertion: AnyTransition.opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(32)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showPrivateKey)
        }
    }
}

#Preview {
    ContentView()
}
