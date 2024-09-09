//
//  ContentView.swift
//  Pingo
//
//  Created by Zain Malik on 09/08/2024.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    
    let didCompleteProcess: () -> ()
    
    @StateObject private var viewModel1 = AuthenticationViewModel()
    @StateObject private var viewModel = SignInEmailModel()
    
    
    
    @State private var isAuthenticated: Bool = false
    
    @State var isLoginMode = false
    
    @State var showImagePicker = false
    @State var image = AuthenticationManager.shared.image
    
    var body: some View {
        NavigationStack{
            ScrollView{
                Picker("Picker Here", selection: $isLoginMode) {
                    Text("Login")
                        .tag(true)
                    Text("Create Account")
                        .tag(false)
                }.padding()
                
                if !isLoginMode{
                    Button{
                        showImagePicker.toggle()
                    } label: {
                        VStack{
                            if let image = self.image{
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 15)
                                    .padding(.vertical,30)
                                
                            }else{
                                Image("logo2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .offset(x:33, y: -30)
                            }
                        }
                    }
                }
                VStack(spacing: 15){
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal,10)
                        .padding(.vertical,12)
                        .background(Color.white) // Clean background
                        .cornerRadius(8) // Slightly smaller corner radius
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Subtle border
                        )
                        .padding(.horizontal,30)
                        .padding(.vertical,3)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding(.horizontal,10)
                        .padding(.vertical,12)
                        .background(Color.white)
                        .cornerRadius(8) // Slightly smaller corner radius
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                    
                    VStack(spacing: 20){
                        Button {
                            Task{
                                do{
                                    try await viewModel.signUp()
                                    isAuthenticated.toggle()
                                        didCompleteProcess()
                                    return
                                }catch{
//                                    print(error)
                                }
                                
                                do{
                                    try await viewModel.signIn()
                                    isAuthenticated.toggle()
                                    didCompleteProcess()
                                }catch{
//                                    print(error)
                                }
                            }
                        } label: {
                            Text(isLoginMode ?"Login" : "Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 45)
                                .frame(maxWidth: .infinity)
                                .background(Color.pingobackground)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal,30)
                        .navigationDestination(isPresented: $isAuthenticated) {
                           MainMessageView()
                       }
                    
                        Text("OR")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 16)
                        
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .icon, state: .normal)) {
                            Task{
                                do{
                                    try await viewModel1.signInGoogle()
                                }catch{
                                    print(error)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .frame(width: 300)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                    }
                    
                }
                
            }
            .navigationTitle(isLoginMode ?"Welcome Back" : "Create Account")
            .pickerStyle(.segmented)
            .background(Color.pingoextra)
        }
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: {
            if let selectedImage = image {
                AuthenticationManager.shared.image = selectedImage
                
            }
        }, content: {
            ImagePicker(image: $image)
                .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
            
        })
    }
}

#Preview {
    LoginView(didCompleteProcess: {})
}
