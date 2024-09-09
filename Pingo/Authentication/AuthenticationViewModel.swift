//
//  AuthenticationViewModel.swift
//  Pingo
//
//  Created by Zain Malik on 09/08/2024.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject{
    
    func signInGoogle() async throws{
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}
    
