//
//  Tuner.swift
//  PracticePerfect
//
//  Created by Anna Matusewicz on 11/5/19.
//  Copyright © 2019 CS98PracticePerfect. All rights reserved.
//

import AudioKit
import Foundation

// Written following a tutorial found at:
// http://shinerightstudio.com/posts/ios-tuner-app-using-audiokit/
class Tuner {
    let mic: AKMicrophone
    let tracker: AKFrequencyTracker
    let silence: AKBooster
    let pollingInterval = 0.05
    var pollingTimer: Timer?
    var delegate: TunerDelegate?

    init() {
        do {
            // Configure settings of AVFoundation.
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement)
        } catch let error {
            print(error.localizedDescription)
        }

        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()!
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)

        AudioKit.output = silence
    }

    func start() {
        do {
            try AudioKit.start()
        } catch let error {
            print(error.localizedDescription)
        }

        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true, block: {_ in self.pollingTick()})
    }

    func stop() {
        do {
            try AudioKit.stop()
        } catch let error {
            print(error.localizedDescription)
        }

        if let t = pollingTimer {
            t.invalidate()
        }
        
    }

    private func pollingTick() {
        let frequency = Double(tracker.frequency)
        let pitch = Pitch.makePitchByFrequency(frequency)
        
        if let d = delegate {
            d.tunerDidTick(pitch: pitch, frequency: frequency)
        }
    }
}

protocol TunerDelegate {
    func tunerDidTick(pitch: Pitch, frequency: Double)
}
