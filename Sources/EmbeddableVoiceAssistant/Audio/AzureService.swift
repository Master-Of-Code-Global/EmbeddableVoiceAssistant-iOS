//
//  AzureService.swift
//  VAssistant
//
//  Created by Aleksandr on 17.12.2020.
//

import Foundation
import Speech
import Accelerate
import SwiftUI

public class AzureService: SpeechToTextService {
    var speechRecognizer: SpeechRecognizer?
    var speechSynthesizer: SpeechSynthesizer?
    public var serviceState: ServiceState
    var audioEngine: AVAudioEngine?
    private var measurementHandler: ((_ array: [Float]) -> Void)?
    private var offset: UInt64?

    public init(speechRecognizer: SpeechRecognizer?,
                speechSynthesizer: SpeechSynthesizer?) {
        self.speechRecognizer = speechRecognizer
        self.speechSynthesizer = speechSynthesizer
        serviceState = ServiceState()
        serviceState.isAvailable = speechRecognizer != nil || speechSynthesizer != nil
    }

    public func useVoiceName(_ name: String) {
        self.speechSynthesizer?.useVoiceName(name)
    }

    public func startListening(resultHandler: @escaping (_ text: String, _ isNew: Bool) -> Void,
                               measurementHandler: @escaping (_ array: [Float]) -> Void) {
        guard serviceState.isListening == false
        else {
            print("Listening is already started")
            return
        }

        self.measurementHandler = measurementHandler
        
        measureSoundLevel()
        
        let status = self.speechRecognizer?.startContinuousRecognition { [unowned self] result in
            DispatchQueue.main.async {
                if let recognitionResult = result.text {
                    var isNew = false
                    if result.offset > self.offset ?? 0 {
                        self.offset = result.offset
                        isNew = true
                    }
                    resultHandler(recognitionResult, isNew)
                }
            }
        }
        
        serviceState.isListening = status ?? false
    }

    public func stopListening() {
        guard serviceState.isListening else {
            return
        }

        _ = self.speechRecognizer?.stopContinuousRecognition()
        audioEngine?.stop()
        audioEngine?.reset()
        serviceState.isListening = false
    }

    public func synthesize(_ text: String,
                           onComplete: @escaping () -> Void) {
        guard text.count > 0 else {
            return
        }

        serviceState.isSpeaking = true
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category != .soloAmbient {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setActive(false, options: [])
                try audioSession.setCategory(.soloAmbient,
                                             mode: .voicePrompt,
                                             options: [.duckOthers, .defaultToSpeaker])
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                // print("AsureService.synthesize audio error: \(error)")
            }
        }
        
        self.speechSynthesizer?.startSynthesize(text) { [weak self] in
            self?.serviceState.isSpeaking = false
            onComplete()
        }
    }

    public func stopSynthesize() {
        guard serviceState.isSpeaking else {
            return
        }

        do {
            _ = self.speechSynthesizer?.stopSynthesize()
            try AVAudioSession.sharedInstance().setActive(false, options: [])
            serviceState.isSpeaking = false
        } catch {
            serviceState.isSpeaking = false
            print("AsureService.stopSynthesize audio error: \(error)")
        }
    }

    func measureSoundLevel() {
        audioEngine?.stop()
        audioEngine?.reset()

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            print("Unable to create audio engine")
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false, options: [])
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("AsureService.measureSoundLevel audio error: \(error)")
        }
        let inputNode = audioEngine.inputNode

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
            guard let data = buffer.floatChannelData?[0] else {
                return
            }
            let sampleCount = UInt(buffer.frameLength)

            let dbData = UnsafeMutablePointer<Float>.allocate(capacity: Int(sampleCount))

            // take the absolute values to get amplitude
            vDSP_vabs(data, 1, dbData, 1, sampleCount)

            var zero: Float = 32000.0
            vDSP_vdbcon(dbData, 1, &zero, dbData, 1, sampleCount, 1)

            // clip to [noiseFloor, 0]
            var ceil: Float = 0.0
            var noiseFloor: Float = -140.0
            vDSP_vclip(dbData, 1, &noiseFloor, &ceil, dbData, 1, sampleCount)

            let samplesPerItem = Int(sampleCount)
            let itemsCount = Int(sampleCount)/samplesPerItem

            // downsample and average
            let filter = [Float](repeating: 1.0 / Float(samplesPerItem), count: Int(samplesPerItem))

            var downSampledData = [Float](repeating: 0.0, count: itemsCount)

            vDSP_desamp(dbData, vDSP_Stride(samplesPerItem), filter, &downSampledData,
                        vDSP_Length(itemsCount), vDSP_Length(samplesPerItem))

            self.measurementHandler?(downSampledData)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("AsureService.measureSoundLevel 2 audio error: \(error)")
        }
    }

}
