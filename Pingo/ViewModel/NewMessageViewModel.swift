//
//  NewMessageViewModel.swift
//  Pingo
//
//  Created by Zain Malik on 15/08/2024.
//

import Foundation

class NewMessageViewModel : ObservableObject{
    
    @Published var users = [ChatUser]()
    
    init(){
        fetchAllUsers()
    }
    
    private func fetchAllUsers(){
        AuthenticationManager.shared.fireStore.collection("user").getDocuments { documentSnapshot, error in
            if let error = error{
                print("Failed to fetch users:\(error)")
                return
            }
            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                self.users.append(.init(data: data))
            })
        }
    }

}
