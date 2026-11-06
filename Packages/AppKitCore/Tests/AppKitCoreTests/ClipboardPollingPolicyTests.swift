import AppKitCore
import Testing

struct ClipboardPollingPolicyTests {
    @Test func pollsEveryHalfSecondWithATolerance() {
        #expect(ClipboardPollingPolicy.standard.interval == .milliseconds(500))
        #expect(ClipboardPollingPolicy.standard.tolerance > .zero)
    }
}
