//
//  macroKitTests.swift
//  macroKit
//
//  Created by 이명진 on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(macroKitMacros)
import macroKitMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "addSubview": AddSubviewMacro.self,
    "URL": URLMacro.self,
    "unwrap": UnwrapMacro.self,
    "log": LogMacro.self,
    "buildDate": BuildDateMacro.self,
    "AddSubviews": AddSubviewsMacro.self,
    "AddTo": AddToMacro.self,
]
#endif

// MARK: - Stringify Macro Tests

final class StringifyMacroTests: XCTestCase {
    func testStringify() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testStringifyWithStringLiteral() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

// MARK: - AddSubview Macro Tests

final class AddSubviewMacroTests: XCTestCase {
    func testAddSubview() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            #addSubview(titleLabel)
            """,
            expandedSource: """
            self.addSubview(titleLabel)
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

// MARK: - URL Macro Tests

final class URLMacroTests: XCTestCase {
    func testValidURL() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            #URL("https://apple.com")
            """,
            expandedSource: """
            URL(string: "https://apple.com")!
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testURLWithSpecialCharacters() throws {
        #if canImport(macroKitMacros)
        // 한글 URL도 Foundation URL이 percent encoding으로 처리함
        assertMacroExpansion(
            """
            #URL("https://example.com/한글")
            """,
            expandedSource: """
            URL(string: "https://example.com/한글")!
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

// MARK: - Unwrap Macro Tests

final class UnwrapMacroTests: XCTestCase {
    func testUnwrapBasic() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            try #unwrap(optionalValue)
            """,
            expandedSource: """
            try {
                guard let unwrapped = optionalValue else {
                    throw UnwrapError.nilValue("Failed to unwrap: optionalValue")
                }
                return unwrapped
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testUnwrapWithMessage() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            try #unwrap(optionalValue, "커스텀 메시지")
            """,
            expandedSource: """
            try {
                guard let unwrapped = optionalValue else {
                    throw UnwrapError.nilValue("커스텀 메시지")
                }
                return unwrapped
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

// MARK: - Log Macro Tests

final class LogMacroTests: XCTestCase {
    func testLog() throws {
        #if canImport(macroKitMacros)
        // Log 매크로는 context.location을 사용
        // 테스트 환경에서는 기본값이 사용됨
        assertMacroExpansion(
            """
            #log(userName)
            """,
            expandedSource: """
            {
                let _value = userName
                print("[\\("TestModule/test.swift"):\\(1):\\(1)] userName = \\(_value)")
                return _value
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

// MARK: - BuildDate Macro Tests

final class BuildDateMacroTests: XCTestCase {
    // BuildDate는 매번 다른 시간을 생성하므로
    // 실제 테스트는 통합 테스트에서 수행
}

// MARK: - AddSubviews Macro Tests

final class AddSubviewsMacroTests: XCTestCase {
    func testAddSubviewsBasic() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            @AddSubviews
            class MyViewController {
                let titleLabel = UILabel()
                let button = UIButton()
            }
            """,
            expandedSource: """
            class MyViewController {
                let titleLabel = UILabel()
                let button = UIButton()

                func setHierarchy() {
                        view.addSubview(titleLabel)
                        view.addSubview(button)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddSubviewsWithAddTo() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            @AddSubviews
            class MyViewController {
                let containerView = UIView()

                @AddTo("containerView")
                let innerLabel = UILabel()
            }
            """,
            expandedSource: """
            class MyViewController {
                let containerView = UIView()
                let innerLabel = UILabel()

                func setHierarchy() {
                        view.addSubview(containerView)
                        containerView.addSubview(innerLabel)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddSubviewsWithMultipleViews() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            @AddSubviews
            class MyViewController {
                let headerView = UIView()
                let titleLabel = UILabel()
                let descriptionLabel = UILabel()
                let actionButton = UIButton()

                @AddTo("headerView")
                let headerIcon = UIImageView()

                @AddTo("headerView")
                let headerTitle = UILabel()
            }
            """,
            expandedSource: """
            class MyViewController {
                let headerView = UIView()
                let titleLabel = UILabel()
                let descriptionLabel = UILabel()
                let actionButton = UIButton()
                let headerIcon = UIImageView()
                let headerTitle = UILabel()

                func setHierarchy() {
                        view.addSubview(headerView)
                        view.addSubview(titleLabel)
                        view.addSubview(descriptionLabel)
                        view.addSubview(actionButton)
                        headerView.addSubview(headerIcon)
                        headerView.addSubview(headerTitle)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddSubviewsIgnoresNonUIViewTypes() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            @AddSubviews
            class MyViewController {
                let titleLabel = UILabel()
                let name = "Hello"
                let count = 42
            }
            """,
            expandedSource: """
            class MyViewController {
                let titleLabel = UILabel()
                let name = "Hello"
                let count = 42

                func setHierarchy() {
                        view.addSubview(titleLabel)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
