//
//  BackgroundFilter.swift
//  PracticePerfect
//
//  Created by Sean Hawkins on 2/19/20.
//  Copyright © 2020 CS98PracticePerfect. All rights reserved.
//

import SwiftUI

struct BackgroundFilter: View, TunerDelegate {
    @Binding var rootIsActive : Bool
    @EnvironmentObject var settings: UserSettings
    
    // Song metadata passed from song selection - used to retrieve music data from backed through API
    var songMetadata: SongMetadata
    var tempo: Int
    var timeSig: (Int, Int)
    @State var showPrevious: Bool
    var measures: [MeasureMetadata]
        
    // Tuner variables 
    @State var isOn = false
    @State var startedCalibrating = false
    @State var backgroundMeanAmplitude: Float = 0.0
    @State var backgroundReadingCount: Int = 0
    @State var calibrated: Bool = false
    
    var body: some View {
        ZStack {
            mainGradient
            VStack {
                Spacer()
                Text("Take a minute to calibrate the tuner to the level of background noise where you're playing.")
                    .multilineTextAlignment(.center)
                    .font(.title)
                Spacer()
                HStack() {
                    HStack {
                        if isOn {
                            Button(action: {
                                self.settings.tuner.stop()
                                self.isOn = false
                                self.calibrated = true
                                self.settings.tuner.beatCount = 0
                            }) {
                                Text("Stop")
                                    .font(.title)
                            }
                                 .modifier(MenuButtonStyle())
                            .frame(width: 125)
                        } else if startedCalibrating {
                            Button(action: {
                                self.startTuner()
                            }) {
                                Text("Recalibrate")
                                    .font(.title)
                            }
                                 .modifier(MenuButtonStyle())
                        } else {
                            Button(action: {
                                self.startTuner()
                                self.startedCalibrating = true
                            }) {
                                Text("Calibrate")
                                    .font(.title)
                                    .fixedSize()
                            }
                                 .modifier(MenuButtonStyle())
                        }
                    }
                    .frame(width: 200)
                       
                    Spacer()
                    
                    NavigationLink(destination: PlayMode(rootIsActive: self.$rootIsActive, songMetadata: songMetadata, tempo: tempo, isSong: self.showPrevious, tuner: self.settings.tuner, measures: self.measures)) {
                        Text("Play!")
                            .font(.title)
                    }
                    .isDetailLink(false)
                    .modifier(MenuButtonStyle())
                    .frame(width: 200)
                    .disabled(self.isOn || !self.calibrated)
                    .opacity((self.isOn || !self.calibrated) ? 0.5 : 1)
                }
                .frame(maxWidth: 450)
                Spacer()
            }
        }
        .foregroundColor(.black)
        .onAppear() {
            self.settings.tuner.beatCount = 0
        }
    }
    
    // Updates current note information from microphone
    func tunerDidTick(pitch: Pitch, frequency: Double, beatCount: Int, change: Bool) {
        backgroundReadingCount += 1
        backgroundMeanAmplitude = (Float(backgroundReadingCount - 1) * backgroundMeanAmplitude + Float(settings.tuner.tracker.amplitude)) / Float(backgroundReadingCount)
        settings.tuner.updateThreshold(newThreshold: backgroundMeanAmplitude)
    }
    
    func startTuner() {
        self.settings.tuner.delegate = self
        self.settings.tuner.start()
        self.isOn = true
    }
}


struct BackgroundFilter_Previews: PreviewProvider {
    static var previews: some View {
        // Example with sample SongMetadata
        BackgroundFilter(rootIsActive: .constant(false), songMetadata: SongMetadata(songId: -1, name: "", artist: "", resourceUrl: "", year: -1, level: -1, topScore: -1, highScore: -1, highScoreId: -1, deleted: false, rank: ""), tempo: 100, timeSig: (4,4), showPrevious: true, measures: [MeasureMetadata()]).previewLayout(.fixed(width: 896, height: 414))
    }
}
