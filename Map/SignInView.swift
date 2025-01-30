//
//  SignInView.swift
//  Map
//
//  Created by saj panchal on 2025-01-29.
//

import SwiftUI
///authenticationServices framework
import AuthenticationServices
struct SignInView: View {
    ///binding variable that updates the parent view on change
    @Binding var isSignedIn: Bool
    @Environment(\.colorScheme) var bgMode: ColorScheme
    var body: some View {
        VStack {
            /// occupy remaining space
            Spacer()
            ///App logo
            Image("appstore")
                .resizable()
                .frame(width: 150, height: 150, alignment: .center)
                .cornerRadius(10.0)
                .shadow(color: bgMode == .dark ? Color(UIColor.darkGray) : .black, radius: 1, x: 1, y: 1)
            
            ///App Display name
            Text("AutoMate")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(bgMode == .dark ? .white : .black)
            Spacer()
            ///sign-in with apple button with label set as signin button. when tapped its on request parameter body will be executed which will prompt the user for touchID or faceID to fetch user creds.
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            }
            ///on completion of the request its on-completion body will be executed with result parameter as either success or failure.
            onCompletion: { result in
                ///switch cases for result variable
                switch result {
                    ///if result is success
                case .success:
                    print("Sign in successful")
                    ///set the flag true to indicate sign in successful.
                    isSignedIn = true
                    ///if result is failure.
                case .failure(let error):
                    ///reset the flag false to indicate sign in un-successful.
                    print(error.localizedDescription)
                    isSignedIn = false
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
            .padding()
            /// set the button style based on phone color scheme.
            .signInWithAppleButtonStyle(bgMode == .dark ? .white : .black)                        
        }
    }
}

#Preview {
    SignInView(isSignedIn: .constant(false))
}
