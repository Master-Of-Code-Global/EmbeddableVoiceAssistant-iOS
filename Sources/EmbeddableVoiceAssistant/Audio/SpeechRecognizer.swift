//
//  SpeechRecognizer.swift
//  
//
//  Created by Andrii Horishnii on 26.02.2021.
//

import Foundation

public struct SpeechRecognizerionResult {
    let text: String?
    let offset: UInt64
    
    public init(text: String?, offset: UInt64) {
        self.text = text
        self.offset = offset
    }
}

public protocol SpeechRecognizer {
    func startContinuousRecognition(_ handler: @escaping (SpeechRecognizerionResult) -> Void) -> Bool
    func stopContinuousRecognition() -> Bool
}
