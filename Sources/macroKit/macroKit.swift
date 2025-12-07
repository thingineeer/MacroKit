// The Swift Programming Language
// https://docs.swift.org/swift-book

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
///     // override func setHierarchy() {
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
