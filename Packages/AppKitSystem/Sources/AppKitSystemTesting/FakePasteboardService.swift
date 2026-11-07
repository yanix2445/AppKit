import AppKitCore
import AppKitSystem
import Foundation
import Synchronization

/// A pasteboard the tests write to.
public final class FakePasteboardService: PasteboardService {
    private struct State {
        var changeCount = 0
        var text: String?
        var types: Set<String> = []
        var formats: [ClipRepresentation] = []
        var color: ClipColor?
        var sourceMarker: String?
        var readDelay: TimeInterval = 0
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

    /// Simulates the wait for a copy to arrive from another device.
    public var readDelay: TimeInterval {
        get { state.withLock { $0.readDelay } }
        set { state.withLock { $0.readDelay = newValue } }
    }

    public func readText() -> String? {
        Thread.sleep(forTimeInterval: readDelay)
        return state.withLock {
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

    public func readColor() -> ClipColor? {
        state.withLock { $0.color }
    }

    /// Simulates a copy from a color picker.
    public func copy(color: ClipColor) {
        state.withLock {
            $0.changeCount += 1
            $0.text = nil
            $0.color = color
            $0.types = [ClipClassifier.colorType]
            $0.formats = [ClipRepresentation(type: ClipClassifier.colorType, data: Data([1]))]
        }
    }

    /// Simulates a copy with its text and other formats.
    public func copy(text: String, formats: [ClipRepresentation]) {
        state.withLock {
            $0.changeCount += 1
            $0.text = text
            $0.formats = formats
            $0.types = Set(formats.map(\.type)).union([ClipClassifier.plainTextType])
        }
    }

    /// Simulates the marker by which an app names itself.
    public func setSourceMarker(_ identifier: String?) {
        state.withLock { $0.sourceMarker = identifier }
    }

    public func readString(forType type: String) -> String? {
        type == ClipCapturePolicy.sourceMarkerType ? state.withLock { $0.sourceMarker } : nil
    }

    public func readFormats() -> [ClipRepresentation] {
        state.withLock {
            $0.readCount += 1
            return $0.formats
        }
    }

    public func write(formats: [ClipRepresentation]) -> Int {
        state.withLock {
            $0.changeCount += 1
            $0.text = nil
            $0.formats = formats
            $0.types = Set(formats.map(\.type))
            return $0.changeCount
        }
    }

    /// Simulates a copy of an image or a PDF.
    public func copy(formats: [ClipRepresentation]) {
        _ = write(formats: formats)
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
            $0.formats = []
            return $0.changeCount
        }
    }

    public func copy(text: String?, types: Set<String> = []) {
        state.withLock {
            $0.changeCount += 1
            $0.text = text
            $0.types = types.isEmpty && text != nil ? [ClipClassifier.plainTextType] : types
        }
    }

    /// Simulates an app that empties the pasteboard.
    public func empty() {
        state.withLock {
            $0.changeCount += 1
            $0.text = nil
            $0.types = []
            $0.formats = []
        }
    }
}
