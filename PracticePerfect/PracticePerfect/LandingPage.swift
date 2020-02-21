//
//  LandingPage.swift
//  Practice Perfect
//
//  Created by Abigail Chen on 11/3/19.
//  Copyright © 2019 CS98 Practice Perfect. All rights reserved.
//
// Environment variable/UserDefaults use:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-environmentobject-to-share-data-between-views
// https://www.hackingwithswift.com/read/12/2/reading-and-writing-basics-userdefaults
// https://medium.com/better-programming/userdefaults-in-swift-4-d1a278a0ec79
//
// isActive navigation method inspired by: https://stackoverflow.com/a/59662275


import SwiftUI

struct LandingPage: View {
    @EnvironmentObject var settings: UserSettings
    @State var isActive : Bool = false
    
    let note: some View = Image("note").resizable().frame(width: 75, height: 75)
    let smallNote: some View = Image("note").resizable().frame(width: 50, height: 50)
    
    var body: some View {
        ZStack {
            mainGradient
            
            VStack {
                HStack {
                    Spacer()
                    smallNote
                    note
                }
                HStack {
                    Spacer()
                    smallNote
                }
                Spacer()
                HStack {
                    smallNote
                    Spacer()
                }
                HStack {
                    note
                    smallNote
                    Spacer()
                }
            }
            VStack {
                Image("full-logo")
                
                HStack {
                    NavigationLink(destination: SelectMusic(rootIsActive: self.$isActive), isActive: self.$isActive) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play!")
                                .fixedSize()
                        }
                    }
                    .isDetailLink(false)
                    .modifier(MenuButtonStyle())
                    
                    NavigationLink(destination: TunerView()) {
                        HStack {
                            Image(systemName: "tuningfork")
                            Text("Tuner")
                                .fixedSize()
                        }
                    }
                    .modifier(MenuButtonStyle())
                }
                
                HStack {
                    NavigationLink(destination: ScalePicker(rootIsActive: self.$isActive),
                        isActive: self.$isActive) {
                        HStack {
                            Image(systemName: "music.note")
                            Text("Scales")
                                .fixedSize()
                        }
                    }
                    .isDetailLink(false)
                    .modifier(MenuButtonStyle())
                    
                    NavigationLink(destination: SettingsView(selectedClef: settings.clefIndex, selectedKey: settings.keyIndex)) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                                .fixedSize()
                        }
                    }
                    .modifier(MenuButtonStyle())
                }
            }
            .navigationBarTitle(settings.username ?? "")
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage().previewLayout(.fixed(width: 896, height: 414))
    }
}
