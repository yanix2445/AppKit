import Foundation

/// The text of the copies in one contiguous block, held only while the strip is open. A word is
/// looked for through the whole block at once, far faster than copy by copy.
public struct ClipSearchIndex: Sendable {
    private let ids: [UUID]
    /// Where each copy starts in `bytes`, plus the end of the last one.
    private let offsets: [Int]
    private let bytes: [UInt8]

    public init(_ clips: [Clip]) {
        self.init(entries: clips.map { ($0.id, $0.content.searchText) })
    }

    /// - Parameter entries: each copy with its text, without case or accents.
    public init(entries: [(id: UUID, text: String)]) {
        var ids: [UUID] = []
        var offsets: [Int] = []
        var bytes: [UInt8] = []
        ids.reserveCapacity(entries.count)
        offsets.reserveCapacity(entries.count + 1)
        for entry in entries {
            ids.append(entry.id)
            offsets.append(bytes.count)
            bytes.append(contentsOf: entry.text.utf8)
            // A word can never run from one copy into the next.
            bytes.append(0)
        }
        offsets.append(bytes.count)
        self.ids = ids
        self.offsets = offsets
        self.bytes = bytes
    }

    /// The separate words of a search, without case or accents.
    public static func words(in query: String) -> [String] {
        query
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
    }

    /// The copies that hold every word of the search, each word looked for on its own.
    public func matches(for query: String) -> Set<UUID> {
        let words = Self.words(in: query)
        guard !words.isEmpty else { return Set(ids) }
        // How many words each copy has held so far.
        var found = [Int32](repeating: 0, count: ids.count)
        bytes.withUnsafeBytes { buffer in
            guard let base = buffer.baseAddress else { return }
            for (position, word) in words.enumerated() {
                let needle = Array(word.utf8)
                var start = 0
                while start < buffer.count,
                      let hit = memmem(base + start, buffer.count - start, needle, needle.count) {
                    let entry = self.entry(at: base.distance(to: UnsafeRawPointer(hit)))
                    if found[entry] == Int32(position) {
                        found[entry] += 1
                    }
                    start = offsets[entry + 1]
                }
            }
        }
        var result = Set<UUID>()
        for (entry, count) in found.enumerated() where count == Int32(words.count) {
            result.insert(ids[entry])
        }
        return result
    }

    private func entry(at offset: Int) -> Int {
        var low = 0
        var high = ids.count - 1
        while low < high {
            let middle = (low + high + 1) / 2
            if offsets[middle] <= offset {
                low = middle
            } else {
                high = middle - 1
            }
        }
        return low
    }
}
