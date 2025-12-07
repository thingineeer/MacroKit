import macroKit
import Foundation

print("=== macroKit 튜토리얼 ===\n")

// MARK: - 1. #stringify 매크로
// 표현식과 그 소스 코드를 함께 반환합니다
print("📝 #stringify 매크로")
let a = 17
let b = 25
let (result, code) = #stringify(a + b)
print("값: \(result), 코드: \"\(code)\"")
print()

// MARK: - 2. #URL 매크로
// 컴파일 타임에 URL 유효성을 검증합니다
print("🔗 #URL 매크로")
let appleURL = #URL("https://apple.com")
let googleURL = #URL("https://google.com")
print("Apple URL: \(appleURL)")
print("Google URL: \(googleURL)")
// 아래 주석을 해제하면 컴파일 에러가 발생합니다!
 let invalidURL = #URL("이건 URL이 아님")
print()

// MARK: - 3. #unwrap 매크로
// Optional을 안전하게 unwrap합니다
print("📦 #unwrap 매크로")
let optionalName: String? = "Swift"
let optionalNil: String? = nil

do {
    let name = try #unwrap(optionalName)
    print("이름: \(name)")
} catch {
    print("에러: \(error)")
}

do {
    let value = try #unwrap(optionalNil, "값이 없습니다!")
    print("값: \(value)")
} catch {
    print("예상된 에러: \(error)")
}
print()

// MARK: - 4. #log 매크로
// 디버깅용 로그 (파일명, 라인 번호 포함)
print("🔍 #log 매크로")
let userName = "Alice"
let userAge = 25
_ = #log(userName)
_ = #log(userAge * 2)
print()

// MARK: - 5. #buildDate 매크로
// 빌드 시점의 날짜/시간을 반환합니다
print("📅 #buildDate 매크로")
print("빌드 시간: \(#buildDate)")
print()

print("=== 튜토리얼 완료! ===")
print("""

💡 사용 가능한 매크로:
- #stringify(expr)      : 표현식과 소스 코드 반환
- #URL("...")          : 컴파일 타임 URL 검증
- #unwrap(optional)    : Optional 안전 unwrap
- #log(value)          : 디버그 로깅
- #buildDate           : 빌드 시간 확인
- #addSubview(view)    : UIView에 서브뷰 추가 (UIKit 전용)
""")
