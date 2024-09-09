//
//  SignInGoogleHelper.swift
//  Pingo
//
//  Created by Zain Malik on 09/08/2024.
//

import Foundation
import GoogleSignIn

struct SignInWithGoogleResultModel{
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper{
    
    @MainActor
    func signIn() async throws -> SignInWithGoogleResultModel{
        guard let topVc = Utilities.shared.topViewController() else{
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVc)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let acessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = SignInWithGoogleResultModel(idToken: idToken, accessToken: acessToken)
        return tokens
    }
}
