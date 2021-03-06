//
//  SettingsView.swift
//  PracticePerfect
//
//  Created by Anna Matusewicz on 11/3/19.
//  Copyright © 2019 CS98PracticePerfect. All rights reserved.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var clefIndex = UserDefaults.standard.integer(forKey: "clefIndex")
    @Published var keyIndex = UserDefaults.standard.integer(forKey: "keyIndex")
    @Published var username = UserDefaults.standard.string(forKey: "username")
    @Published var userId = UserDefaults.standard.integer(forKey: "userId")
    @Published var firstDate = UserDefaults.standard.string(forKey: "firstDate")
    @Published var mostRecentDate = UserDefaults.standard.string(forKey: "mostRecentDate")
    @Published var dailyTimes = UserDefaults.standard.array(forKey: "dailyTimes")
    @Published var tuner = Tuner()
}

let scaleOrder: [String] = ["G♭", "D♭", "A♭", "E♭", "B♭", "F", "C", "G", "D", "A", "E", "B", "F♯"].reversed()

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var loggedOut : Bool
    
    let clefs = ["Treble", "Alto", "Bass"]
    
    @State var selectedClef: Int
    @State var selectedKey: Int
        
    var body: some View {
        ZStack {
            mainGradient
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    HStack {
                        Text("What clef would you like to use?")
                            .font(Font.title.weight(.bold))
                        Spacer()
                        VStack {
                            Picker(selection: $selectedClef, label: EmptyView()) {
                                ForEach(0 ..< clefs.count) {
                                    Text(String(self.clefs[$0]))
                                }
                            }.labelsHidden()
                            .frame(maxWidth: 200)
                            .clipped()
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("What key is your instrument tuned to?")
                            .font(Font.title.weight(.bold))
                        Spacer()
                        VStack {
                            Picker(selection: $selectedKey, label: EmptyView()) {
                                ForEach(0 ..< scaleOrder.count) {
                                    Text(String(scaleOrder[$0]))
                                }
                            }.labelsHidden()
                            .frame(maxWidth: 200)
                            .clipped()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
                VStack {
                    Button (action: {
                        UserDefaults.standard.set(self.selectedClef, forKey: "clefIndex")
                        self.settings.clefIndex = self.selectedClef
                        UserDefaults.standard.set(self.selectedKey, forKey: "keyIndex")
                        self.settings.keyIndex = self.selectedKey
                        
                        self.presentationMode.wrappedValue.dismiss()
                    } ){
                        Text("Save Preferences")
                    }
                    .modifier(MenuButtonStyle())
                }
                Spacer()
            }
        }
        .foregroundColor(.black)
        .navigationBarTitle("Settings")
        .navigationBarItems(trailing:
            Button(action: {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(nil, forKey: "userId")
                    self.settings.userId = -1
                    UserDefaults.standard.set(nil, forKey: "username")
                    self.settings.username = nil
                }
                self.loggedOut = true
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text("Logout")
                        .fixedSize()
                }
            }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(loggedOut: .constant(false), selectedClef: 0, selectedKey: 0)
    }
}
