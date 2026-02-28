import Foundation
import LocalAuthentication

enum BiometricLockService {
    static func canEvaluate() -> Bool {
        let ctx = LAContext()
        var err: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err)
    }

    static func evaluate(reason: String) async -> Bool {
        let ctx = LAContext()
        do {
            return try await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            // biometrics失敗時はパスコードにフォールバックしたいなら .deviceOwnerAuthentication を使う
            return false
        }
    }
}
