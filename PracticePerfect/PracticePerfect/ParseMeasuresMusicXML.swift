//
//  ParseMeasuresMusicXML.swift
//  PracticePerfect
//
//  Created by Abigail Chen on 11/16/19.
//  Copyright © 2019 CS98PracticePerfect. All rights reserved.
//

import SwiftUI
import SWXMLHash

var measureMusicXML : String = "temp"

//initialize SWXMLHash object
let MeasureSWXML = SWXMLHash.config {
            config in
            config.shouldProcessLazily = false
}.parse(measureMusicXML)

//***rest parser code coming here***



struct ParseMeasuresMusicXML: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ParseMeasuresMusicXML_Previews: PreviewProvider {
    static var previews: some View {
        ParseMeasuresMusicXML().previewLayout(.fixed(width: 896, height: 414))
    }
}