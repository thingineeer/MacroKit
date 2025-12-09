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
    "AddSubviews": AddSubviewsMacro.self,
    "AddTo": AddToMacro.self,
]
#endif

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

                override func setHierarchy() {
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

                override func setHierarchy() {
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

                override func setHierarchy() {
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

    func testAddSubviewsWithLazyVar() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            @AddSubviews
            class MyViewController {
                let titleLabel = UILabel()

                lazy var descriptionLabel: UILabel = {
                    let label = UILabel()
                    label.numberOfLines = 0
                    return label
                }()
            }
            """,
            expandedSource: """
            class MyViewController {
                let titleLabel = UILabel()

                lazy var descriptionLabel: UILabel = {
                    let label = UILabel()
                    label.numberOfLines = 0
                    return label
                }()

                override func setHierarchy() {
                    view.addSubview(titleLabel)
                    view.addSubview(descriptionLabel)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddSubviewsWithLazyVarAndAddTo() throws {
        #if canImport(macroKitMacros)
        assertMacroExpansion(
            """
            @AddSubviews
            class MyViewController {
                let containerView = UIView()

                @AddTo("containerView")
                lazy var innerButton: UIButton = {
                    let button = UIButton()
                    button.setTitle("Click", for: .normal)
                    return button
                }()
            }
            """,
            expandedSource: """
            class MyViewController {
                let containerView = UIView()
                lazy var innerButton: UIButton = {
                    let button = UIButton()
                    button.setTitle("Click", for: .normal)
                    return button
                }()

                override func setHierarchy() {
                    view.addSubview(containerView)
                    containerView.addSubview(innerButton)
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
