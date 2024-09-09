//
//  MessageViewModel.swift
//  Pingo
//
//  Created by Zain Malik on 12/08/2024.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct RecentMessage: Identifiable, Codable {

  @DocumentID var id: String?

//  let documentId: String
  let text: String
  let fromId: String
  let toId: String
  let email: String
  let profileImageUrl: String
  let timestamp: Date
    

//    init(documentId: String, data: [String: Any]) {
//        self.documentId = documentId
//        self.text = data["text"] as? String ?? ""
//        self.fromId = data["fromId"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
//    }
}

struct ChatUser: Identifiable, Hashable {
    
    var id: String {uid}
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    @Published var logOutButton = false
    @Published var recentMessage = [RecentMessage]()
    
    
    init() {
        
        DispatchQueue.main.async {
            self.logOutButton  = AuthenticationManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    private var firestoreListener: ListenerRegistration?

    
    func fetchRecentMessages() {
        guard let uid = AuthenticationManager.shared.auth.currentUser?.uid else {
            print("Failed to fetch UID.")
            return
        }
        
        self.firestoreListener?.remove()
        self.recentMessage.removeAll()

//        print("Fetching recent messages for UID: \(uid)")
        
        firestoreListener = AuthenticationManager.shared.fireStore.collection("recent_messages").document(uid).collection("messages").order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to fetch recent messages: \(error)")
                    return
                }

                if let documents = querySnapshot?.documents {
//                    print("Fetched \(documents.count) documents.")
                    
                    for _ in documents {
//                        print("Document ID: \(document.documentID), Data: \(document.data())")
                    }
                } else {
                    print("No documents found.")
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    
                    
                    if let index = self.recentMessage.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessage.remove(at: index)
                    }
                    do{
                        if let rm = try? change.document.data(as: RecentMessage.self){
                            self.recentMessage.insert(rm, at: 0)
                        }
                    }catch{
                        print(error)
                    }
                    

//                    let newMessage = RecentMessage(documentId: docId, data: change.document.data())
//                    self.recentMessage.insert(newMessage, at: 0)
                    
//                    print("Inserted new message: \(newMessage)")
                }
                
//                print("Updated recent messages: \(self.recentMessage.count) messages")
            }
    }


    
    public func fetchCurrentUser() {
        
        guard let uid = AuthenticationManager.shared.auth.currentUser?.uid
        else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
//        print("User UID: \(uid)")


        AuthenticationManager.shared.fireStore.collection("user").document(uid).getDocument { snapshot, error in
            if let error = error {
//                print("Failed to fetch current user:", error)
                self.errorMessage = "Failed to fetch current user: \(error)"
                return
            }
            
            guard let data = snapshot?.data() else {
//                print("No data found for user ID: \(uid)")
                self.errorMessage = "No data found for user ID: \(uid)"
                return
            }
            
//            print("Fetched data: \(data)")
            self.chatUser = ChatUser(data: data)
        
        }
    }
    
    func logOut() throws{
        logOutButton.toggle()
       try AuthenticationManager.shared.logOut()
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let now = Date()
              let calendar = Calendar.current
              
              let components = calendar.dateComponents([.day, .hour], from: date, to: now)
              
              if let days = components.day, days >= 7 {
                  let weeks = days / 7
                  return "\(weeks) week\(weeks > 1 ? "s" : "") ago"
              } else if let days = components.day, days >= 1 {
                  return "\(days) day\(days > 1 ? "s" : "") ago"
              } else if let hours = components.hour, hours >= 1 {
                  return "\(hours) hour\(hours > 1 ? "s" : "") ago"
              } else {
                  let minutes = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0
                  if minutes > 0 {
                      return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
                  } else {
                      return "Just now"
                  }
              }
    }

}
