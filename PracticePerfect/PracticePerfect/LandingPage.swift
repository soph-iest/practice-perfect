//
//  LandingPage.swift
//  Practice Perfect
//
//  Created by Abigail Chen on 11/3/19.
//  Copyright © 2019 CS98 Practice Perfect. All rights reserved.
//

import SwiftUI

struct LandingPage: View {
    @State var isNavigationBarHidden: Bool = false
    
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
                    NavigationLink(destination: SelectMusic(isNavigationBarHidden: $isNavigationBarHidden)) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play!")
                                .fixedSize()
                        }
                    }
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
                    NavigationLink(destination: PracticeView()) {
                        HStack {
                            Image(systemName: "music.note")
                            Text("Practice")
                                .fixedSize()
                        }
                    }
                    .modifier(MenuButtonStyle())
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                                .fixedSize()
                        }
                    }
                    .modifier(MenuButtonStyle())
                }
            }
            .navigationBarTitle("")
//            .navigationBarHidden(true)
            .onAppear {
                self.isNavigationBarHidden.toggle()
            }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage().previewLayout(.fixed(width: 896, height: 414))
    }
}
