//
//  SpeechFeedbackTip.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/29/26.
//

import SwiftUI
import TipKit

struct SpeechFeedbackTip: Tip {

    var title: Text {
        Text("Enable Speech Feedback")
    }

    var message: Text? {
        Text("Turn on spoken battery results in Settings for better accessibility and hands-free use. You can also enable haptic feedback to feel different classification results without looking at the screen.")
    }

    var image: Image? {
        Image(systemName: "speaker.wave.2.fill")
    }

    // ✅ Show only once, ever
    var options: [Option] {
        Tips.MaxDisplayCount(1)
    }
}
