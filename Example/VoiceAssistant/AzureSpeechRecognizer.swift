//
//  AzureSpeechRecognizer.swift
//  VoiceAssistant
//
//  Created by Andrii Horishnii on 26.02.2021.
//

import EmbeddableVoiceAssistant

class AzureSpeechRecognizer: SpeechRecognizer {
    private let subscriptionKey: String
    private let region: String
    private let language: String

    lazy var speechRecognizer: SPXSpeechRecognizer? = {
        let speechRecognizer: SPXSpeechRecognizer?
        do {
            let speechConfig = try SPXSpeechConfiguration(subscription: subscriptionKey, region: region)
            speechConfig.speechRecognitionLanguage = language

            let audioConfig = SPXAudioConfiguration()

            try speechRecognizer = SPXSpeechRecognizer(speechConfiguration: speechConfig,
                                                       audioConfiguration: audioConfig)
        } catch {
            speechRecognizer = nil
        }
        return speechRecognizer
    }()

    public init(subscriptionKey: String,
                region: String,
                language: String = "en-US") {
        self.subscriptionKey = subscriptionKey
        self.region = region
        self.language = language
    }

    func startContinuousRecognition(_ handler: @escaping (SpeechRecognizerionResult) -> Void) -> Bool {
        speechRecognizer?.addRecognizingEventHandler {_, evt in
            handler(SpeechRecognizerionResult(text: evt.result.text, offset: evt.result.offset))
        }
        do {
            try speechRecognizer?.startContinuousRecognition()
        } catch {
            return false
        }
        return true
    }

    func stopContinuousRecognition() -> Bool {
        do {
            try speechRecognizer?.stopContinuousRecognition()
        } catch {
            return false
        }
        return true
    }
}
