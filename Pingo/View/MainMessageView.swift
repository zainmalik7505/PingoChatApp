import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MainMessageView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    @State var messageScreen = false
    
    @State var shouldNavigateToChatLog = false

    //Which User is Selected
    @State var chatUser: ChatUser?
    
    private var customNavBar: some View {
        HStack(spacing: 16) {

                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.pingobackground.opacity(0.7), lineWidth: 2))
                    .shadow(radius: 4)

            
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.pingoextra)
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.white))
                }
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(3)
                    .background(Circle().foregroundColor(.pingoextra))
            }
        }
        .padding()
        .background(Color.pingotextfield)
        .cornerRadius(10)
        .padding(.horizontal)
        .shadow(radius: 8)
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    Task{
                        do{
                            try vm.logOut()
                        }catch{
                            print(error)
                        }
                    }
                    print("handle sign out")
                }),
                    .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.logOutButton, onDismiss: nil, content: {
            LoginView(didCompleteProcess: {
                vm.logOutButton = false
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
            })
        })
        .background(Color.pingotextfield)
    }
    
    private var chatLogViewModel1 = chatLogViewModel(chatUser: nil)

    var body: some View {
        NavigationStack {
            VStack {
                customNavBar
                messagesView

            }
            
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            }.navigationBarBackButtonHidden(true)
        

  
            NavigationLink(value: shouldNavigateToChatLog) {}
                .navigationDestination(isPresented: $shouldNavigateToChatLog) {
//                    ChatLogView(chatUser: self.chatUser)
                    ChatLogView(vm: chatLogViewModel1)
                }
         }
        
    
    
    private var messagesView: some View {

        ScrollView {
            ForEach(vm.recentMessage) { recentMessage in
                VStack {
                    Button {
                        // Determine the UID for the chat user
                        let uid = AuthenticationManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        

                            
                            // Initialize chatUser with data
                            self.chatUser = ChatUser(data: [
                                messageConstants.email: recentMessage.email,
                                messageConstants.profileImageUrl: recentMessage.profileImageUrl,
                                messageConstants.uid: uid
                            ])
                            
                            // Proceed only if chatUser is not nil
                            if let chatUser = self.chatUser {
                                self.chatLogViewModel1.chatUser = chatUser
                                self.chatLogViewModel1.fetchMessages()
                                self.shouldNavigateToChatLog.toggle()
                            } else {
                                print("Failed to initialize chatUser.")
                            }
                    
                    
                    }label: {
                        HStack(spacing: 16) {
                            // Profile Image Placeholder
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.pingobackground.opacity(0.7), lineWidth: 2))
                                .shadow(radius: 4)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recentMessage.email)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.pingoextra)
                                    .multilineTextAlignment(.leading)
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.white))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            VStack {
                                Text(vm.formatTimestamp(recentMessage.timestamp))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.pingotextfield)
    }

    
    private var newMessageButton: some View {
        Button {
            messageScreen.toggle()
            print("New Message Button Tapped")

        } label: {
            HStack {
                Image(systemName: "plus.message.fill")
                    .font(.system(size: 20))
                Text("New Message")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.pingoextra)
            .cornerRadius(25)
            .shadow(radius: 10)
        }.padding(.bottom, 20)
            .fullScreenCover(isPresented: $messageScreen, content: {
                NewMessageView(didSelectUser: {user in
                    self.shouldNavigateToChatLog.toggle()
                    self.chatUser = user
                    self.chatLogViewModel1.chatUser = user
                    self.chatLogViewModel1.fetchMessages()
                    
                })
            })
    }
}

#Preview {
    MainMessageView()
}
