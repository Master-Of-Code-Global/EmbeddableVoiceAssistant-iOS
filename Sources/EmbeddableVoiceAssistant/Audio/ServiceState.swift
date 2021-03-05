//
//  ServiceState.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 12.01.2021.
//

import SwiftUI
import Combine

public class ServiceState: ObservableObject {
    @Published var isListening: Bool = false
    @Published var isAvailable: Bool = false
    @Published var isSpeaking: Bool = false
}
