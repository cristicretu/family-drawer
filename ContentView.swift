//
//  ContentView.swift
//  family-drawer
//
//  Created by John Doe on 03.03.2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showModal = false
    var body: some View {
        ZStack {
            Button("Show Modal") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    showModal = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(999)
            .font(.system(size: 20, weight: .semibold, design: .rounded))

            // Custom modal view
            if showModal {
                ModalBackdrop(isPresented: $showModal)
                    .transition(.opacity)

                ModalContent(isPresented: $showModal)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

// Separate backdrop component
struct ModalBackdrop: View {
    @Binding var isPresented: Bool

    var body: some View {
        Color.black.opacity(0.3)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isPresented = false
                }
            }
    }
}

// Modal content component
struct ModalContent: View {
    @Binding var isPresented: Bool
    @State private var showPrivateKey = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if showPrivateKey {
                    Image(systemName: "creditcard")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .transition(.opacity)
                } else {
                    Text("Options")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .transition(.opacity)
                }

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        if showPrivateKey {
                            showPrivateKey = false
                        } else {
                            isPresented = false
                        }
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
            .padding(.horizontal, 24)
            .zIndex(1)  // Keep header on top

            // Content area that changes
            Group {
                if showPrivateKey {
                    PrivateKeyContent(onBack: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showPrivateKey = false
                        }
                    })
                    .transition(
                        .asymmetric(
                            insertion: AnyTransition.opacity.combined(
                                with: .scale(scale: 1.05, anchor: .center)),
                            removal: AnyTransition.opacity.combined(
                                with: .scale(scale: 0.95, anchor: .center))
                        ))
                } else {
                    OptionsContent(onPrivateKeyTap: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showPrivateKey = true
                        }
                    })
                    .transition(
                        .asymmetric(
                            insertion: AnyTransition.opacity.combined(
                                with: .scale(scale: 1.05, anchor: .center)),
                            removal: AnyTransition.opacity.combined(
                                with: .scale(scale: 0.95, anchor: .center))
                        ))
                }
            }
            .fixedSize(horizontal: false, vertical: true)  // Only take needed height
        }
        .background(Color.white)
        .cornerRadius(32)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        // This animation applies to the container's size changes
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showPrivateKey)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

// Options content only (without header)
struct OptionsContent: View {
    var onPrivateKeyTap: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                onPrivateKeyTap()
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
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

// Private Key content only (without header)
struct PrivateKeyContent: View {
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
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
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                Button(action: {
                    onBack()
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
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ContentView()
}
