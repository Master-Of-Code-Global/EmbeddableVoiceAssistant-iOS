//
//  RequestShape.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 04.01.2021.
//

import SwiftUI

struct RequestShape: Shape {
    let radius: CGFloat = 8
    let bulgeHeight: CGFloat = 8
    let bulgeWidth: CGFloat = 7

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))

        path.addRelativeArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: .degrees(-90),
                            delta: .degrees(90))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY + bulgeHeight))
        path.addLine(to: CGPoint(x: rect.maxX - bulgeWidth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))

        path.addRelativeArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                            radius: radius,
                            startAngle: .degrees(90),
                            delta: .degrees(90))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))

        path.addRelativeArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: .degrees(180),
                            delta: .degrees(90))

        return path
    }
}
