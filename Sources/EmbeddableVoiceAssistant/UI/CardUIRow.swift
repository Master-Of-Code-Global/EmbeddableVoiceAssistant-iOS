//
//  CardUIRow.swift
//  VoiceAssistant
//
//  Created by Andrii Horishnii on 13.01.2021.
//

import AdaptiveCardUI
import SwiftUI
import DirectLine

struct CardUIRow: View {
    private enum Constants {
        static let cardCornerRadius: CGFloat = 4
        static let cardBorderColor = Color.primary.opacity(0.25)
        static let cardBorderWidth: CGFloat = 0.5
        static let maxCardWidth: CGFloat = 400
    }

    let message: MessageInfo

    var body: some View {
        if let attachmentLayout = message.attachmentLayout {
            if attachmentLayout == AttachmentLayout.carousel {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 4, content: {
                        ForEach(message.adaptiveCards, id: \.self) { card in
                            adaptiveCardView(card)
                        }
                    })
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4, content: {
                        ForEach(message.adaptiveCards, id: \.self) { card in
                            adaptiveCardView(card)
                        }
                    })
                }
            }
        } else {
            if let card = message.adaptiveCards.first {
                adaptiveCardView(card)
            } else {
                EmptyView()
            }
        }
    }

    func adaptiveCardView(_ adaptiveCard: AdaptiveCard) -> AnyView {
        AnyView(AdaptiveCardView(adaptiveCard)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                            .strokeBorder(Constants.cardBorderColor, lineWidth: Constants.cardBorderWidth)
                    )
                    .frame(maxWidth: Constants.maxCardWidth)
                    .padding()
                    .actionSetConfiguration(ActionSetConfiguration(actionsOrientation: .horizontal))
                    //                .customCardElement { StarCountView($0) }
                    //                .customCardElement { RepoLanguageView($0) }
                    .onImageStyle(.default, apply: RoundedImageStyle())
                    .buttonStyle(CapsuleButtonStyle())
                    .animation(.default))
    }
}

struct RoundedImageStyle: CustomImageStyle {
    func makeBody(content: Content) -> some View {
        content.clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct CardUIRow_Previews: PreviewProvider {
    static var previews: some View {
        CardUIRow(message: Messages.mockAdaptiveCardMessageInfo())
    }
}
