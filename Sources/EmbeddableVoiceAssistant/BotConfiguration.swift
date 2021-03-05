//
//  BotConfiguration.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 24.02.2021.
//

import SwiftUI
import Logging

public struct BotConfiguration {
    /// Configuration values for the Microsoft Asure Bot.
    public let secretToken: String
    public let userID: String
    public let userName: String
    public let logLevel: Logger.Level

    /// Microsoft Asure Speech API.
    public let speechRecognizer: SpeechRecognizer?
    public let speechSynthesizer: SpeechSynthesizer?

    public init(
        secretToken: String,
        userID: String = userID(),
        userName: String = "Anonymous",
        logLevel: Logger.Level = .debug,
        speechRecognizer: SpeechRecognizer?,
        speechSynthesizer: SpeechSynthesizer?) {
        self.secretToken = secretToken
        self.userID = userID
        self.userName = userName
        self.logLevel = logLevel
        self.speechRecognizer = speechRecognizer
        self.speechSynthesizer = speechSynthesizer
    }

    init() {
        self.init(secretToken: "",
                  speechRecognizer: nil,
                  speechSynthesizer: nil)
    }
}

extension BotConfiguration {
    public static func userID() -> String {
        if let userID = UserDefaults.standard.string(forKey: "conversationUserID") {
            return userID
        }

        let userID = UUID().uuidString
        UserDefaults.standard.setValue(userID, forKey: "conversationUserID")
        UserDefaults.standard.synchronize()
        return userID
    }
}
