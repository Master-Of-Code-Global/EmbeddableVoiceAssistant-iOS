//
//  MessageInformation.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 28.12.2020.
//

import SwiftUI
import Combine
import DirectLine
import AdaptiveCardUI

enum MessageType {
    case recognizing
    case temporaryRequest
    case request
    case response
    case card
    case error
    case waiting
}

// swiftlint:disable identifier_name
struct ActionInfo: Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String?
    var value: String

    func displayValue() -> String {
        title ?? value
    }
}

struct MessageInfo: Identifiable, Equatable, Hashable {
    let id: String
    let activityId: String?
    var type: MessageType
    var text: String
    var speak: String?
    var actionsInfo = [ActionInfo]()
    var adaptiveCards = [AdaptiveCard]()
    var attachmentLayout: AttachmentLayout?

    init(type: MessageType = .request,
         text: String = "",
         id: String = UUID().uuidString) {
        self.type = type
        self.text = text
        self.id = id
        self.activityId = nil
    }

    // swiftlint:disable cyclomatic_complexity
    init(activity: Activity<DirectLine.Empty>) {
        self.id = activity.id ?? UUID().uuidString
        self.activityId = activity.id

        switch activity.type {
        case let .message(messageActivity):
            self.text = messageActivity.text ?? ""
            self.speak = messageActivity.speak

            if let actions = messageActivity.suggestedActions?.actions {
                for action in actions {
                    switch action {
                    case .imBack(let cardActivity):
                        actionsInfo.append(ActionInfo(title: cardActivity.title,
                                                      value: cardActivity.value))
                    default:
                        print("Unknown suggested action type")
                    }
                }
            }

            for attachment in messageActivity.attachments {
                switch attachment {
                case .content(let contentAttachment):
                    if contentAttachment.contentType == "application/vnd.microsoft.card.adaptive" {
                        if let content = contentAttachment.content as? AdaptiveCard {
                            self.adaptiveCards.append(content)
                        }
                    } else {
                        print("contentAttachment.contentType: \(contentAttachment.contentType)")
                    }
                case .url(let urlAttachment):
                    print("\(urlAttachment) - URLAttachment isn't supported")
                }
            }

            self.attachmentLayout = messageActivity.attachmentLayout

        default:
            self.text = "Unhandled activity type"
        }

        if self.adaptiveCards.count > 0 {
            self.type = .card
        } else {
            if let fromID = activity.from.id, fromID.contains("IVY_Voice_Assistant") {
                self.type = .response
            } else {
                self.type = .request
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity

    init(errorMessage: String) {
        self.id = UUID().uuidString
        self.activityId = nil
        self.text = errorMessage
        self.speak = errorMessage
        self.type = .error
    }

    static func mockRequestData() -> MessageInfo {
        MessageInfo.init(type: .recognizing, text: "Weather on Monday ...")
    }

    static func mockResponseData() -> MessageInfo {
        MessageInfo.init(type: .response, text: "Rainy, +5C")
    }
}
// swiftlint:enable identifier_name

public class Messages: ObservableObject {
    @Published var list = [MessageInfo]()
    @Published var speechList = [MessageInfo]()
    @Published var actions = [ActionInfo]()
    @Published var connectionErrorDescription: String? = nil

    func fillWithMockData() {
        list.append(MessageInfo.init(type: .response,
                                     text: "Hi, I’m MOC, an open-source Voice Assistant. That's what i can:"))
        list.append(MessageInfo.init(type: .request, text: "What weather will be tomorrow ..."))
        list.append(MessageInfo(type: .card, text: Messages.mockAdaptiveCardJson()))
        connectionErrorDescription = "Socket connection error"
    }

    static func mockAdaptiveCardJson() -> String {
        if let fileURL = Bundle.main.url(forResource: "WeatherCard", withExtension: "json") {

            do {
                let adaptiveCardJSON = try String(contentsOf: fileURL, encoding: .utf8)
                return adaptiveCardJSON
            } catch {
            }
        }

        return ""
    }

    static func mockAdaptiveCardMessageInfo() -> MessageInfo {
        do {
            let decoder = JSONDecoder()
            let activity = try decoder.decode(Activity<DirectLine.Empty>.self,
                                              from: Messages.mockAdaptiveCardJson().data(using: .utf8)!)
            return MessageInfo(activity: activity)
        } catch {
            print(error)
            return MessageInfo(errorMessage: "Fail create mock adaptive card")
        }
    }
}

struct MessageInformation_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
