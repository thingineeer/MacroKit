//
//  BuildDateMacro.swift
//  macroKit
//
//  Created by macroKit on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

/// #buildDate - 빌드된 날짜와 시간을 문자열로 반환합니다
public struct BuildDateMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())

        return "\(literal: dateString)"
    }
}
