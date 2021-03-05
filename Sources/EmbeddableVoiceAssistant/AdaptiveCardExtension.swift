//
//  AdaptiveCardExtension.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 26.01.2021.
//

import AdaptiveCardUI

extension AdaptiveCard {
    static let contentType = "application/vnd.microsoft.card.adaptive"
}

extension AdaptiveCard: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}
