//
//  BotAssistant.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 28.01.2021.
//

import SwiftUI
import DirectLine
import Combine
import AdaptiveCardUI
import Reachability

open class BotAssistant: ObservableObject {
    public var messages = Messages()
    public var voiceAssistant: VoiceAssistant

    var directLine: BotConnection<DirectLine.Empty>?
    var myAccount: ChannelAccount?
    private var activityStream: BotConnection<DirectLine.Empty>.ActivityStream?

    var requestCancellable: AnyCancellable?
    var postRequestCancellable: AnyCancellable?
    var statusCancellable: AnyCancellable?

    var waitTimer: Timer?
    let maxUpdateInterval: TimeInterval = 2

    private var isSendingActivity = false
    private var allowSynthesize = true

    private var reachability = try! Reachability()

    public init(_ configuration: BotConfiguration) {
        let auth = Auth.secret(configuration.secretToken)
        directLine = BotConnection<DirectLine.Empty>(auth, logLevel: configuration.logLevel)
        myAccount = ChannelAccount(id: configuration.userID, name: configuration.userName)

        voiceAssistant = VoiceAssistant(speechRecognizer: configuration.speechRecognizer,
                                        speechSynthesizer: configuration.speechSynthesizer)

        ContentAttachment.register(AdaptiveCard.self, contentType: AdaptiveCard.contentType)

        activityStream = directLine?.getActivityStream()
        initActivityStream()
        initReachability()
        initChangeStatusHandler()
    }

    func moveToBackground() {
        requestCancellable?.cancel()
        statusCancellable?.cancel()
        
        stopSynthesize()
        voiceAssistant.stopListening()
        removeMessages(messageTypes: [.recognizing])

        reachability.stopNotifier()
        activityStream = nil
    }

    func moveToForeground() {
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        initActivityStream()
        initChangeStatusHandler()
    }

    func initReachability() {
        reachability.whenReachable = { [self] reachability in
            displayGeneralErrorMessage()
        }

        reachability.whenUnreachable = { [self] _ in
            displayGeneralErrorMessage("No internet connection")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    func initChangeStatusHandler() {
        statusCancellable = directLine?.state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (botConnectionState) in

                switch botConnectionState {
                case .ready(_):
                    self.displayGeneralErrorMessage()
                case .connectingFailed:
                    self.displayGeneralErrorMessage("No internet connection")
                default:
                    break
                }

                //print("botConnectionState: \(botConnectionState)")
            })
    }

    func initActivityStream() {
        requestCancellable = (activityStream ?? directLine?.getActivityStream())?
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error as BotConnectionError) = completion {
                    handleBotError(error)
                }
                directLine?.resetState()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                    activityStream = directLine?.getActivityStream()
                    initActivityStream()
                }
            }, receiveValue: { [unowned self] result in
                removeMessages(messageTypes: [.waiting, .temporaryRequest])
                let message = MessageInfo(activity: result)
                handleMessage(message, replyToId: result.replyToId)
            })
    }

    func handleMessage(_ message: MessageInfo, replyToId: String? = nil) {
        if messages.actions.isEmpty, message.type == .response {
            messages.actions.append(contentsOf: message.actionsInfo)
        }
        if let messageIndex = messages.list.firstIndex(where: { (currentMessage) -> Bool in
            currentMessage.id == message.id
        }) {
            messages.list[messageIndex] = message
        } else {
            insertMessage(to: &messages.list, message: message)

            if message.type == .request {
                messages.speechList.removeAll()
                removeMessages(messageTypes: [.temporaryRequest])
            }

            if let speak = message.speak, speak.count > 0, allowSynthesize, message.type != .error {
                messages.speechList.append(message)
                synthesizeMessages()
            }
        }
    }

    func insertMessage(to list: inout [MessageInfo], message: MessageInfo) {
        let positon = messagePosition(list: list, message: message)
        list.insert(message, at: positon)
    }

    func messagePosition(list: [MessageInfo], message: MessageInfo) -> Int {
        for (index, item) in list.reversed().enumerated() {
            let position = list.count - index
            guard let listId = item.activityId, let messageId = message.activityId else {
                return position
            }
            if listId < messageId {
                return position
            }
            if position == 1 {
                return 0
            }
        }
        return list.count
    }

    func handleBotError(_ error: BotConnectionError) {
        finishSendMessageToBot()

        var errorDescription: String?

        switch error {
        case .badArgument(let message):
            errorDescription = message
        case .failedToConnect(let message):
            errorDescription = message
        case .socketPing(_):
            displayGeneralErrorMessage("Socket connection error")
        default:
            errorDescription = nil
        }

        if let errorDescription = errorDescription {
            let errorInformation = MessageInfo(errorMessage: errorDescription)
            self.handleMessage(errorInformation)
        }
    }

    func displayGeneralErrorMessage(_ text: String? = nil) {
        if let text = text {
            if (messages.connectionErrorDescription == nil) {
                messages.connectionErrorDescription = text
            }
        } else {
            messages.connectionErrorDescription = nil
        }
    }

    public func startListening() {
        voiceAssistant.startListening { [unowned self] (text) in

            guard voiceAssistant.serviceState.isListening else {
                // Prevent updating list after stopListening
                return
            }

            let message = MessageInfo(type: .recognizing, text: text.appending(" ..."))
            if let recognizingMessage = messages.list.last, recognizingMessage.type == .recognizing,
               let recognizingIndex = messages.list.firstIndex(of: recognizingMessage) {
                messages.list[recognizingIndex] = message
            } else {
                messages.list.append(message)
            }

            waitForFinishInput()
        }
    }

    func waitForFinishInput() {
        waitTimer?.invalidate()
        waitTimer = Timer.scheduledTimer(withTimeInterval: maxUpdateInterval,
                                         repeats: false,
                                         block: { [unowned self] (_) in
                                            sendRecognizingMessageToBot()
                                         })
    }

    func sendRecognizingMessageToBot() {
        if let recognizingMessage = messages.list.last, recognizingMessage.type == .recognizing {
            let requestText = recognizingMessage.text.replacingOccurrences(of: " ...", with: "")
            sendMessageToBot(requestText)
        }
    }

    func sendMessageToBot(_ text: String) {
        guard isSendingActivity == false else {
            return
        }

        if isChangeVoiceCommand(text) {
            return
        }

        allowSynthesize = true
        isSendingActivity = true
        voiceAssistant.stopListening()
        resetRecognizingMessages()

        if let directLine = directLine, let myAccount = myAccount {
            print("SEND: \(text)")
            addSendingAndWaitingMessages(text)

            let message = MessageActivity(text: text, textFormat: .plain)
            let type = ActivityType.message(message)
            let activity = Activity<DirectLine.Empty>(type: type, from: myAccount)
            postRequestCancellable = directLine.postActivity(activity)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] completion in
                    isSendingActivity = false
                    switch completion {
                    case .failure(let error):
                        handleBotError(error)
                    case .finished:
                        finishSendMessageToBot()
                    }
                } receiveValue: { _ in
                }
        }
    }

    private func isChangeVoiceCommand(_ text: String) -> Bool {
        if text.hasPrefix("en-") {
            voiceAssistant.speechToText?.useVoiceName(text)
            handleMessage(MessageInfo(type: .response, text: "Using voice with name \(text)"))
            return true
        }

        return false
    }

    func removeMessages(messageTypes: [MessageType]) {
        messages.list.removeAll { (message) -> Bool in
            messageTypes.contains(message.type)
        }
    }

    func resetRecognizingMessages() {
        voiceAssistant.resetRecognizingMessage()

        removeMessages(messageTypes: [.recognizing])
    }

    func addSendingAndWaitingMessages(_ text: String) {
        removeMessages(messageTypes: [.waiting])

        messages.list.append(MessageInfo(type: .temporaryRequest, text: text))
        messages.list.append(MessageInfo(type: .waiting))
    }

    func finishSendMessageToBot() {
        removeMessages(messageTypes: [.waiting])
    }

    func clearHistory() {
        messages.list.removeAll()
    }

    func synthesizeMessages() {
        let voice = voiceAssistant
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let this = self else { return }

            guard voice.serviceState.isAvailable else {
                return
            }

            guard !voice.serviceState.isSpeaking else {
                return
            }
            
            let firstMessage = this.messages.speechList.min {
                guard let l = $0.activityId, let r = $1.activityId else { return true }
                return l < r
            }

            if let message = firstMessage, let speak = message.speak {
                this.messages.speechList.removeAll { $0.id == message.id }
                voice.synthesize(speak, onComplete: { [weak self] in
                    guard let this = self else { return }
                    this.synthesizeMessages()
                })
            }
        }
    }

    func stopSynthesize() {
        allowSynthesize = false
        messages.speechList.removeAll()
        voiceAssistant.stopSynthesize()
    }

    func shutdown() {
        stopSynthesize()
        voiceAssistant.stopListening()
        waitTimer?.invalidate()
    }
}
