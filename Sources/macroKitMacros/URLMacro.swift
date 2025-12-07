//
//  URLMacro.swift
//  macroKit
//
//  Created by macroKit on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

/// #URL("https://example.com") - 컴파일 타임에 URL 유효성을 검증합니다
/// 잘못된 URL이면 컴파일 에러가 발생합니다
public struct URLMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression,
              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case .stringSegment(let literalSegment)? = segments.first else {
            throw MacroError.message("#URL requires a static string literal")
        }

        let urlString = literalSegment.content.text

        // 컴파일 타임에 URL 유효성 검사
        guard URL(string: urlString) != nil else {
            throw MacroError.message("Invalid URL: \"\(urlString)\"")
        }

        return "URL(string: \(argument))!"
    }
}
