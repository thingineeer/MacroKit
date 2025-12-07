//
//  AddSubviewMacro.swift
//  macroKit
//
//  Created by 이명진 on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

// Minimal error type used by AddSubviewMacro
enum AddSubviewMacroError: Error {
    case message(String)
}

public struct AddSubviewMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {

        // 매크로 인자에서 변수명 꺼내기
        guard let argument = node.arguments.first?.expression else {
            throw AddSubviewMacroError.message("addSubview macro needs a view instance!")
        }

        // 결과: self.addSubview(argument)
        return "self.addSubview(\(argument))"
    }
}
