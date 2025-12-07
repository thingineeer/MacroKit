import macroKit

// @AddSubviews 매크로는 UIKit 환경에서 사용합니다.
// 예시:
//
// @AddSubviews
// class ViewController: BaseViewController {
//     let titleLabel = UILabel()
//     let containerView = UIView()
//
//     @AddTo("containerView")
//     let innerButton = UIButton()
// }
//
// 자동 생성:
// override func setHierarchy() {
//     view.addSubview(titleLabel)
//     view.addSubview(containerView)
//     containerView.addSubview(innerButton)
// }

print("macroKit - @AddSubviews 매크로")
