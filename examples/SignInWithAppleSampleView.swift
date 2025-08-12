//
//  SignInWithAppleSampleView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/12.
//

import AuthenticationServices
import SwiftUI

extension ASAuthorizationAppleIDProvider.CredentialState {
    var display: String {
        switch self {
        case .authorized:
            String(localized: "Authorized")
        case .notFound:
            String(localized: "Not Found")
        case .revoked:
            String(localized: "Revoked")
        case .transferred:
            String(localized: "Transferred")
        @unknown default:
            fatalError()
        }
    }
}

extension ASUserDetectionStatus {
    var display: String {
        switch self {
        case .unsupported:
            String(localized: "Unsupported")
        case .unknown:
            String(localized: "Unknown")
        case .likelyReal:
            String(localized: "Likely Real")
        @unknown default:
            fatalError()
        }
    }
}

extension ASUserAgeRange {
    var display: String {
        switch self {
        case .unknown:
            String(localized: "Unknown")
        case .child:
            String(localized: "Child")
        case .notChild:
            String(localized: "Not Child")
        @unknown default:
            fatalError()
        }
    }
}

@Observable
final class SignWithAppleSampleViewModel {
    var authorization: ASAuthorization? {
        didSet {
            if let authorization {
                userCredential =
                    authorization.credential
                    as? ASAuthorizationAppleIDCredential
                getCredentialState()
            }
        }
    }
    var userCredential: ASAuthorizationAppleIDCredential? = nil
    var signInError: String? = nil

    var authorizationState: ASAuthorizationAppleIDProvider.CredentialState =
        .notFound

    @ObservationIgnored let provider = ASAuthorizationAppleIDProvider()

    func handleSignInResult(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authorization):
            self.authorization = authorization
        case .failure(let error):
            signInError = error.localizedDescription
        }
    }

    func getCredentialState() {
        guard let userCredential else { return }
        provider.getCredentialState(forUserID: userCredential.user) {
            state,
            error in
            self.authorizationState = state
        }
    }
}

struct SignInWithAppleSampleView: View {
    @State private var viewModel = SignWithAppleSampleViewModel()

    var body: some View {
        List {
            if viewModel.authorizationState != .authorized {
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.handleSignInResult(result)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section {
                if let signInError = viewModel.signInError {
                    LabeledContent("SignIn Error", value: signInError)
                }
                LabeledContent(
                    "Credential State",
                    value: viewModel.authorizationState.display
                )
                if let userCredential = viewModel.userCredential {
                    DisclosureGroup("Apple ID Credential") {
                        if let identityToken = userCredential.identityToken,
                            let identityTokenString = String(
                                data: identityToken,
                                encoding: .utf8
                            )
                        {
                            LabeledContent(
                                "Identity Token(JWT)",
                                value: identityTokenString
                            )
                        }
                        if let authorizationCode = userCredential
                            .authorizationCode,
                            let authorizationCodeString = String(
                                data: authorizationCode,
                                encoding: .utf8
                            )
                        {
                            LabeledContent(
                                "Authorization Code",
                                value: authorizationCodeString
                            )
                        }
                        LabeledContent(
                            "State",
                            value: userCredential.state ?? ""
                        )
                        LabeledContent(
                            "User",
                            value: userCredential.user
                        )
                        LabeledContent(
                            "Full Name",
                            value: userCredential.fullName?.formatted(
                                .name(style: .long)
                            ) ?? ""
                        )
                        LabeledContent(
                            "Email",
                            value: userCredential.email ?? ""
                        )
                        LabeledContent(
                            "realUserStatus",
                            value: userCredential.realUserStatus.display
                        )
                        LabeledContent(
                            "User Age Range",
                            value: userCredential.userAgeRange.display
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    SignInWithAppleSampleView()
}
