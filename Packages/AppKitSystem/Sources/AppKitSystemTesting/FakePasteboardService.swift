import AppKitSystem
import Synchronization

/// A pasteboard the tests write to.
public final class FakePasteboardService: PasteboardService {
    private struct State {
        var changeCount = 0
        var text: String?
    }

    private let state = Mutex(State())

    public init() {}

    public var changeCount: Int {
        state.withLock { $0.changeCount }
    }

    public func readText() -> String? {
        state.withLock { $0.text }
    }

    public func copy(text: String?) {
        state.withLock {
            $0.changeCount += 1
            $0.text = text
        }
    }
}
