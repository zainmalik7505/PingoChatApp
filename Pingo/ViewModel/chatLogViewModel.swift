//
//  chatLogViewModel.swift
//  Pingo
//
//  Created by Zain Malik on 17/08/2024.
//

import Foundation
import Firebase

struct messageConstants{
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timeStamp = "timestamp"
    static let profileImageUrl = "profileImageUrl"
    static let email = "email"
    static let uid = "uid"
}

struct chatMessage: Identifiable{
    var id:String { documentId }
    
    let documentId: String
    let fromId, toId , text : String
    
    init(documentId: String , data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[messageConstants.fromId] as? String ?? ""
        self.toId = data[messageConstants.toId] as? String ?? ""
        self.text = data[messageConstants.text] as? String ?? ""
    }
}


class chatLogViewModel : ObservableObject {
    
    @Published var count = 0
    @Published var chatText = ""
    @Published var chatMessages = [chatMessage]()
    
    var firestoreListener: ListenerRegistration?
    
    var chatUser : ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
     func fetchMessages() {
        guard let fromId = AuthenticationManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
         
         firestoreListener?.remove()
         chatMessages.removeAll()
        firestoreListener = AuthenticationManager.shared.fireStore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }

                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        let documentId = change.document.documentID
                        let chatMessage = chatMessage(documentId: documentId, data: data)
                        self.chatMessages.append(chatMessage)
                       print("Appending chatMessage at \(Date())")
                    }
                }
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            
                
//                querySnapshot?.documentChanges.forEach({ change in
//                    if change.type == .added {
//                        let data = change.document.data()
//                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
//                    }
//                })
            }
    }
    
    private func presistRecentMessage(){
        guard let chatUser = chatUser else { return }
        
        guard let uid = AuthenticationManager.shared.auth.currentUser?.uid else{ return }
        
        guard let toId = self.chatUser?.uid else {return }
        
        let document = AuthenticationManager.shared.fireStore.collection("recent_messages").document(uid).collection("messages").document(toId)

        let data = [ "timestamp": Timestamp(), messageConstants.text: self.chatText, messageConstants.fromId: uid , messageConstants.toId: toId, messageConstants.profileImageUrl: chatUser.profileImageUrl, messageConstants.email: chatUser.email ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error{
                print(error)
                return
            }
        }
        
    }
    
    
    func chatHandler(){
        guard let fromId = AuthenticationManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toId = chatUser?.uid else {
            return
        }
        
        let messageData = [
            messageConstants.fromId: fromId,
            messageConstants.toId: toId,
            messageConstants.text: self.chatText,
            "timestamp": Timestamp()
        ] as [String : Any]
        
        let document = AuthenticationManager.shared.fireStore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                return
            }
            
            self.presistRecentMessage()
            // Clear the chat text after sending the message
            self.chatText = ""
            self.count += 1
        }
        
        let senderDocument = AuthenticationManager.shared.fireStore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        senderDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                return
            }
        }
    }
}

