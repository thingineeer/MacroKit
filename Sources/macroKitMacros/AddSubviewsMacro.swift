//
//  AddSubviewsMacro.swift
//  macroKit
//
//  Created by 이명진 on 12/7/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import Foundation

/// 매크로 에러 타입
enum MacroError: Error, CustomStringConvertible {
    case message(String)

    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}

/// @AddSubviews - 클래스에 붙이면 setHierarchy() 메서드를 자동 생성합니다
/// UIView/UIViewController 프로퍼티들을 자동으로 addSubview 합니다
public struct AddSubviewsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self) else {
            throw MacroError.message("@AddSubviews can only be applied to classes or structs")
        }

        var defaultSubviews: [String] = []
        var customSubviews: [(child: String, parent: String)] = []

        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

            guard let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }

            let propertyName = identifier.identifier.text

            let isLazy = varDecl.modifiers.contains { $0.name.tokenKind == .keyword(.lazy) }

            var isUIView = false

            if isLazy {
                if let typeAnnotation = binding.typeAnnotation?.type {
                    let typeText = typeAnnotation.description.trimmingCharacters(in: .whitespaces)
                    isUIView = isUIViewType(typeText)
                } else if let initializer = binding.initializer?.value {
                    let initText = initializer.description.trimmingCharacters(in: .whitespaces)
                    isUIView = isUIViewType(initText) || isClosureReturningUIView(initText)
                }
            } else {
                guard let initializer = binding.initializer?.value else { continue }
                let initText = initializer.description.trimmingCharacters(in: .whitespaces)
                isUIView = isUIViewType(initText)
            }

            guard isUIView else { continue }

            var parentView: String? = nil
            for attribute in varDecl.attributes {
                if let attr = attribute.as(AttributeSyntax.self),
                   let attrName = attr.attributeName.as(IdentifierTypeSyntax.self),
                   attrName.name.text == "AddTo" {
                    if let arguments = attr.arguments?.as(LabeledExprListSyntax.self),
                       let firstArg = arguments.first?.expression.as(StringLiteralExprSyntax.self),
                       let segment = firstArg.segments.first?.as(StringSegmentSyntax.self) {
                        parentView = segment.content.text
                    }
                }
            }

            if let parent = parentView {
                customSubviews.append((child: propertyName, parent: parent))
            } else {
                defaultSubviews.append(propertyName)
            }
        }

        var statements: [CodeBlockItemSyntax] = []

        for subview in defaultSubviews {
            statements.append(
                CodeBlockItemSyntax("view.addSubview(\(raw: subview))")
            )
        }

        for (child, parent) in customSubviews {
            statements.append(
                CodeBlockItemSyntax("\(raw: parent).addSubview(\(raw: child))")
            )
        }

        guard !statements.isEmpty else { return [] }

        let method = try! FunctionDeclSyntax("override func setHierarchy()") {
            for stmt in statements {
                stmt
            }
        }

        return [DeclSyntax(method)]
    }

    /// UIView 관련 타입인지 확인
    private static func isUIViewType(_ text: String) -> Bool {
        let viewTypes = [
            "UIView", "UILabel", "UIButton", "UIImageView", "UITextField",
            "UITextView", "UITableView", "UICollectionView", "UIScrollView",
            "UIStackView", "UISwitch", "UISlider", "UIProgressView",
            "UISegmentedControl", "UIPickerView", "UIDatePicker",
            "UIActivityIndicatorView", "UIVisualEffectView", "UISearchBar",
            "UIToolbar", "UITabBar", "UINavigationBar", "UIPageControl",
            "WKWebView", "MKMapView", "SKView", "GLKView", "MTKView"
        ]

        return viewTypes.contains { text.hasPrefix($0) }
    }

    /// 클로저가 UIView를 반환하는지 확인
    private static func isClosureReturningUIView(_ text: String) -> Bool {
        let viewTypes = [
            "UIView", "UILabel", "UIButton", "UIImageView", "UITextField",
            "UITextView", "UITableView", "UICollectionView", "UIScrollView",
            "UIStackView", "UISwitch", "UISlider", "UIProgressView",
            "UISegmentedControl", "UIPickerView", "UIDatePicker",
            "UIActivityIndicatorView", "UIVisualEffectView", "UISearchBar",
            "UIToolbar", "UITabBar", "UINavigationBar", "UIPageControl",
            "WKWebView", "MKMapView", "SKView", "GLKView", "MTKView"
        ]

        return viewTypes.contains { text.contains($0) }
    }
}
