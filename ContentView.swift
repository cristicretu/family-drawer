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
                ModalView(isPresented: $showModal)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

// UIKit Transition Controller
class CustomAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    let duration: TimeInterval

    init(isPresenting: Bool, duration: TimeInterval = 0.3) {
        self.isPresenting = isPresenting
        self.duration = duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = transitionContext.view(forKey: .to),
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        if isPresenting {
            containerView.addSubview(toView)
            toView.alpha = 0

            let springTiming = UISpringTimingParameters(
                dampingRatio: 0.7,
                initialVelocity: CGVector(dx: 0, dy: 0)
            )

            let animator = UIViewPropertyAnimator(
                duration: duration,
                timingParameters: springTiming
            )

            animator.addAnimations {
                toView.alpha = 1
                toView.transform = .identity
            }

            animator.addCompletion { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

            animator.startAnimation()
        } else {
            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeInOut
            )

            animator.addAnimations {
                toView.alpha = 0
            }

            animator.addCompletion { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

            animator.startAnimation()
        }
    }
}

// UIKit View Controller for Options
class OptionsViewController: UIViewController {
    var onPrivateKeyTap: (() -> Void)?
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        let hostingController = UIHostingController(
            rootView: OptionsView(
                onPrivateKeyTap: { [weak self] in
                    self?.onPrivateKeyTap?()
                },
                onDismiss: { [weak self] in
                    self?.onDismiss?()
                }
            ))

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }
}

// UIKit View Controller for Private Key
class PrivateKeyViewController: UIViewController {
    var onBack: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        let hostingController = UIHostingController(
            rootView: PrivateKeyView(
                onBack: { [weak self] in
                    self?.onBack?()
                }
            ))

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }
}

// Container for UIKit transition
struct ModalContainerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @State private var showPrivateKey = false

    func makeUIViewController(context: Context) -> UINavigationController {
        let optionsVC = OptionsViewController()
        optionsVC.onPrivateKeyTap = {
            showPrivateKey = true
        }
        optionsVC.onDismiss = {
            isPresented = false
        }

        let navController = UINavigationController(rootViewController: optionsVC)
        navController.isNavigationBarHidden = true
        navController.delegate = context.coordinator
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if showPrivateKey {
            if uiViewController.viewControllers.count == 1 {
                let privateKeyVC = PrivateKeyViewController()
                privateKeyVC.onBack = {
                    showPrivateKey = false
                    uiViewController.popViewController(animated: true)
                }
                uiViewController.pushViewController(privateKeyVC, animated: true)
            }
        } else {
            if uiViewController.viewControllers.count > 1 {
                uiViewController.popToRootViewController(animated: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UINavigationControllerDelegate {
        func navigationController(
            _ navigationController: UINavigationController,
            animationControllerFor operation: UINavigationController.Operation,
            from fromVC: UIViewController,
            to toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            return CustomAnimationController(isPresenting: operation == .push)
        }
    }
}

// SwiftUI View for Options
struct OptionsView: View {
    var onPrivateKeyTap: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 16) {
                HStack {
                    Text("Options")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                    Spacer()
                    Button(action: {
                        onDismiss()
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
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(32)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

// SwiftUI View for Private Key
struct PrivateKeyView: View {
    var onBack: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onBack()
                }

            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "creditcard")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                    Spacer()
                    Button(action: {
                        onBack()
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
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(32)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

struct ModalView: View {
    @Binding var isPresented: Bool
    @State private var showPrivateKey = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        if showPrivateKey {
                            showPrivateKey = false
                        } else {
                            isPresented = false
                        }
                    }
                }

            // Modal container that stays in place
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
        }
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
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ContentView()
}
