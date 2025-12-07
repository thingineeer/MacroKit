// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - Error Types

/// #unwrap 매크로에서 사용하는 에러 타입
public enum UnwrapError: Error, CustomStringConvertible {
    case nilValue(String)

    public var description: String {
        switch self {
        case .nilValue(let message):
            return message
        }
    }
}

// MARK: - Stringify Macro

/// 표현식과 그 소스 코드를 함께 반환합니다.
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "macroKitMacros", type: "StringifyMacro")

// MARK: - AddSubview Macro

/// UIView에 서브뷰를 추가합니다.
///
///     #addSubview(myLabel)
///
/// expands to `self.addSubview(myLabel)`
@freestanding(expression)
public macro addSubview(_ view: Any) = #externalMacro(
    module: "macroKitMacros",
    type: "AddSubviewMacro"
)

// MARK: - URL Macro

/// 컴파일 타임에 URL 유효성을 검증합니다.
/// 잘못된 URL이면 컴파일 에러가 발생합니다.
///
///     let url = #URL("https://apple.com")
///     let invalid = #URL("not a url")  // 컴파일 에러!
///
@freestanding(expression)
public macro URL(_ string: String) -> URL = #externalMacro(
    module: "macroKitMacros",
    type: "URLMacro"
)

// MARK: - Unwrap Macro

/// Optional을 안전하게 unwrap하고, nil이면 에러를 던집니다.
///
///     let value = try #unwrap(optionalString)
///     let value2 = try #unwrap(optionalInt, "숫자가 필요합니다!")
///
@freestanding(expression)
public macro unwrap<T>(_ value: T?, _ message: String) -> T = #externalMacro(
    module: "macroKitMacros",
    type: "UnwrapMacro"
)

@freestanding(expression)
public macro unwrap<T>(_ value: T?) -> T = #externalMacro(
    module: "macroKitMacros",
    type: "UnwrapMacro"
)

// MARK: - Log Macro

/// 디버깅용 로그를 출력합니다. 파일명, 라인 번호, 표현식과 값을 함께 출력합니다.
///
///     #log(userName)
///     // 출력: [main.swift:10:5] userName = "Alice"
///
@freestanding(expression)
public macro log<T>(_ value: T) -> T = #externalMacro(
    module: "macroKitMacros",
    type: "LogMacro"
)

// MARK: - BuildDate Macro

/// 빌드된 날짜와 시간을 문자열로 반환합니다.
///
///     print("Built on: \(#buildDate)")
///     // 출력: "Built on: 2025-12-07 14:30:00"
///
@freestanding(expression)
public macro buildDate() -> String = #externalMacro(
    module: "macroKitMacros",
    type: "BuildDateMacro"
)

// MARK: - AddSubviews Macro

/// 클래스에 붙이면 setHierarchy() 메서드를 자동 생성합니다.
/// UIView 타입 프로퍼티들을 자동으로 view.addSubview() 합니다.
///
///     @AddSubviews
///     class MyViewController: UIViewController {
///         let titleLabel = UILabel()
///         let button = UIButton()
///
///         @AddTo("containerView")
///         let innerLabel = UILabel()
///
///         let containerView = UIView()
///     }
///
///     // 자동 생성:
///     // func setHierarchy() {
///     //     view.addSubview(titleLabel)
///     //     view.addSubview(button)
///     //     view.addSubview(containerView)
///     //     containerView.addSubview(innerLabel)
///     // }
///
@attached(member, names: named(setHierarchy))
public macro AddSubviews() = #externalMacro(
    module: "macroKitMacros",
    type: "AddSubviewsMacro"
)

// MARK: - AddTo Macro

/// 특정 뷰에 서브뷰로 추가되도록 지정합니다.
/// @AddSubviews와 함께 사용합니다.
///
///     @AddTo("containerView")
///     let innerLabel = UILabel()
///
@attached(peer)
public macro AddTo(_ parentView: String) = #externalMacro(
    module: "macroKitMacros",
    type: "AddToMacro"
)
