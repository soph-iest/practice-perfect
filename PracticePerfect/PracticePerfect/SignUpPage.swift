//
//  SignUpPage.swift
//  PracticePerfect
//
//  Created by Sean Hawkins on 1/14/20.
//  Copyright © 2020 CS98PracticePerfect. All rights reserved.
//

import SwiftUI

// https://stackoverflow.com/a/58242249

struct SignUpPage: View {
    @State var name: String = ""
    @State var email: String = ""
    @State var username: String
    @State var password: String
    
    @ObservedObject var keyboard: KeyboardResponder
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    @State private var textFieldInput: String = ""
    @State var showErrorMessage: Bool = false
    @State var showUnfilledMessage: Bool = false
    @State var showTakenInfoMessage: Bool = false

    var body: some View {
        ZStack {
            mainGradient

            VStack {
                Text("Enter your information below!")
                    .padding(.bottom, 15)
                    .font(.largeTitle)
                    .frame(width: 500)
                if (self.showErrorMessage) {
                    Text("Error creating account. Please try again later.")
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .font(.body)
                        .frame(width: 500)
                }
                if (self.showUnfilledMessage) {
                    Text("Please fill out all fields!")
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .font(.body)
                        .frame(width: 500)
                }
                if (self.showTakenInfoMessage) {
                    Text("Username or email already taken!")
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .font(.body)
                        .frame(width: 500)
                }
                HStack {
                    ZStack(alignment: .leading) {
                        TextField("", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .frame(width: 300)
                        if name.isEmpty { Text("Name").foregroundColor(Color.gray) }
                    }
                    ZStack(alignment: .leading) {
                        TextField("", text: $email)
                            .autocapitalization(UITextAutocapitalizationType.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .frame(width: 300)
                        if email.isEmpty { Text("Email").foregroundColor(Color.gray) }
                    }
                }
                HStack {
                    ZStack(alignment: .leading) {
                        TextField("", text: $username)
                            .autocapitalization(UITextAutocapitalizationType.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .frame(width: 300)
                        if username.isEmpty { Text("Username (optional)").foregroundColor(Color.gray) }
                    }
                    
                    ZStack(alignment: .leading) {
                        SecureField("", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .frame(width: 300)
                        if password.isEmpty { Text("Password").foregroundColor(Color.gray) }
                    }
                }
                HStack {                    
                    Button(action: {
                        if self.name != "" && self.password != "" && self.email != "" && self.username != "" && self.email.contains("@") {
                            // Retrieve signup data and parse
                            let signupUrl = URL(string: "https://practiceperfect.appspot.com/users")!
                            let signupSession = URLSession.shared
                            var signupRequest = URLRequest(url: signupUrl)
                            signupRequest.httpMethod = "POST"
                            let params: [String: String] = ["email": self.email, "username": self.username, "password": self.password, "name": self.name, "level": "1"]
                            signupRequest.httpBody = try? JSONSerialization.data(withJSONObject: params)
                            signupRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

                            var successful: Bool = false
                            
                            let signupSemaphore = DispatchSemaphore(value: 0)
                            let signupTask = signupSession.dataTask(with: signupRequest) { data, response, error in
                                // Unwrap data
                                guard let unwrappedData = data else {
                                    print(error!)
                                    return
                                }
                                // Get json object from data
                                let signupData: AnyObject = try! JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                                if (signupData["statusCode"] as? Int == 404) {
                                    self.showErrorMessage = true
                                } else if signupData["statusCode"] as? Int == 400 {
                                    self.showTakenInfoMessage = true
                                } else {
                                    self.showErrorMessage = false
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.set(signupData["id"] as! Int, forKey: "userId")
                                        self.settings.userId = signupData["id"] as! Int
                                        UserDefaults.standard.set(signupData["username"] as? String, forKey: "username")
                                        self.settings.username = signupData["username"] as? String
                                    }
                                    successful = true
                                }
                                signupSemaphore.signal()
                            }
                            signupTask.resume()
                            // Wait for the signup to be retrieved before displaying all of them
                            _ = signupSemaphore.wait(wallTimeout: .distantFuture)
                            
                            if successful {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            self.showUnfilledMessage = true
                        }
                    }) {
                        HStack {
                            Text("Create Account")
                        }
                    }
                    .modifier(MenuButtonStyle())
                }
            }
        }
        .foregroundColor(.black)
        .padding(.bottom, keyboard.currentHeight)
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeOut(duration: 0.16))
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(username: "username", password: "password", keyboard: KeyboardResponder()).previewLayout(.fixed(width: 896, height: 414))
    }
}
