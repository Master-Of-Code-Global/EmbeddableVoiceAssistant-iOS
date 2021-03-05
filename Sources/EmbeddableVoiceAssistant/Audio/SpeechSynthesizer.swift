//
//  SpeechSynthesizer.swift
//  
//
//  Created by Andrii Horishnii on 26.02.2021.
//

import Foundation

public protocol SpeechSynthesizer {
    func useVoiceName(_ name: String)
    func startSynthesize(_ text: String, onComplete: @escaping () -> Void)
    func stopSynthesize() -> Bool
}
