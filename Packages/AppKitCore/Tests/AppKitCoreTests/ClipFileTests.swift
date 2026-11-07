import AppKitCore
import Foundation
import Testing

struct ClipFileTests {
    private func format(_ path: String, item: Int = 0) -> ClipRepresentation {
        ClipRepresentation(
            type: ClipClassifier.fileURLType,
            data: URL(fileURLWithPath: path).dataRepresentation,
            itemIndex: item
        )
    }

    @Test func readsEveryFileOfACopy() {
        let files = ClipFile.files(in: [
            format("/tmp/a.png", item: 0),
            ClipRepresentation(type: "public.utf8-plain-text", data: Data("a.png".utf8), itemIndex: 0),
            format("/tmp/b c.pdf", item: 1),
        ])
        #expect(files.map(\.name) == ["a.png", "b c.pdf"])
        #expect(files[1].fileExtension == "pdf")
    }

    @Test func tellsWhenAFileIsGone() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "ClipFileTests-\(UUID().uuidString)")
        try Data([1]).write(to: url)
        let file = ClipFile(path: url.path)
        #expect(file.exists)
        try FileManager.default.removeItem(at: url)
        #expect(!file.exists)
    }

    @Test func recognizesProtectedFolders() {
        #expect(ClipProtectedFolder.containing("/Users/a/Documents/f.pdf", home: "/Users/a") == .documents)
        #expect(ClipProtectedFolder.containing("/Users/a/Desktop/x/f.pdf", home: "/Users/a") == .desktop)
        #expect(ClipProtectedFolder.containing("/Users/a/Downloads/f.pdf", home: "/Users/a") == .downloads)
        #expect(ClipProtectedFolder.containing("/Users/a/Musique/f.pdf", home: "/Users/a") == nil)
        #expect(ClipProtectedFolder.containing("/tmp/Documents/f.pdf", home: "/Users/a") == nil)
    }

    @Test func aFormatStoredWithoutAnIndexBelongsToTheFirstElement() throws {
        struct Old: Codable { let type: String; let data: Data }
        let encoded = try PropertyListEncoder().encode(Old(type: "public.png", data: Data([1])))
        let decoded = try PropertyListDecoder().decode(ClipRepresentation.self, from: encoded)
        #expect(decoded.itemIndex == 0)
    }
}
