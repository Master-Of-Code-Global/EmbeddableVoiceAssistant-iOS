//
//  AssistantView.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 28.12.2020.
//

import SwiftUI
import AdaptiveCardUI
import AdaptiveCard

public struct AssistantView: View {
    let bot: BotAssistant
    @ObservedObject private var messages: Messages
    @ObservedObject private var serviceState: ServiceState
    @State private var isRecognizeMode = true
    @State private var isMenuExpanded = false

    public init(_ bot: BotAssistant) {
        self.bot = bot
        self.messages = bot.messages
        self.serviceState = bot.voiceAssistant.serviceState
    }

    public var body: some View {
        VStack(spacing: 0, content: {
            BarView {
                bot.clearHistory()
            }
            
            ConnectionIssueView(errorDescription: messages.connectionErrorDescription)

            ScrollView(.vertical) {
                ScrollViewReader { scrollView in
                    VStack {
                        ForEach(messages.list, id: \.self) { message in
                            rowView(message)
                        }
                    }
                    .onCollectedSizesChange(perform: { (_: [String: CGSize]) in
                        let index = messages.list.endIndex - 1
                        if index > 0 {
                            scrollView.scrollTo(messages.list[index])
                        }
                    })
                    .onChange(of: messages.list) { list in
                        let index = list.endIndex - 1
                        if index > 0 {
                            scrollView.scrollTo(messages.list[index])
                        }
                    }
                    .adaptiveCardConfiguration(adaptiveCardConfiguration())
                    .accentColor(.cardButtonColor)
                    .accentColor(.green)
                }
            }

            Spacer()

            if isMenuExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(messages.actions, id: \.self) { actionInfo in
                            CommandButton(action: {
                                isMenuExpanded.toggle()
                                bot.sendMessageToBot(actionInfo.displayValue())
                            }, text: actionInfo.displayValue())
                            .padding(.top, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            if isRecognizeMode {
                RecognizeBar(recognizeAction: self.recognize,
                             menuAction: self.showQuickCommands,
                             keyboardModeAction: {
                                bot.stopSynthesize()
                                isRecognizeMode = false
                             },
                             isListening: serviceState.isListening,
                             isMenuExpanded: self.$isMenuExpanded,
                             voiceLevel: bot.voiceAssistant.voiceLevel)
            } else {
                KeyboardBar(menuAction: self.showQuickCommands,
                            sendAction: self.sendCommand(_:),
                            recognizeModeAction: {
                                isRecognizeMode = true
                                recognize()
                            },
                            isMenuExpanded: self.$isMenuExpanded)
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification),
                   perform: willMoveBackground)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
                   perform: willMoveForeground)
        .onDisappear {
            bot.shutdown()
        }
    }
}

// MARK: - Event Handlers
extension AssistantView {
    func recognize() {
        bot.stopSynthesize()

        if serviceState.isListening {
            bot.voiceAssistant.stopListening()
        } else {
            bot.startListening()
        }
    }

    func showQuickCommands() {
        self.isMenuExpanded.toggle()
    }

    func sendCommand(_ text: String) {
        isRecognizeMode = true
        bot.sendMessageToBot(text)
    }

    func willMoveBackground(notification: Notification) {
        bot.moveToBackground()
    }

    func willMoveForeground(notification: Notification) {
        bot.moveToForeground()
    }
}

extension AssistantView {
    func rowView(_ message: MessageInfo) -> AnyView {
        switch message.type {
        case .temporaryRequest,
             .request,
             .recognizing:
            return AnyView(RequestRow(message: message,
                                      resetMessageAction: {
                                        bot.resetRecognizingMessages()
                                      }))
        case .response:
            return AnyView(ResponseRow(message: message,
                                       sendMessageAction: { (messageText) in
                                        bot.sendMessageToBot(messageText)
                                       }))
        case .card:
            return AnyView(CardUIRow(message: message).collectSize(tag: message.id))
        case .error:
            return AnyView(ErrorRow(message: message))
        case .waiting:
            return AnyView(WaitingRow())
        }
    }
}

extension AssistantView {
    private func adaptiveCardConfiguration() -> AdaptiveCardConfiguration {
        let containerStyleConfiguration = ContainerStyleConfiguration(
            default: ContainerConfiguration(
                backgroundColor: .defaultBackground,
                textColors: TextColorConfiguration(light: TextColorPair(default: .gray,
                                                                        subtle: .subtleText))))
        let spacingConfiguration = SpacingConfiguration(
            default: 4,
            small: 2,
            medium: 8,
            large: 16,
            extraLarge: 24,
            padding: 8
        )
        return AdaptiveCardConfiguration(actions: ActionSetConfiguration(),
                                         containerStyles: containerStyleConfiguration,
                                         imageSizes: ImageSizeConfiguration.default,
                                         factSet: FactSetConfiguration.default,
                                         fonts: FontTypeConfiguration.default,
                                         spacing: spacingConfiguration)
    }
}

struct AssistantView_Previews: PreviewProvider {
    static var previews: some View {
        let bot = BotAssistant(BotConfiguration())
        bot.messages.fillWithMockData()

        return AssistantView(bot)
    }
}
