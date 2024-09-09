//
//  newMessageView.swift
//  Pingo
//
//  Created by Zain Malik on 14/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewMessageView: View {
    
    //Which User is Selected
    let didSelectUser: (ChatUser) -> ()
    
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = NewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Ensure the background color is applied first
                Color.pingoextra
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ScrollView {
                        ForEach(vm.users) { user in
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                didSelectUser(user)
                            } label: {
                                HStack(spacing: 12) {
                                    WebImage(url: URL(string: user.profileImageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.pingobackground.opacity(0.7), lineWidth: 2))
                                        .shadow(radius: 4)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.email)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color.black)
                                        
                                        Text("Tap to start a conversation")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 72)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.pingotextfield)
                    }
                }
            }
        }
    }
}


#Preview {
    MainMessageView()
    //    NewMessageView()
}
