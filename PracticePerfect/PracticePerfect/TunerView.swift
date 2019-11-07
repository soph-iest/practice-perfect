//
//  TunerView.swift
//  PracticePerfect
//
//  Created by Anna Matusewicz on 11/3/19.
//  Copyright © 2019 CS98PracticePerfect. All rights reserved.
//

import SwiftUI
import AudioKit

struct TunerView: View, TunerDelegate {
    @State var tuner = Tuner()
    @State var userFrequency = 261.6255653005986
    @State var noteFrequency = 261.6255653005986
    @State var note = Note(Note.Name.c, Note.Accidental.natural)
    @State var tunerOn = false
    
    struct NoteStyle: ViewModifier {
        func body(content: Content) -> some View {
            return content
                .foregroundColor(Color.black)
                .font(Font.custom("Arial Rounded MT Bold", size: 100))
        }
    }
    
    struct AccidentalStyle: ViewModifier {
        func body(content: Content) -> some View {
            return content
                .foregroundColor(Color.black)
                .font(Font.custom("Arial Rounded MT Bold", size: 50))
        }
    }
    
    struct ButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            return content
                .foregroundColor(Color.black)
                .padding()
                .font(Font.custom("Arial Rounded MT Bold", size: 18))
                .background(RadialGradient(gradient: Gradient(colors: [.white, .gray]), center: .center, startRadius: 40, endRadius: 100))
                .cornerRadius(6)
        }
    }
    
    var body: some View {
        ZStack {
            if tunerOn {
                LinearGradient(gradient: Gradient(colors: [makeSideColor(), makeMiddleColor(), makeSideColor()]), startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)
            } else {
                LinearGradient(gradient: Gradient(colors: [.red, .green]), startPoint: .leading, endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            }

            VStack {
                if !tunerOn {
                    Spacer()
                    Button(action: {
                        self.tuner.delegate = self
                        self.tuner.start()
                        self.tunerOn = true
                    }) {
                        Text("Start Tuner")
                    }
                        .modifier(ButtonStyle())
                } else {
                    Spacer()
                    Text(displayNote())
                        .modifier(NoteStyle())
                    HStack {
                        Text("Flat")
                            .modifier(AccidentalStyle())
                            .opacity(max(0, calulateCents() / -50))
                        Spacer()
                        Text("Sharp")
                            .modifier(AccidentalStyle())
                            .opacity(max(0, calulateCents() / 50))
                    }
                    Spacer()
                    Button(action: {
                        self.tuner.stop()
                        self.tunerOn = false
                    }) {
                        Text("Stop Tuner")
                    }
                        .modifier(ButtonStyle())
                }
            }
            .navigationBarTitle("Tuner")
        }
    }
    
    // Updates current note information from microphone
    func tunerDidTick(pitch: Pitch, frequency: Double) {
        self.userFrequency = frequency
        self.noteFrequency = pitch.frequency
        self.note = pitch.note
    }
    
    // Calculates the cents off of in tune
    // Equation taken from:
    // http://www.sengpielaudio.com/calculator-centsratio.htm
    func calulateCents() -> Double {
        let cents = 1200 * log2(userFrequency / noteFrequency)
        if cents > 50 || cents < -50 || (cents < 5 && cents > -5) {
            return 0
        }
        return cents
    }

    func makeSideColor() -> Color {
        let colors = setGreenRed()
        let red = colors.0
        let green = colors.1
        return Color(red: (red - 70)/255.0, green: (green - 70)/255.0, blue: 0.0/255.0)
    }
    
    func makeMiddleColor() -> Color {
        let colors = setGreenRed()
        let red = colors.0
        let green = colors.1
        return Color(red: red/255.0, green: green/255.0, blue: 0.0/255.0)
    }
    
    func setGreenRed() -> (Double, Double) {
        let red: Double
        let green: Double
        let cents = abs(calulateCents())
        if cents < 25 {
            green = 255.0
            red = 255.0 * (cents / 25.0)
        } else {
            red = 255.0
            green = 255.0 * ((50 - cents) / 25.0)
        }
        
        return (red, green)
    }
    
    func displayNote() -> String {
        var noteName: String
        var accidental: String
        
        switch note.note {
            case .a:
                noteName = "A"
            case .b:
                noteName = "B"
            case .c:
                noteName = "C"
            case .d:
                noteName = "D"
            case .e:
                noteName = "E"
            case .f:
                noteName = "F"
            case .g:
                noteName = "G"
        }
        
        switch note.accidental {
            case .sharp:
                accidental = "\u{266F}"
            case .flat:
                accidental = "\u{266D}"
            case .natural:
                accidental = ""
        }

        return noteName + accidental
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView().previewLayout(.fixed(width: 896, height: 414))
    }
}
