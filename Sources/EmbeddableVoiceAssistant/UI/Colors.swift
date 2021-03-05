//
//  Colors.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 12.01.2021.
//

import SwiftUI

extension Color {
    init(red: Int, green: Int, blue: Int, alpha: Double) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(RGBColorSpace.sRGB,
                  red: Double(red) / 255.0,
                  green: Double(green) / 255.0,
                  blue: Double(blue) / 255.0,
                  opacity: alpha)
    }

    init(rgb: Int, alpha: Double = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}

extension Color {
    private static let mainContrast = Color(rgb: 0xF1563C)
    private static let lightGray = Color(rgb: 0xECEBF0)
}

public extension Color {
    /// Colors for the top bar
    static var topBarBackgroundStartGradient = white
    static var topBarBackgroundEndGradient = Color(rgb: 0xF5F4F8)

    /// Colors for buttons text in top bar, subtle text in adaptive card
    static var subtleText = Color(rgb: 0xCCCAD0)
    static var subtleDisabledText = Color(rgb: 0xCCCAD0, alpha: 0.5)

    /// Color for the delimiters
    static var delimiter = lightGray

    /// Colors for the request row
    static var requestBackground = mainContrast
    static var requestText = white

    /// Background colors for the request row(recognizing mode) and waiting row
    static var recognizeBackgroundStartGradient = Color(rgb: 0xFF9884)
    static var recognizeBackgroundEndGradient = Color(rgb: 0xFB8770, alpha: 0.28)

    /// Colors for the response row
    static var responseBackground = lightGray
    static var responseText = Color(rgb: 0x272629)

    /// Colors for the error row
    static var errorBackground = Color(rgb: 0xFFC3CA)
    static var errorText = white

    /// Color for the command button
    static var commandText = mainContrast

    /// Color for the button in adaptive card
    static var cardButtonColor = mainContrast

    /// Color for display the level of the voice that will be recognized
    static var soundLevel = mainContrast.opacity(0.14)
}
