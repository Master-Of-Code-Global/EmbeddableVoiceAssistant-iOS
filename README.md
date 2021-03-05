# EmbeddableVoiceAssistant
Embeddable Voice Assistant  is  a SwiftUI widget for mobile apps. It can communicate with [Microsoft Azure Bot](https://dev.botframework.com) via [Direct Line](https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-directline?view=azure-bot-service-4.0) with voice, text  and [Adaptive Cards](https://adaptivecards.io)  UI interface 
Assistant has a demo basic flow with sharing weather forecast, news and jokes, and demonstrates the main Voice Assistant possibilities.  But it is possible to connect any other  Bot Framework based bot with or without Adaptive Cards. Voice Synthesizing impelemented using [Cognitive Services Speech Devices SDK](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/get-speech-devices-sdk)

## Requirements
It works on iOS 14.0 and later.

## Installation
To add the EmbeddableVoiceAssistant dependency to your Xcode project:
1. Select **File > Swift Packages > Add Package Dependency…**
1. Enter `https://github.com/Master-Of-Code-Global/EmbeddableVoiceAssistant-iOS` into the package repository URL text field
1. Link **EmbeddableVoiceAssistant** to your application target

For more details see [Apple documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Usage

The recognizing and synthesizing of voice require the [Cognitive Services Speech Devices SDK](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/get-speech-devices-sdk). Register your Speech resource at [Asure portal](https://portal.azure.com/#create/hub) and look for "SUBSCRIPTION_KEY" and "REGION" or open [existing resource](https://portal.azure.com/#home) with "Cognitive Services" type, select Keys and Endpoints under RESOURCE MANAGEMENT, and use any key as "subscriptionKey" parameter and "Location" as "region" parameter.

Add the following class to implement recognizing functionality:

```swift
import EmbeddableVoiceAssistant

class AzureSpeechRecognizer: SpeechRecognizer {
    var speechRecognizer: SPXSpeechRecognizer?

    public init() {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: "SUBSCRIPTION_KEY", region: "REGION")
            speechConfig?.speechRecognitionLanguage = "en-US"

            let audioConfig = SPXAudioConfiguration()

            try self.speechRecognizer = SPXSpeechRecognizer(speechConfiguration: speechConfig!,
                                                            audioConfiguration: audioConfig)
        } catch {
            speechRecognizer = nil
        }
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
```

Also, for text synthesizing add another class:

```swift
import EmbeddableVoiceAssistant

class AzureSpeechSynthesizer: SpeechSynthesizer {
    var speechSynthesizer: SPXSpeechSynthesizer?

    public init() {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: "SUBSCRIPTION_KEY", region: "REGION")
            try self.speechSynthesizer = SPXSpeechSynthesizer(speechConfig!)
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
            if (try? self.speechSynthesizer?.speakText(text)) != nil {
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
```

The communication with bot is done via Direct Line channel. You can find "YOUR_TOKEN" of your bot [there](https://portal.azure.com/#home). 
Open a resource with type Bot Channels Registration, select Settings -> Channels -> Direct Line -> Edit. Put one Secret key to "secretToken" parameter for connecting with your bot.

```swift
import EmbeddableVoiceAssistant

let botConfiguration = BotConfiguration(secretToken: "YOUR_TOKEN",
                                        logLevel: .critical,
                                        speechRecognizer: AzureSpeechRecognizer(),
                                        speechSynthesizer: AzureSpeechSynthesizer())

let botAssistant = BotAssistant(botConfiguration)
let assistantView = AssistantView(botAssistant)
```

Show assistantView to communicate with bot.

## Customization

File **Colors.swift** contains set of the colors that is used in AssistantView. Any color can be overriden:
```swift
Color.requestBackground = .yellow
```

## Example
Check the project in Example directory.
1. Run `pod install` in project directory to install dependencies.
1. Open `VoiceAssistant.xcworkspace` and build the project.

## License
EmbeddableVoiceAssistant is available under the MIT license. See the [LICENSE](/LICENSE) file for more info.
