//
//  PingoApp.swift
//  Pingo
//
//  Created by Zain Malik on 09/08/2024.
//

import SwiftUI
import Firebase

@main
struct PingoApp: App {
    
    init(){
        FirebaseApp.configure()
        print("Firebase Configured")
    }

    var body: some Scene {
        WindowGroup {
            LoginView(didCompleteProcess: {
            })
        }
    }
    
}
