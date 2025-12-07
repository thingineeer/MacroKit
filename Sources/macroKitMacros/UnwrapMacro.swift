//
//  UnwrapMacro.swift
//  macroKit
//
//  Created by macroKit on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// #unwrap(optionalValue) - Optional을 안전하게 unwrap하고 실패시 에러를 던집니다
/// #unwrap(optionalValue, "커스텀 에러 메시지") - 커스텀 메시지와 함께 unwrap
public struct UnwrapMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let arguments = node.arguments

        guard let firstArg = arguments.first?.expression else {
            throw MacroError.message("#unwrap requires at least one argument")
        }

        // 두 번째 인자가 있으면 커스텀 메시지로 사용
        if arguments.count >= 2,
           let secondArg = arguments.dropFirst().first?.expression {
            return """
            {
                guard let unwrapped = \(firstArg) else {
                    throw UnwrapError.nilValue(\(secondArg))
                }
                return unwrapped
            }()
            """
        }

        // 기본 메시지 사용
        let expressionDescription = firstArg.description
        return """
        {
            guard let unwrapped = \(firstArg) else {
                throw UnwrapError.nilValue("Failed to unwrap: \(raw: expressionDescription)")
            }
            return unwrapped
        }()
        """
    }
}

