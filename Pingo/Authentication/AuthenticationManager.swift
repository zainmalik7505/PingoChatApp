//
//  AuthenticationManager.swift
//  Pingo
//
//  Created by Zain Malik on 09/08/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage



enum AuthProviderOption: String{
    case email = "password"
    case google = "google.com"
}



struct AuthDataResultModel{
    let uid: String
    let email: String?
    let photoUrl: String?
    
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}


final class AuthenticationManager{
    

    
    static let shared = AuthenticationManager()
    var image : UIImage?

    let auth: Auth
    let storage: Storage
    let fireStore : Firestore
    
    
    private init(){
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
        self.auth = Auth.auth()
    }
    
    
    
//    func getCurrentUserUID() -> String? {
//        return Auth.auth().currentUser?.uid
//    }
    

    func getRegisteredUser() throws -> AuthDataResultModel{
        guard let registeredUser = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: registeredUser)
    }

    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            }else{
                assertionFailure("Provider Option not Find: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    
    func logOut() throws{
        try Auth.auth().signOut()
    }
    
}

// MARK: Sign In Email
extension AuthenticationManager{
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        do {
            try await presistImageToStorage(user: authDataResult.user)
        } catch {
            print("Failed to upload image: \(error)")
        }
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func presistImageToStorage(user: User) async throws {
        guard let uid = Auth.auth().currentUser?.uid else{ return }
        let ref = storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        
        do {
            _ = try await ref.putDataAsync(imageData, metadata: nil)
            let url = try await ref.downloadURL()
            try await storeUserInformation(imageProfileUrl: url, user: user)
        } catch {
            throw error
        }
    }
    
    func storeUserInformation(imageProfileUrl: URL, user: User) async throws {
        guard let uid = Auth.auth().currentUser?.uid else{ return }

        let userData: [String: Any] = [
            "uid": uid,
            "email": user.email ?? "",
            "profileImageUrl": imageProfileUrl.absoluteString
        ]
        
        do {
            try await fireStore.collection("user").document(uid).setData(userData)
        } catch {
            throw error
        }
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)

        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    func updatePassword(password:String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    
    func updatePassword(email:String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
    
    
    
}

// MARK: SIGN IN SSO

extension AuthenticationManager{
    
    @discardableResult
    func signInWithGoogle(tokens: SignInWithGoogleResultModel) async throws -> AuthDataResultModel{
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}

