//
//  LogMacro.swift
//  macroKit
//
//  Created by macroKit on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// #log("message") - 파일명, 함수명, 라인 번호와 함께 로그를 출력합니다
/// #log(someVariable) - 변수 이름과 값을 함께 출력합니다
public struct LogMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw MacroError.message("#log requires an argument")
        }

        // 소스 위치 정보 가져오기
        let location = context.location(of: node)
        let file = location?.file.description ?? "unknown"
        let line = location?.line.description ?? "?"
        let column = location?.column.description ?? "?"

        let expressionString = argument.description

        return """
        {
            let _value = \(argument)
            print("[\\(\(raw: file)):\\(\(raw: line)):\\(\(raw: column))] \(raw: expressionString) = \\(_value)")
            return _value
        }()
        """
    }
}
