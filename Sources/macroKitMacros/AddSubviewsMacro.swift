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

        // 클래스 또는 구조체인지 확인
        guard declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self) else {
            throw MacroError.message("@AddSubviews can only be applied to classes or structs")
        }

        // 모든 프로퍼티 수집
        var defaultSubviews: [String] = []
        var customSubviews: [(child: String, parent: String)] = []

        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

            // 프로퍼티 이름 가져오기
            guard let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }

            let propertyName = identifier.identifier.text

            // UIView 타입인지 확인 (초기화 표현식으로 판단)
            guard let initializer = binding.initializer?.value else { continue }

            // 함수 호출 초기화인지 확인 (예: UILabel(), UIButton())
            let initText = initializer.description.trimmingCharacters(in: .whitespaces)
            guard isUIViewType(initText) else { continue }

            // @AddTo 어트리뷰트가 있는지 확인
            var parentView: String? = nil
            for attribute in varDecl.attributes {
                if let attr = attribute.as(AttributeSyntax.self),
                   let attrName = attr.attributeName.as(IdentifierTypeSyntax.self),
                   attrName.name.text == "AddTo" {
                    // @AddTo("parentView")에서 parentView 추출
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

        // setupSubviews() 메서드 생성
        var bodyStatements: [String] = []

        // 기본 서브뷰들 (view.addSubview)
        for subview in defaultSubviews {
            bodyStatements.append("view.addSubview(\(subview))")
        }

        // 커스텀 서브뷰들 (parent.addSubview)
        for (child, parent) in customSubviews {
            bodyStatements.append("\(parent).addSubview(\(child))")
        }

        guard !bodyStatements.isEmpty else {
            return []
        }

        // 각 statement를 개별 ExprSyntax로 변환
        let statementsCode = bodyStatements.map { "        \($0)" }.joined(separator: "\n")

        let method: DeclSyntax = """

        override func setHierarchy() {
        \(raw: statementsCode)
        }
        """

        return [method]
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

        for viewType in viewTypes {
            if text.hasPrefix(viewType) {
                return true
            }
        }

        return false
    }
}
