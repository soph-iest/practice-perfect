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
    @State private var textFieldInput: String = ""
    @State var continueButtonDisabled: Bool = true
    @State var showErrorMessage: Bool = false

    var body: some View {
        ZStack {
            mainGradient

            VStack {
                Text("Enter your information below!")
                    .padding(.bottom, 15)
                    .font(.largeTitle)
                    .frame(width: 500)
                if(self.showErrorMessage){
                    Text("Error creating account. Please try again later.")
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .font(.system(size: 14))
                        .frame(width: 500)
                }
                HStack {
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .frame(width: 300)
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .frame(width: 300)
                }
                HStack {
                    TextField("Username (optional)", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .frame(width: 300)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .frame(width: 300)
                }
                HStack {
                    Button(action: {
                        // Retrieve signup data and parse
                        let signupUrl = URL(string: "https://practiceperfect.appspot.com/users")!
                        let signupSession = URLSession.shared
                        var signupRequest = URLRequest(url: signupUrl)
                        signupRequest.httpMethod = "POST"
                        let params: [String: String] = ["email": self.email, "username": self.username, "password": self.password, "name": self.name, "level": "1"]
                        signupRequest.httpBody = try? JSONSerialization.data(withJSONObject: params)
                        signupRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

                        let signupSemaphore = DispatchSemaphore(value: 0)
                        let signupTask = signupSession.dataTask(with: signupRequest) { data, response, error in
                            // Unwrap data
                            guard let unwrappedData = data else {
                                print(error!)
                                return
                            }
                            // Get json object from data
                            let signupData: AnyObject = try! JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                            if(signupData["statusCode"] as? Int == 404){
                                self.showErrorMessage = true
                                self.continueButtonDisabled = true
                                userData = ["id": "-1"]
                            } else {
                                self.showErrorMessage = false
                                self.continueButtonDisabled = false
                                userData["id"] = "\(signupData["id"] as! Int)"
                                userData["username"] = (signupData["username"] as! String)
                            }
                            signupSemaphore.signal()
                        }
                        signupTask.resume()
                        // Wait for the signup to be retrieved before displaying all of them
                        _ = signupSemaphore.wait(wallTimeout: .distantFuture)
                        
                    }) {
                        HStack {

                            Text("Verify")
                        }
                    }
                    .modifier(MenuButtonStyle())
                    if(!self.continueButtonDisabled){
                        NavigationLink(destination: LandingPage()) {
                            HStack {
                                Text("Sign Up")
                                    .fixedSize()
                            }
                        }
                        .modifier(MenuButtonStyle())
                    }
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
