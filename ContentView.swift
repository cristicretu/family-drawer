//
//  ContentView.swift
//  family-drawer
//
//  Created by John Doe on 03.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    @State private var useDirectionalAnimation = false
    @State private var animationDuration: Double = 0.25

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
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

                // Animation style toggle
                Toggle(isOn: $useDirectionalAnimation) {
                    Text("Use Directional Animation")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 20)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

                // Animation duration slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Animation Speed: \(String(format: "%.2f", animationDuration))s")
                        .font(.system(size: 14, weight: .medium))

                    HStack {
                        Text("Fast")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Slider(value: $animationDuration, in: 0.1...3.0, step: 0.05)
                            .accentColor(.blue)

                        Text("Slow")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }

            if showModal {
                ModalBackdrop(isPresented: $showModal)
                    .transition(.opacity)

                ModalContent(
                    isPresented: $showModal,
                    useDirectionalAnimation: useDirectionalAnimation,
                    animationDuration: animationDuration
                )
                .transition(.move(edge: .bottom))
            }
        }
    }
}

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

struct ModalContent: View {
    @Binding var isPresented: Bool
    @State private var showPrivateKey = false
    var useDirectionalAnimation: Bool
    var animationDuration: Double

    // Computed animations based on the slider value
    private var contentTransition: Animation {
        .spring(response: animationDuration, dampingFraction: 0.7)
    }

    private var heightTransition: Animation {
        .spring(response: animationDuration * 1.2, dampingFraction: 0.8)
    }

    private var smoothFadeInScale: AnyTransition {
        let opacity = AnyTransition.opacity
        let scale = AnyTransition.scale(scale: 1.05)

        return AnyTransition.modifier(
            active: SmoothTransitionModifier(opacity: 0, scale: 1.05),
            identity: SmoothTransitionModifier(opacity: 1, scale: 1)
        )
    }

    private var smoothFadeOutScale: AnyTransition {
        return AnyTransition.modifier(
            active: SmoothTransitionModifier(opacity: 0, scale: 0.95),
            identity: SmoothTransitionModifier(opacity: 1, scale: 1)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if showPrivateKey {
                    Image(systemName: "creditcard")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .transition(
                            useDirectionalAnimation
                                ? .opacity.combined(with: .move(edge: .trailing))
                                : .opacity)
                } else {
                    Text("Options")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .transition(
                            useDirectionalAnimation
                                ? .opacity.combined(with: .move(edge: .leading))
                                : .opacity)
                }

                Spacer()

                Button(action: {
                    withAnimation(contentTransition) {
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
            .zIndex(1)

            // Content area that changes
            ZStack {
                if showPrivateKey {
                    PrivateKeyContent(onBack: {
                        withAnimation(contentTransition) {
                            showPrivateKey = false
                        }
                    })
                    .transition(
                        useDirectionalAnimation
                            ? .asymmetric(
                                insertion: AnyTransition.move(edge: .trailing)
                                    .combined(with: .opacity),
                                removal: AnyTransition.move(edge: .trailing)
                                    .combined(with: .opacity)
                            )
                            : .asymmetric(
                                insertion: smoothFadeInScale,
                                removal: smoothFadeOutScale
                            )
                    )
                    .id("privateKey")
                } else {
                    OptionsContent(onPrivateKeyTap: {
                        withAnimation(contentTransition) {
                            showPrivateKey = true
                        }
                    })
                    .transition(
                        useDirectionalAnimation
                            ? .asymmetric(
                                insertion: AnyTransition.move(edge: .leading)
                                    .combined(with: .opacity),
                                removal: AnyTransition.move(edge: .leading)
                                    .combined(with: .opacity)
                            )
                            : .asymmetric(
                                insertion: smoothFadeInScale,
                                removal: smoothFadeOutScale
                            )
                    )
                    .id("options")
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(Color.white)
        .cornerRadius(32)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .animation(heightTransition, value: showPrivateKey)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

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

struct PrivateKeyContent: View {
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Private Key")
                    .font(.system(size: 22, weight: .bold, design: .rounded))

                Text(
                    "Your Private Key is the key used to back up your wallet. Keep it secret and secure at all times."
                )
                .font(.system(size: 18, weight: .regular, design: .rounded))
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

// Custom modifier for smooth simultaneous animations
struct SmoothTransitionModifier: ViewModifier {
    let opacity: Double
    let scale: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
    }
}

#Preview {
    ContentView()
}
