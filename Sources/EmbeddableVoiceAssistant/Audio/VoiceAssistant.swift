//
//  VoiceAssistant.swift
//  VAssistant
//
//  Created by Aleksandr on 17.12.2020.
//

import SwiftUI
import DirectLine
import Combine
import AdaptiveCardUI

public protocol SpeechToTextService: class {
    var serviceState: ServiceState { get set }
    func startListening(resultHandler: @escaping (_ text: String, _ isNew: Bool) -> Void,
                        measurementHandler: @escaping (_ array: [Float]) -> Void)
    func stopListening()
    func synthesize(_ text: String,
                    onComplete: @escaping () -> Void)
    func stopSynthesize()
    func useVoiceName(_ name: String)
}

open class VoiceAssistant: ObservableObject {

    public var speechToText: SpeechToTextService?
    public var voiceLevel = Measurement()
    public var serviceState = ServiceState()
    private var recognizingResult = [String]()

    init(speechRecognizer: SpeechRecognizer?,
         speechSynthesizer: SpeechSynthesizer?) {
        speechToText = AzureService.init(speechRecognizer: speechRecognizer,
                                         speechSynthesizer: speechSynthesizer)
        if let state = speechToText?.serviceState {
            self.serviceState = state
        }
    }

    public func startListening(recognizeHandler: @escaping (_ text: String) -> Void) {
        recognizingResult.removeAll()
        speechToText?.startListening(resultHandler: { [unowned self] (text, isNew) in

            if recognizingResult.last != nil {
                if isNew {
                    recognizingResult.append(text)
                } else {
                    recognizingResult.removeLast()
                    recognizingResult.append(text)
                }
            } else {
                recognizingResult.append(text)
            }
            recognizeHandler(recognizingResult.joined(separator: " "))
        }, measurementHandler: { (measurements) in
            self.handleMeasurementArray(measurements)
        })
    }

    public func stopListening() {
        speechToText?.stopListening()
        resetRecognizingMessage()
    }

    public func resetRecognizingMessage() {
        recognizingResult.removeAll()
    }

    public func synthesize(_ text: String,
                           onComplete: @escaping () -> Void) {
        stopSynthesize()
        stopListening()
        speechToText?.synthesize(text, onComplete: onComplete)
    }

    public func stopSynthesize() {
        speechToText?.stopSynthesize()
    }

    func handleMeasurementArray(_ measurements: [Float]) {
        let level = min((fabsf(max(measurements.last ?? -140, -140) + 140))/5, 1)
        DispatchQueue.main.async {
            self.voiceLevel.value = level
        }
    }

}
