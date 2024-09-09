//
//  SignInEmailModel.swift
//  Pingo
//
//  Created by Zain Malik on 09/08/2024.
//

import Foundation

@MainActor
final class SignInEmailModel : ObservableObject{
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard  !email.isEmpty && !password.isEmpty else{
            print("Enter Valid Email Password")
            return
        }
        
            let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
        
    }
    
    func signIn() async throws {
        guard  !email.isEmpty && !password.isEmpty else{
            print("Enter Valid Email Password")
            return
        }
        
            let _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
    }
}
