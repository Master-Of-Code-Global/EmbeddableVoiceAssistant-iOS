//
//  Measurements.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 05.01.2021.
//

import SwiftUI
import Combine

public class Measurement: ObservableObject {
    @Published var value: Float = 0

    func coefficient(_ isListening: Bool = false) -> CGFloat {
        if value < 0.01 || !isListening {
            return CGFloat(0)
        }

        let displayValue = value * 40 + 60
        return CGFloat(displayValue/100)
    }
}
