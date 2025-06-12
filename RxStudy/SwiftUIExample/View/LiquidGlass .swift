//
//  LiquidGlass .swift
//  RxStudy
//
//  Created by dy on 2025/6/12.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

/// https://github.com/rebeloper/LiquidGlass

@available(iOS 15.0, macOS 14.0, watchOS 10.0, tvOS 15.0, visionOS 1.0, *)
public struct LiquidGlassBackgroundModifier: ViewModifier {
    
    public enum GlassBackgroundDisplayMode {
        case always
        case automatic
    }
    
    public enum GradientStyle {
        case normal
        case reverted
    }
    
    let displayMode: GlassBackgroundDisplayMode
    let radius: CGFloat
    let color: Color
    let material: Material
    let materialOpacity: Double
    let gradientOpacity: Double
    let gradientStyle: GradientStyle
    let strokeWidth: CGFloat
    let shadowColor: Color
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    
    public init(
        displayMode: GlassBackgroundDisplayMode,
        radius: CGFloat,
        color: Color,
        material: Material = .ultraThinMaterial,
        materialOpacity: Double = 0.7,
        gradientOpacity: Double = 0.5,
        gradientStyle: GradientStyle = .normal,
        strokeWidth: CGFloat = 1.5,
        shadowColor: Color = .white,
        shadowOpacity: Double = 0.5,
        shadowRadius: CGFloat? = nil,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 5
    ) {
        self.displayMode = displayMode
        self.radius = radius
        self.color = color
        self.material = material
        self.materialOpacity = materialOpacity
        self.gradientOpacity = gradientOpacity
        self.gradientStyle = gradientStyle
        self.strokeWidth = strokeWidth
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius ?? radius
        self.shadowX = shadowX
        self.shadowY = shadowY
    }
    
    public func body(content: Content) -> some View {
        content
            .background(material.opacity(materialOpacity))
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors()),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: strokeWidth
                    )
            )
            .shadow(color: shadowColor.opacity(shadowOpacity), radius: shadowRadius, x: shadowX, y: shadowY)
    }
    
    private func gradientColors() -> [Color] {
        switch gradientStyle {
        case .normal:
            return [
                color.opacity(gradientOpacity),
                .clear,
                .clear,
                color.opacity(gradientOpacity)
            ]
        case .reverted:
            return [
                .clear,
                color.opacity(gradientOpacity),
                color.opacity(gradientOpacity),
                .clear
            ]
        }
    }
}

@available(iOS 15.0, macOS 14.0, watchOS 10.0, tvOS 15.0, visionOS 1.0, *)
public extension View {
    /// Applies a customizable glass/frosted effect to the view
    /// - Parameters:
    ///   - displayMode: Controls when the effect is displayed (.always or .automatic)
    ///   - radius: Corner radius of the glass effect
    ///   - color: Base color for the effect's gradient and highlights
    ///   - material: The material style to use for the glass effect
    ///   - materialOpacity: Opacity level for the material overlay
    ///   - gradientOpacity: Opacity level for the gradient overlay
    ///   - gradientStyle: Direction style of the gradient (.normal or .reverted)
    ///   - strokeWidth: Width of the border stroke
    ///   - shadowColor: Color of the drop shadow
    ///   - shadowOpacity: Opacity level for the shadow
    ///   - shadowRadius: Blur radius for the shadow (defaults to corner radius if nil)
    ///   - shadowX: Horizontal offset of the shadow
    ///   - shadowY: Vertical offset of the shadow
    /// - Returns: A view with the glass effect applied
    func glass(
        displayMode: LiquidGlassBackgroundModifier.GlassBackgroundDisplayMode = .always,
        radius: CGFloat = 32,
        color: Color = .white,
        material: Material = .ultraThinMaterial,
        materialOpacity: Double = 0.5,
        gradientOpacity: Double = 0.5,
        gradientStyle: LiquidGlassBackgroundModifier.GradientStyle = .normal,
        strokeWidth: CGFloat = 1.5,
        shadowColor: Color = .white,
        shadowOpacity: Double = 0.5,
        shadowRadius: CGFloat? = nil,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 5
    ) -> some View {
        #if os(visionOS)
        return self.glassBackgroundEffect()
        #else
        return modifier(LiquidGlassBackgroundModifier(
            displayMode: displayMode,
            radius: radius,
            color: color,
            material: material,
            materialOpacity: materialOpacity, gradientOpacity: gradientOpacity,
            gradientStyle: gradientStyle,
            strokeWidth: strokeWidth,
            shadowColor: shadowColor,
            shadowOpacity: shadowOpacity,
            shadowRadius: shadowRadius,
            shadowX: shadowX,
            shadowY: shadowY
        ))
        #endif
    }
}
