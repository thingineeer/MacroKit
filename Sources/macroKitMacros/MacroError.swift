//
//  MacroError.swift
//  macroKit
//
//  Created by macroKit on 12/7/25.
//

import Foundation

/// 매크로에서 공통으로 사용하는 에러 타입
public enum MacroError: Error, CustomStringConvertible {
    case message(String)

    public var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}
