//
//  LoginPage.swift
//  PracticePerfect
//
//  Created by Sean Hawkins on 1/14/20.
//  Copyright © 2020 CS98PracticePerfect. All rights reserved.
//

import SwiftUI

public var userData: [String:String] = ["username":"Not signed in", "id": "-1"]

// https://stackoverflow.com/a/58242249
final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height - 10
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

struct LoginPage: View {
    @State var username: String = ""
    @State var password: String = ""
    
    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var textFieldInput: String = ""
    @State var showErrorMessage: Bool = false
    @State var loginButtonDisabled: Bool = true

    var body: some View {
        ZStack {
            mainGradient

            VStack {
                Text("Enter your username and password!")
                    .font(.largeTitle)
                if self.showErrorMessage {
                    Text("Error: no account found with this username and password. Please try again.")
                        .background(Color.red)
                        .foregroundColor(Color.white)
                }
                TextField("Username", text: $username)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 5)
                    .frame(width: 500)
               SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 5)
                    .frame(width: 500)
                HStack {
                    Button(action: {
                            // Retrieve login data and parse
                        let loginUrl = URL(string: "https://practiceperfect.appspot.com/users/" + self.username + "/" + self.password)!
                        let loginSession = URLSession.shared
                        var loginRequest = URLRequest(url: loginUrl)
                        loginRequest.httpMethod = "GET"

                        let loginSemaphore = DispatchSemaphore(value: 0)
                        let loginTask = loginSession.dataTask(with: loginRequest) { data, response, error in
                            // Unwrap data
                            guard let unwrappedData = data else {
                                print(error!)
                                return
                            }
                            // Get json object from data
                            let loginData: AnyObject = try! JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                            if(loginData["statusCode"] as? Int == 404){
                                self.showErrorMessage = true
                                self.loginButtonDisabled = true
                                userData = ["id": "-1"]
                            } else {
                                self.showErrorMessage = false
                                self.loginButtonDisabled = false
                                userData["id"] = "\(loginData["id"] as! Int)"
                                userData["username"] = (loginData["username"] as! String)
                            }
                            loginSemaphore.signal()
                        }
                        loginTask.resume()
                        // Wait for the login to be retrieved before displaying all of them
                        _ = loginSemaphore.wait(wallTimeout: .distantFuture)
                        
                    }) {
                        HStack {
                            Text("Verify")
                        }
                    }
                    .modifier(MenuButtonStyle())
                    
                    if(!self.loginButtonDisabled){
                        NavigationLink(destination: LandingPage()) {
                            HStack {
                                Text("Login")
                            }
                        }
                        .modifier(MenuButtonStyle())
                    }
                }
                Text("or").fixedSize().padding(.bottom, 5)
                NavigationLink(destination: SignUpPage(username: username, password: password, keyboard: keyboard)) {
                    HStack {
                        Text("Sign Up")
                    }
                }
                .modifier(MenuButtonStyle())
            }
        }
        .foregroundColor(.black)
        .padding(.bottom, keyboard.currentHeight)
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeOut(duration: 0.16))
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage().previewLayout(.fixed(width: 896, height: 414))
    }
}
