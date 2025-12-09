//
//  AddToMacro.swift
//  macroKit
//
//  Created by 이명진 on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// @AddTo("parentView") - 특정 뷰에 서브뷰로 추가되도록 지정합니다
/// @AddSubviews와 함께 사용됩니다
public struct AddToMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return [] // AddTo는 AddSubviews에서만 사용
    }
}
