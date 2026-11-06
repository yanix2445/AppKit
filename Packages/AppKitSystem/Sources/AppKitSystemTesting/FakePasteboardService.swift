import AppKitSystem
import Synchronization

/// A pasteboard the tests write to.
public final class FakePasteboardService: PasteboardService {
    private struct State {
        var changeCount = 0
        var text: String?
        var types: Set<String> = []
        var readCount = 0
        var replacementDuringRead: (text: String, types: Set<String>)?
    }

    private let state = Mutex(State())

    public init() {}

    public var changeCount: Int {
        state.withLock { $0.changeCount }
    }

    public func readTypes() -> Set<String> {
        state.withLock { $0.types }
    }

    public func readText() -> String? {
        state.withLock {
            $0.readCount += 1
            let text = $0.text
            if let replacement = $0.replacementDuringRead {
                $0.replacementDuringRead = nil
                $0.changeCount += 1
                $0.text = replacement.text
                $0.types = replacement.types
            }
            return text
        }
    }

    /// How many times the content was read.
    public var readCount: Int {
        state.withLock { $0.readCount }
    }

    /// Simulates a copy landing between the check of the types and the read of the text.
    public func replaceDuringNextRead(text: String, types: Set<String>) {
        state.withLock { $0.replacementDuringRead = (text, types) }
    }

    public func write(text: String) -> Int {
        state.withLock {
            $0.changeCount += 1
            $0.text = text
            $0.types = []
            return $0.changeCount
        }
    }

    public func copy(text: String?, types: Set<String> = []) {
        state.withLock {
            $0.changeCount += 1
            $0.text = text
            $0.types = types
        }
    }
}
