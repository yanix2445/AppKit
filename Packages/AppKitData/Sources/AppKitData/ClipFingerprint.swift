import AppKitCore
import CryptoKit
import Foundation

/// Recognizes the same copy made again: every format identical, byte for byte, leaving out those
/// that change at each copy. It stays sealed on disk, as a hash of a short text could be guessed.
public enum ClipFingerprint {
    public static let volatileTypes: Set<String> = [
        "org.chromium.internal.source-rfh-token",
        "org.chromium.source-url",
        "com.apple.WebKit.custom-pasteboard-data",
        "com.apple.finder.noderef",
        "org.nspasteboard.source",
        ClipClassifier.remoteClipboardType,
    ]

    public static func make(content: ClipContent, formats: [ClipRepresentation]) -> Data {
        var hash = SHA256()
        let kept = formats.filter { !volatileTypes.contains($0.type) }
        if kept.isEmpty, let text = content.plainText {
            hash.update(data: Data(text.utf8))
        } else {
            let sorted = kept.sorted { ($0.itemIndex, $0.type) < ($1.itemIndex, $1.type) }
            for format in sorted {
                hash.update(data: Data("\(format.itemIndex)|\(format.type)|\(format.data.count)|".utf8))
                hash.update(data: format.data)
            }
        }
        return Data(hash.finalize())
    }
}
