//
//  PopoverShape.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import SwiftUI

struct PopoverShape: Shape {
    var arrowHeight: CGFloat = 12
    var cornerRadius: CGFloat = 16
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let centerX = rect.midX
        let arrowTipY = rect.minY
        
        let arrowCurveStartX = centerX - arrowHeight * 1.5
        let arrowCurveEndX = centerX + arrowHeight * 1.5
        let arrowBaseY = rect.minY + arrowHeight
        
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + arrowHeight))
        
        path.addLine(to: CGPoint(x: arrowCurveStartX, y: arrowBaseY))
        
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: arrowTipY),
            control: CGPoint(x: arrowCurveStartX + arrowHeight * 0.3, y: arrowBaseY - arrowHeight * 0.4)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: arrowCurveEndX, y: arrowBaseY),
            control: CGPoint(x: arrowCurveEndX - arrowHeight * 0.3, y: arrowBaseY - arrowHeight * 0.4)
        )
        
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + arrowHeight))
        
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + arrowHeight + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY + arrowHeight)
        )
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + arrowHeight + cornerRadius))
        
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + arrowHeight),
            control: CGPoint(x: rect.minX, y: rect.minY + arrowHeight)
        )
        
        return path
    }
}
