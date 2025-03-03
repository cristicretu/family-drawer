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

                Toggle(isOn: $useDirectionalAnimation) {
                    Text("Use Directional Animation")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 20)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

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

                ModalView(
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

struct ModalView: View {
    @Binding var isPresented: Bool
    var useDirectionalAnimation: Bool
    var animationDuration: Double

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private let dismissThreshold: CGFloat = 120

    var body: some View {
        ModalContent(
            isPresented: $isPresented,
            useDirectionalAnimation: useDirectionalAnimation,
            animationDuration: animationDuration
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = max(0, value.translation.height)
                    dragOffset = newOffset
                    isDragging = true
                }
                .onEnded { value in
                    isDragging = false

                    if dragOffset > dismissThreshold {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isPresented = false
                            dragOffset = 0
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .opacity(1.0 - (dragOffset / (dismissThreshold * 2.5)))
    }
}

struct ModalContent: View {
    @Binding var isPresented: Bool
    @State private var showPrivateKey = false
    var useDirectionalAnimation: Bool
    var animationDuration: Double

    private var contentTransition: Animation {
        .spring(response: animationDuration, dampingFraction: 0.7)
    }

    private var heightTransition: Animation {
        .spring(response: animationDuration * 1.2, dampingFraction: 0.8)
    }

    private var smoothFadeInScale: AnyTransition {
        return AnyTransition.modifier(
            active: SmoothTransitionModifier(opacity: 0, scale: 1.05, yOffset: -100),
            identity: SmoothTransitionModifier(opacity: 1, scale: 1, yOffset: 0)
        )
    }

    private var smoothFadeOutScale: AnyTransition {
        return AnyTransition.modifier(
            active: SmoothTransitionModifier(opacity: 0, scale: 0.95, yOffset: 100),
            identity: SmoothTransitionModifier(opacity: 1, scale: 1, yOffset: 0)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if showPrivateKey {
                    Image(systemName: "creditcard")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .transition(
                            useDirectionalAnimation
                                ? .opacity.combined(with: .move(edge: .trailing))
                                : .opacity.combined(with: .scale)
                        )
                        .padding(.leading, 8)
                } else {
                    Text("iCloud Backup")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .transition(
                            useDirectionalAnimation
                                ? .opacity.combined(with: .move(edge: .leading))
                                : smoothFadeInScale)
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
            .zIndex(1)

            ZStack {
                if showPrivateKey {
                    PrivateKeyContent(
                        onBack: {
                            withAnimation(contentTransition) {
                                showPrivateKey = false
                            }
                        },
                        animationDuration: animationDuration
                    )
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
                    OptionsContent(
                        onPrivateKeyTap: {
                            withAnimation(contentTransition) {
                                showPrivateKey = true
                            }
                        },
                        animationDuration: animationDuration
                    )
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
    var animationDuration: Double

    var body: some View {
        VStack(spacing: 10) {
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(.primary.opacity(0.05))
                .cornerRadius(20)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)

            Button(action: {
                onPrivateKeyTap()
            }) {
                HStack {
                    Image(systemName: "widget.large")
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
                    Image(systemName: "rectangle.grid.3x3")
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
                onPrivateKeyTap()
            }) {
                HStack {
                    Image(systemName: "circle.grid.2x2.fill")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                    Text("View Backup Group")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.03))
                .cornerRadius(16, antialiased: true)
            }
            .foregroundColor(.primary)

            AnimatedActionButton(isPrivateKeyView: false, animationDuration: animationDuration)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

struct PrivateKeyContent: View {
    var onBack: () -> Void
    var animationDuration: Double

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Private Key")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))

                Text(
                    "Your Private Key is the key used to back up your wallet. Keep it secret and secure at all times."
                )
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)

                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(.primary.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 13)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield")
                            .foregroundColor(.secondary)
                        Text("Keep your private key safe")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .foregroundColor(.secondary)
                        Text("Don't share it with anyone else")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.secondary)
                        Text("If you lose it we can't recover it")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 16)

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                Button(action: {
                    onBack()
                }) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.05))
                        .foregroundColor(.primary)
                        .cornerRadius(999)
                }

                Button(action: {
                    onBack()
                }) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Reveal")
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                }

                //                AnimatedActionButton(isPrivateKeyView: true, animationDuration: animationDuration)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

// Shared animated button component
struct AnimatedActionButton: View {
    var isPrivateKeyView: Bool
    var animationDuration: Double

    // Custom animation for the button transition
    private var buttonTransition: Animation {
        .spring(response: animationDuration, dampingFraction: 0.7)
    }

    // Custom smooth transitions for button
    private var smoothButtonTransition: AnyTransition {
        .modifier(
            active: SmoothButtonTransitionModifier(
                progress: 0,
                isPrivateKeyView: isPrivateKeyView
            ),
            identity: SmoothButtonTransitionModifier(
                progress: 1,
                isPrivateKeyView: isPrivateKeyView
            )
        )
    }

    var body: some View {
        Button(action: {
            // Action remains the same
        }) {
            Group {
                if isPrivateKeyView {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Reveal")
                        Spacer()
                    }
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(999)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Remove Wallet")
                        Spacer()
                    }
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(30)
                }
            }
            .transition(smoothButtonTransition)
        }
    }
}

// Custom modifier for smooth button transitions
struct SmoothButtonTransitionModifier: ViewModifier {
    let progress: Double
    let isPrivateKeyView: Bool

    // Interpolate between colors
    private func interpolateColor(from: Color, to: Color) -> Color {
        // This is a simplified version - in a real app you'd want to properly interpolate RGB values
        return progress == 0 ? from : to
    }

    func body(content: Content) -> some View {
        let fromBgColor = isPrivateKeyView ? Color.red.opacity(0.1) : Color.blue
        let toBgColor = isPrivateKeyView ? Color.blue : Color.red.opacity(0.1)
        let fromFgColor = isPrivateKeyView ? Color.red : Color.white
        let toFgColor = isPrivateKeyView ? Color.white : Color.red

        let iconName =
            isPrivateKeyView
            ? (progress < 0.5 ? "exclamationmark.triangle" : "eye")
            : (progress < 0.5 ? "eye" : "exclamationmark.triangle")

        let text =
            isPrivateKeyView
            ? (progress < 0.5 ? "Remove Wallet" : "Reveal")
            : (progress < 0.5 ? "Reveal" : "Remove Wallet")

        HStack {
            Image(systemName: iconName)
            Text(text)
            Spacer()
        }
        .font(.system(size: 17, weight: .medium, design: .rounded))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(interpolateColor(from: fromBgColor, to: toBgColor))
        .foregroundColor(interpolateColor(from: fromFgColor, to: toFgColor))
        .cornerRadius(16)
        .opacity(progress < 0.5 ? 1 - progress * 2 : (progress - 0.5) * 2)
        .scaleEffect(progress < 0.5 ? 1.0 : 1.0)
    }
}

// Custom modifier for smooth simultaneous animations
struct SmoothTransitionModifier: ViewModifier {
    let opacity: Double
    let scale: CGFloat
    let yOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(y: yOffset)
    }
}

#Preview {
    ContentView()
}
