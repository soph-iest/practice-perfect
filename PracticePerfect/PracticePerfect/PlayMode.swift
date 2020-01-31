//
//  PlayMode.swift
//  Practice Perfect
//
//  Created by Abigail Chen on 11/3/19.
//  Copyright © 2019 CS98 Practice Perfect. All rights reserved.
//
import SwiftUI

// Get screen dimensions
let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = CGFloat(screenSize.width)
let screenHeight = CGFloat(screenSize.height)

//offsets from center to draw staff lines
let screenDivisions : CGFloat = 20
let offsets : [CGFloat] = [screenWidth/screenDivisions,screenWidth/screenDivisions * 2, 0, screenWidth/(-screenDivisions), screenWidth/(-screenDivisions) * 2]

//Currently loads local file to String
func loadXML2String(fileName : String, fileExtension: String) -> String {
    if let filepath = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
        do {
            let contents = try String(contentsOfFile: filepath)
            print(contents)
            return(contents)
        } catch {
            return "file contents could not be loaded"
        }
    } else {
        return "file not found"
    }
}

//***TEMPORARILY HOT CODED TO LOCAL FILE APRES***
var musicXMLToParseFromFile: String = loadXML2String(fileName: "apres", fileExtension: "musicxml")

// Posts new score to API
// Posting guidance: https://stackoverflow.com/a/58804263
func postNewScore(songId: Int, score: Int) -> () {
    // TO DO: Add user ID as non-hard-coded value
    let params: [String: String] = ["song": String(songId), "user": "1", "score": String(score)]
    let scoreUrl = URL(string: "https://practiceperfect.appspot.com/scores")!
    let scoreSession = URLSession.shared
    var scoreRequest = URLRequest(url: scoreUrl)
    scoreRequest.httpMethod = "POST"
    scoreRequest.httpBody = try? JSONSerialization.data(withJSONObject: params)
    scoreRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let semaphore = DispatchSemaphore(value: 0)
    let task = scoreSession.dataTask(with: scoreRequest) { data, response, error in
        // TO DO: Error handling with response, currently just returns 200 which is what you would expect
        print(response!)
        semaphore.signal()
    }
    task.resume()

    // Wait for the songs to be retrieved before displaying all of them
    _ = semaphore.wait(wallTimeout: .distantFuture)
}

// Posts score update to API
// Posting guidance: https://stackoverflow.com/a/58804263
func postScoreUpdate(scoreId: Int, score: Int) -> () {
    // TO DO: Params from results passed into function - hard-coded right now
    let params: [String: String] = ["score": String(score)]
    let scoreUrl = URL(string: "https://practiceperfect.appspot.com/scores/" + String(scoreId))!
    let scoreSession = URLSession.shared
    var scoreRequest = URLRequest(url: scoreUrl)
    scoreRequest.httpMethod = "POST"
    scoreRequest.httpBody = try? JSONSerialization.data(withJSONObject: params)
    scoreRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let semaphore = DispatchSemaphore(value: 0)
    let task = scoreSession.dataTask(with: scoreRequest) { data, response, error in
        // TO DO: Error handling with response, currently just returns 200 which is what you would expect
        print(response!)
        semaphore.signal()
    }
    task.resume()

    // Wait for the songs to be retrieved before displaying all of them
    _ = semaphore.wait(wallTimeout: .distantFuture)
}

// Test data - to be removed when parsing XML is done
let note1 = NoteMetadata(step: "C", duration: 2, type: "half")
let note2 = NoteMetadata(step: "D", duration: 2, type: "half")
let note3 = NoteMetadata(step: "E", duration: 3, type: "half", dot: true)
let note4 = NoteMetadata(step: "F", duration: 1, type: "quarter")
let note5 = NoteMetadata(step: "G", duration: 1.5, type: "quarter", dot: true)
let note6 = NoteMetadata(step: "A", duration: 0.5, type: "eighth")
let note7 = NoteMetadata(step: "B", duration: 1.5, type: "quarter", dot: true)
let note8 = NoteMetadata(step: "C", duration: 0.5, type: "eighth")
let note9 = NoteMetadata(step: "C", duration: 0.5, type: "16th")
let note10 = NoteMetadata(step: "B", duration: 0.5, type: "16th")
let note11 = NoteMetadata(step: "A", duration: 0.5, type: "16th")
let note12 = NoteMetadata(step: "G", duration: 0.5, type: "16th")
let note13 = NoteMetadata(step: "F", duration: 0.5, type: "16th")
let note14 = NoteMetadata(step: "E", duration: 0.5, type: "16th")
let note15 = NoteMetadata(step: "D", duration: 0.5, type: "16th")
let note16 = NoteMetadata(step: "C", duration: 0.5, type: "16th")

var testMeasures = [MeasureMetadata(measureNumber: 1, notes: [note1, note2], clef: "G", fifths: 0, mode: "major"),
                    MeasureMetadata(measureNumber: 2, notes: [note3, note4], clef: "G", fifths: 0, mode: "major"),
                    MeasureMetadata(measureNumber: 3, notes: [note5, note6, note7, note8], clef: "G", fifths: 0, mode: "major"),
                    MeasureMetadata(measureNumber: 3, notes: [note9, note10, note11, note12, note13, note14, note15, note16], clef: "G", fifths: 0, mode: "major")]

// Streak multiplier values for streaks of length 0, 10, 25, and 50 (respectively)
let streakMultValues: Array<Float> = [1, 1.2, 1.5, 2]
let streakIncreases: Array<Float> = [10, 25, 50]

// For animation
let scrollLength = Float(400)

struct PlayMode: View, TunerDelegate {
    // Song metadata passed from song selection - used to retrieve music data from backed through API
    var songMetadata: SongMetadata
    var tempo: Int
    var timeSig: (Int, Int)
    
    // Tuner variables
    @State var tuner = Tuner()
    @State var cents = 0.0
    @State var note = Note(Note.Name.c, Note.Accidental.natural)
    @State var isOn = true
    
    // Tempo variables
    @State var totalElapsedBeats: Float = 0
    @State var endOfCurrentNoteBeats: Float = testMeasures[0].notes[0].duration
    
    // Countdown variables
    @State var showCountdown = true
    let beats = 4
    
    //  Scoring variables
    @State var currBeatNotes: [Note] = [] // For all notes in current beat
    @State var runningScore: Float = 0
    @State var streakCount: Int = 0
    @State var streakValuesIndex: Int = 0
    @State var streakIncreaseIndex: Int = 0
    @State var totalNotesPlayed: Int = 0
    @State var missCount: Int = 0
    @State var goodCount: Int = 0
    @State var perfectCount: Int = 0
    
    // Note display variables
    @State var barDist = screenWidth/screenDivisions/2
    @State var currBar = 0
    @State var measures: [MeasureMetadata] = testMeasures
    @State var measureIndex = 0
    @State var beatIndex = 0
    
    // File retrieval methods adapted from:
    // https://www.raywenderlich.com/3244963-urlsession-tutorial-getting-started
    private func getXML() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: songMetadata.resourceUrl) {
            guard let url = urlComponents.url else {
                return
            }
            
            dataTask = downloadSession.dataTask(with: url) { (data, response, error) in
                defer {
                    self.dataTask = nil
                }

                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data, let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.XMLString = String(data: data, encoding: .utf8) ?? ""
                    print(self.XMLString)
                    print(self.songMetadata.resourceUrl)
                }
            }
            dataTask?.resume()
        }
    }
    
    // XML Retrieval
    @State var downloadSession = URLSession(configuration: .default)
    @State var dataTask: URLSessionDataTask?
    @State var errorMessage = ""
    @State var results = ""
    @State var XMLString = ""
    
    var body: some View {
        ZStack {
            mainGradient
        
            VStack{
                Spacer()

                HStack {
                    VStack {
                        if (displayNote(note: note) == measures[measureIndex].notes[beatIndex].step) {
                            Text(displayNote(note: note))
                            .foregroundColor(.green)
                            .modifier(NoteNameStyle())
                            .frame(minWidth: 175, maxWidth: 175)
                        } else if (displayNote(note: note.halfStepUp) == measures[measureIndex].notes[beatIndex].step) {
                            Text(displayNote(note: note))
                            .foregroundColor(.yellow)
                            .modifier(NoteNameStyle())
                            .frame(minWidth: 175, maxWidth: 175)
                        } else if (displayNote(note: note.halfStepDown) == measures[measureIndex].notes[beatIndex].step) {
                            Text(displayNote(note: note))
                            .foregroundColor(.yellow)
                            .modifier(NoteNameStyle())
                            .frame(minWidth: 175, maxWidth: 175)
                        } else if (displayNote(note: note.wholeStepUp) == measures[measureIndex].notes[beatIndex].step) {
                            Text(displayNote(note: note))
                            .foregroundColor(.yellow)
                            .modifier(NoteNameStyle())
                            .frame(minWidth: 175, maxWidth: 175)
                        } else if (displayNote(note: note.wholeStepDown) == measures[measureIndex].notes[beatIndex].step) {
                            Text(displayNote(note: note))
                            .foregroundColor(.yellow)
                            .modifier(NoteNameStyle())
                            .frame(minWidth: 175, maxWidth: 175)
                        } else {
                            Text(displayNote(note: note))
                            .foregroundColor(.red)
                            .modifier(NoteNameStyle())
                            .frame(minWidth: 175, maxWidth: 175)
                        }
                        
                        if cents > 0 {
                            Text("\(roundToFive(num: cents)) cents sharp")
                        } else if cents < 0 {
                            Text("\(roundToFive(num: abs(cents))) cents flat")
                        } else {
                            Text("In tune!")
                        }
                        Text(String(Int(totalElapsedBeats) % timeSig.0 + 1))
                            .font(Font.system(size:64).weight(.bold))
                    }
                        .font(Font.system(size: 16).weight(.bold))

                    Spacer()
                    
                    ZStack {
                        // draws staff
                        VStack {
                            ForEach(0 ..< 5) { index in
                                Rectangle()
                                    .frame(width: 500.0, height: 1.0)
                                    .padding(.bottom, self.barDist)
                                    .padding(.top, 0)
                            }
                        }

                        HStack {
                            if self.measures[self.currBar].clef == "G" {
                                Image("g_clef")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: self.barDist * 7)
                            } else if self.measures[self.currBar].clef == "C" {
                                Image("c_clef")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: self.barDist * 5)
                                    .offset(y: CGFloat(-75 + self.barDist + 10))
                            } else if self.measures[self.currBar].clef == "F" {
                                Image("f_clef")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: self.barDist * 5)
                                    .offset(y: CGFloat(-54 + self.barDist + 10))
                            }
                            
                            self.drawKey(fifths: self.measures[self.currBar].fifths)
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 10, height: 200)
                                    .offset(y: CGFloat(-50 / 4))
                                
                                if (self.currBar < self.measures.count - 2) {
                                    drawMeasure(msr1: self.currBar, msr2: self.currBar + 1, msr3: self.currBar + 2)
                                } else if (self.currBar < self.measures.count - 1) {
                                    drawMeasure(msr1: self.currBar, msr2: self.currBar + 1, msr3: 0)
                                } else {
                                    drawMeasure(msr1: self.currBar, msr2: 0, msr3: 1)
                                }
                            }
                            .padding(.leading, 50)
                            
                            Spacer()
                        }
                            .offset(x: 50)
                    }

                    Spacer()
                }
                
                Spacer()
                
                HStack(spacing: 50) {
                    if isOn {
                        Button(action: {
                            self.tuner.stop()
                            self.isOn = false
                        }) {
                            Text("Pause")
                        }
                             .modifier(MenuButtonStyle())
                        .frame(width: 125)
                    } else {
                        Button(action: {
                            self.startTuner()
                        }) {
                            Text("Resume")
                        }
                             .modifier(MenuButtonStyle())
                        .frame(width: 125)
                    }
                                        
                    Text("Score:")
                        .font(Font.system(size: 64).weight(.bold))
                    Text(String(Int(runningScore)))
                        .font(Font.system(size: 64).weight(.bold))
                        .frame(width: 150)
                                        
                    NavigationLink(destination: ResultsPage(scoreMetadata: ScoreMetadata(newScore: Int(self.runningScore), inTuneCount: 0, inTempoCount: 0, perfectCount: self.perfectCount, goodCount: self.goodCount, missCount: self.missCount, totalCount: self.totalNotesPlayed), songMetadata: songMetadata)) {
                        Text("Results")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        // TO DO: Right now, sends new high score to server when pause button is pressed. This will need to be updated
                        self.tuner.stop()
                        // If highScoreId of -1, i.e. no existing score, then create; otherwise update
                        if self.songMetadata.highScoreId == -1 {
                            postNewScore(songId: self.songMetadata.songId, score: Int(self.runningScore))
                        } else {
                            if (Int(self.runningScore) > self.songMetadata.highScore) {
                                postScoreUpdate(scoreId: self.songMetadata.highScoreId, score: Int(self.runningScore))
                            }
                        }
                    })
                        .modifier(MenuButtonStyle())
                        .frame(width: 125)
                }
                .padding(.bottom, 20)
            }
            .blur(radius: showCountdown ? 20 : 0)
            
            if showCountdown {
                Countdown(tempo: self.tempo, beats: self.beats, showCountdown: self.$showCountdown, callback: startTuner)
            }
        }
        .navigationBarTitle("You are playing: " + songMetadata.name)
        .onAppear {
            self.getXML()
        }
        .onDisappear(perform: self.tuner.stop)
    }
    
    // If correct note, then 10 points; if one half step away, then 5 points; if one whole step away, then 3 points; increase streak count for target, neutral for half step off, reset for whole note or worse
    func updateScore(value: Note) {
        totalNotesPlayed += 1
        switch measures[measureIndex].notes[beatIndex].step {
        case displayNote(note: value):
            perfectCount += 1
            streakCount += 1
            if streakIncreases.contains(Float(streakCount)) {
                streakValuesIndex += 1
            }
            runningScore += (10 * streakMultValues[streakValuesIndex])
        case displayNote(note: value.halfStepUp), displayNote(note: value.halfStepDown):
            goodCount += 1
            runningScore += (5 * streakMultValues[streakValuesIndex])
        case displayNote(note: value.wholeStepUp), displayNote(note: value.wholeStepDown):
            goodCount += 1
            streakCount = 0
            streakValuesIndex = 0
            runningScore += 3
        default:
            missCount += 1
            streakCount = 0
            streakValuesIndex = 0
        }
    }

    // Updates current note information from microphone
    func tunerDidTick(pitch: Pitch, frequency: Double, beatCount: Int, change: Bool) {
        // Convert beatCount to seconds by multiplying by sampling rate, then to minutes by dividing by 60. Then multiply by tempo (bpm) to get tempo count
        let newElapsedBeats: Float = Float(beatCount) * Float(0.05) / Float(60) * Float(tempo)
        
        // If still on current note, add pitch reading to array
        if newElapsedBeats <= endOfCurrentNoteBeats {
            currBeatNotes.append(pitch.note)
        }
        // If new beat, calculate score and empty list for next beat
        else {
            // Frequency calculation algorithm from: https://stackoverflow.com/questions/38416347/getting-the-most-frequent-value-of-an-array
            
            // Create dictionary to map value to count and get most frequent note
            var counts = [Note: Int]()
            currBeatNotes.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
            let (value, _) = counts.max(by: {$0.1 < $1.1}) ?? (Note(Note.Name(rawValue: 0)!,Note.Accidental(rawValue: 0)!), 0)
            
            updateScore(value: value)
            
            // Empty current beat note values array for next beat
            currBeatNotes = []
            
            // If on last beat of current measure, go to first beat
            if beatIndex == measures[measureIndex].notes.count - 1 {
                beatIndex = 0
                // If finishing last measure, go back to first measure
                if measureIndex == measures.count - 1 {
                    measureIndex = 0
                } else {
                    measureIndex += 1
                }
            } else {
                beatIndex += 1
            }
                        
            endOfCurrentNoteBeats = endOfCurrentNoteBeats + measures[measureIndex].notes[beatIndex].duration
        }
        
        // Keep track of current bar
        if Int(newElapsedBeats) > Int(self.totalElapsedBeats) && Int(newElapsedBeats) % timeSig.0 == 0 &&
           Int(newElapsedBeats) != 0 {
            self.currBar += 1
        }
        
        // temp safety
        if self.currBar >= testMeasures.count {
            self.currBar = 0
        }
        
        // Update tempo count
        self.totalElapsedBeats = newElapsedBeats
        
        // If exceeded tuner threshold for new note, update the new note
        if change {
            self.note = pitch.note
            self.cents = calulateCents(userFrequency: frequency, noteFrequency: pitch.frequency)
        }
    }
    
    func startTuner() {
        self.tuner.delegate = self
        self.tuner.start()
        self.isOn = true
    }
    
    func roundToFive(num: Double) -> Int {
        Int(5 * round(num/5))
    }
    
    func drawKey(fifths: Int) -> some View {
        let sharpOrder = ["F", "C", "G", "D", "A", "E", "B"]
        return Group {
            if fifths > 0 {
                ForEach(0 ..< fifths, id: \.self) { index in
                    Text("♯").modifier(KeyStyle(offset: self.calcNoteOffset(note: sharpOrder[index])))
                }
            } else if fifths < 0 {
                ForEach((7 + fifths ..< 7).reversed(), id: \.self) { index in
                    Text("♭").modifier(KeyStyle(offset: self.calcNoteOffset(note: sharpOrder[index])))
                }
            }
        }
    }
    
    func calcOpacity(scrollOffset: Float) -> Double {
        var opacity: Double = 0
        if scrollOffset > scrollLength + 50 {
            opacity = 0
        } else if scrollOffset > scrollLength {
            opacity = Double(1) - Double((scrollOffset - 300) / 50)
        } else if scrollOffset >= 0 {
            opacity = 1
        } else if scrollOffset >= -50 {
            opacity = Double(1) - Double(scrollOffset / -50)
        }
        
        return opacity
    }
    
    func drawNote(note: NoteMetadata, barIndex: Int, barNumber: Int) -> some View {
        let offset = self.calcNoteOffset(note: note.step)
         
        // Get offset between each pair of notes
        let index = self.measures[barIndex].notes.firstIndex(of: note)
        var beatOffset: Float = 0
        if index! > 0 {
            for i in 1...index!{
                beatOffset += self.measures[barIndex].notes[i - 1].duration
            }
        }
              
        // Calculate x position of note
        let barBeatDiv: Float = scrollLength / Float(self.timeSig.0)
        let beat = Int(self.totalElapsedBeats) % self.timeSig.0 + 1
        let beatDiff = self.totalElapsedBeats - Float(Int(self.totalElapsedBeats))
        let scrollOffset = barBeatDiv + (barBeatDiv * Float(beatOffset)) - Float(barBeatDiv * (Float(beat) + beatDiff)) + (Float(barNumber) * scrollLength)
        
        let opacity = calcOpacity(scrollOffset: scrollOffset)
        
        let facingUp = offset > Int(self.barDist + 10) * 2
        
        return Group {
            if note.type == "16th" {
                Circle()
                    .frame(width: 34.0, height: 34.0)
                    .modifier(NoteStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity))
                Rectangle()
                    .modifier(TailStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp))
                Rectangle()
                    .modifier(FlagStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp, position: 0))
                Rectangle()
                    .modifier(FlagStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp, position: 1))
            }
            else if note.type == "eighth" {
                Circle()
                    .frame(width: 34.0, height: 34.0)
                    .modifier(NoteStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity))
                Rectangle()
                    .modifier(TailStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp))
                Rectangle()
                    .modifier(FlagStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp, position: 0))
            }
            else if note.type == "quarter" {
                Circle()
                    .frame(width: 34.0, height: 34.0)
                    .modifier(NoteStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity))
                Rectangle()
                    .modifier(TailStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp))
            }
            else if note.type == "half" {
                Circle()
                    .stroke(Color.black, lineWidth: 4)
                    .modifier(NoteStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity))
                Rectangle()
                    .modifier(TailStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp))
            }
            else if note.type == "whole" {
                Circle()
                    .stroke(Color.black, lineWidth: 4)
                    .modifier(NoteStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity))
            }
            else {
                Circle()
                    .modifier(NoteStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity))
                Rectangle()
                    .modifier(TailStyle(offset: offset, scrollOffset: scrollOffset, opacity: opacity, facingUp: facingUp))
            }
            
            if note.dot {
                Circle()
                    .modifier(NoteDotStyle(offset: offset, scrollOffset: 40 + scrollOffset, opacity: opacity))
            }
        }
    }
    
    func drawMeasure(msr1: Int, msr2: Int, msr3: Int) -> some View {
        return Group {
            ForEach(self.measures[msr1].notes) { note in
                self.drawNote(note: note, barIndex: msr1, barNumber: 0)
            }
            self.drawMeasureBar(barNumber: 0)
            ForEach(self.measures[msr2].notes) { note in
                self.drawNote(note: note, barIndex: msr2, barNumber: 1)
            }
            self.drawMeasureBar(barNumber: 1)
            ForEach(self.measures[msr3].notes) { note in
                self.drawNote(note: note, barIndex: msr3, barNumber: 2)
            }
        }
    }
    
    func drawMeasureBar(barNumber: Int) -> some View {
        let barBeatDiv: Float = scrollLength / Float(self.timeSig.0)
        let beat = Int(self.totalElapsedBeats) % self.timeSig.0 + 1
        let beatDiff = self.totalElapsedBeats - Float(Int(self.totalElapsedBeats))
        let scrollOffset = scrollLength + (barBeatDiv / 2) - Float(barBeatDiv * (Float(beat) + beatDiff)) + (Float(barNumber) * scrollLength)
        
        let opacity = calcOpacity(scrollOffset: scrollOffset)
        
        return Group {
            Rectangle()
                .fill(Color.black)
                .frame(width: 5, height: 150)
                .offset(x: CGFloat(scrollOffset), y: CGFloat(-50 / 4))
                .opacity(opacity)
        }
    }
    
    func calcNoteOffset(note: String) -> Int {
        var offset = self.barDist + 10
        switch note {
            case "F":
                offset *= 0
            case "E":
                offset *= 0.5
            case "D":
                offset *= 1
            case "C":
                offset *= 1.5
            case "B":
                offset *= 2
            case "A":
                offset *= 2.5
            case "G":
                offset *= 3
            default:
                offset *= 1.5
        }
        
        return Int(offset)
    }
}



struct PlayMode_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with example song metadata
        PlayMode(songMetadata: SongMetadata(songId: -1, name: "", artist: "", resourceUrl: "", year: -1, level: -1, topScore: -1, highScore: -1, highScoreId: -1, deleted: false, rank: ""), tempo: 120, timeSig: (4, 4)).previewLayout(.fixed(width: 896, height: 414))
    }
}
