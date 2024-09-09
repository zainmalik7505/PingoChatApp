//
//  ChatLogView.swift
//  Pingo
//
//  Created by Zain Malik on 15/08/2024.
//

import SwiftUI



struct ChatLogView: View {
    
//    let chatUser: ChatUser?
//    init(chatUser: ChatUser?) {
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser)
//        
//    }
    @ObservedObject var vm : chatLogViewModel
    
    //    @State var chatText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            messageDisplay
            
            messageInputBar
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .padding(.bottom)
        }
        .background(Color(.pingoextra))
        .navigationTitle(vm.chatUser?.email ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }.onDisappear{
            vm.firestoreListener?.remove()
        }
    }
    
    static let emptyScrollViewString = "Empty"
    
    private var messageDisplay: some View{
        ScrollView {
            ScrollViewReader{ScrollViewProxy in
                VStack(spacing: 12) {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack{Spacer()}
                        .id(ChatLogView.emptyScrollViewString)
                        .onReceive(vm.$count, perform: { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                ScrollViewProxy.scrollTo(ChatLogView.emptyScrollViewString, anchor: .bottom)
                            }
                        })
                }
                .padding(.top)
            }
        }
    }
    
    struct MessageView: View{
        let message : chatMessage
        var body: some View {
            VStack {
                if message.fromId == AuthenticationManager.shared.auth.currentUser?.uid {
                    HStack {
                        Spacer()
                        HStack {
                            Text(message.text)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.pingotextfield)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    HStack {
                        HStack {
                            Text(message.text)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
        
    }
    

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                
            }) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 24))
                    .foregroundColor(.pingobackground)
            }
            
            TextField("Write message...", text: $vm.chatText)
                .padding(12)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Button(action: {
                vm.chatHandler()
                print("Send Button Tapped")
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.pingobackground)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.pingobackground.opacity(0.2))
            .cornerRadius(12)
        }
    }
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "arrowshape.backward.fill")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.pingobackground)
        }
    }
}


//#Preview {
////    NavigationView {
////        ChatLogView(chatUser: ChatUser(data: ["uid": "123", "email": "zain@gmail.com", "profileImageUrl": "https://example.com/profile.jpg"]))
////    }
//    
//}



