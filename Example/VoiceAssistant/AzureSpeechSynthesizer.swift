//
//  AzureSpeechSynthesizer.swift
//  VoiceAssistant
//
//  Created by Andrii Horishnii on 26.02.2021.
//

import EmbeddableVoiceAssistant

class AzureSpeechSynthesizer: SpeechSynthesizer {
    var speechSynthesizer: SPXSpeechSynthesizer?

    public init(subscriptionKey: String,
                region: String) {
        do {
            let speechConfig = try SPXSpeechConfiguration(subscription: subscriptionKey, region: region)
            try self.speechSynthesizer = SPXSpeechSynthesizer(speechConfig)
        } catch {
            speechSynthesizer = nil
        }
    }

    func useVoiceName(_ name: String) {
        if let properties = self.speechSynthesizer?.properties {
            properties.setPropertyTo?(name, by: .speechServiceConnectionSynthesisVocie)
        }
    }

    func startSynthesize(_ text: String, onComplete: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                if let result = try? self.speechSynthesizer?.speakText(text) {
                    if result.reason == SPXResultReason.canceled {
                        let details = try? SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
                        if let errorDetails = details?.errorDetails {
                            print("Synthesize error: \(errorDetails)")
                        }
                    }

                    DispatchQueue.main.async {
                        onComplete()
                    }
                }
        }
    }

    func stopSynthesize() -> Bool {
        do {
            try self.speechSynthesizer?.stopSpeaking()
        } catch {
            return false
        }
        return true
    }
}
