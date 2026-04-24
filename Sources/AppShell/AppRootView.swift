import Authentication
import DesignSystem
import Features
import Networking
import SwiftUI

public struct AppRootView: View {
    @State private var sessionStore = SessionStore()

    public init() {}

    public var body: some View {
        Group {
            switch sessionStore.state {
            case .checking:
                LaunchView()
            case .signedOut:
                AuthView(sessionStore: sessionStore)
            case .signedIn:
                SignedInRootView(api: sessionStore.api) {
                    Task {
                        await sessionStore.logout()
                    }
                }
            }
        }
        .background(RSColor.backgroundDefault.ignoresSafeArea())
        .task {
            await sessionStore.restore()
        }
    }
}

private struct LaunchView: View {
    var body: some View {
        VStack(spacing: RSSpacing.large) {
            Text("Reading Society")
                .font(RSTypography.display)
                .foregroundStyle(RSColor.textPrimary)

            ProgressView()
                .tint(RSColor.accentPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AuthView: View {
    private enum Mode: String, CaseIterable {
        case login = "Sign in"
        case register = "Register"
    }

    let sessionStore: SessionStore

    @State private var mode: Mode = .login
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case email
        case password
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
                header
                authForm
            }
            .padding(RSSpacing.large)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity, minHeight: 720, alignment: .center)
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: mode) { _, _ in
            sessionStore.clearError()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RSSpacing.medium) {
            Text("Reading Society")
                .font(RSTypography.display)
                .foregroundStyle(RSColor.textPrimary)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            Text("A private room for shared reading, marginalia, discussion, and the slow record of a book in progress.")
                .font(RSTypography.bodyLarge)
                .foregroundStyle(RSColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var authForm: some View {
        RSCard {
            VStack(alignment: .leading, spacing: RSSpacing.large) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                VStack(spacing: RSSpacing.medium) {
                    if mode == .register {
                        RSTextField("Name", text: $name)
                            .focused($focusedField, equals: .name)
                            .textContentType(.name)
                            .submitLabel(.next)
                    }

                    RSTextField("Email", text: $email)
                        .focused($focusedField, equals: .email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)

                    RSSecureField("Password", text: $password, helper: passwordHelper)
                        .focused($focusedField, equals: .password)
                        .textContentType(mode == .login ? .password : .newPassword)
                        .submitLabel(.go)
                }

                if let errorMessage = sessionStore.errorMessage {
                    Text(errorMessage)
                        .font(RSTypography.small)
                        .foregroundStyle(RSColor.accentPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                RSButton(buttonTitle, variant: .primary) {
                    submit()
                }
                .disabled(!canSubmit || sessionStore.isSubmitting)
                .opacity(!canSubmit || sessionStore.isSubmitting ? 0.55 : 1)

                if sessionStore.isSubmitting {
                    ProgressView()
                        .tint(RSColor.accentPrimary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var buttonTitle: String {
        mode == .login ? "Sign in" : "Create account"
    }

    private var passwordHelper: String? {
        mode == .register ? "Use at least eight characters." : nil
    }

    private var canSubmit: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .login:
            return !trimmedEmail.isEmpty && !password.isEmpty
        case .register:
            return !trimmedName.isEmpty && !trimmedEmail.isEmpty && password.count >= 8
        }
    }

    private func submit() {
        guard canSubmit else {
            return
        }

        Task {
            switch mode {
            case .login:
                await sessionStore.login(email: email, password: password)
            case .register:
                await sessionStore.register(name: name, email: email, password: password)
            }
        }
    }
}
