//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 24.02.2021.
//

import Foundation

import SwiftUI
import Logging
import EmbeddableVoiceAssistant

struct ContentView: View {
    @State private var showModal: Bool = false

    var body: some View {
        NavigationView {
            List {
                Image("content")
                Image("content")
               Image("content")
            }
            .overlay(Button(action: {
                self.showModal = true
            }, label: {
                Image("assistant")
            }).sheet(isPresented: self.$showModal) {
                voiceAssistantView()
            }
            .padding(), alignment: .bottomTrailing)
            .navigationBarTitle("Screen title")
            .navigationBarItems(
                trailing:
                    Button(action: {}, label: {
                        Image("info")
                    })
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func voiceAssistantView() -> AssistantView {
        /// Direct Line secret key
        let secretToken = "YOUR_TOKEN"

        /// Asure Speech Cognitive Services
        let subscriptionKey = "SUBSCRIPTION_KEY"
        let region = "REGION"

        let speechRecognizer = AzureSpeechRecognizer(subscriptionKey: subscriptionKey,
                                                     region: region)
        let speechSynthesizer = AzureSpeechSynthesizer(subscriptionKey: subscriptionKey,
                                                       region: region)
        let botConfiguration = BotConfiguration(secretToken: secretToken,
                                                logLevel: .critical,
                                                speechRecognizer: speechRecognizer,
                                                speechSynthesizer: speechSynthesizer)

        let botAssistant = BotAssistant(botConfiguration)
        return AssistantView(botAssistant)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
