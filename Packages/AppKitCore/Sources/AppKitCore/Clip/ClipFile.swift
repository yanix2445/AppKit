import Foundation

/// A file kept by reference: its place on the disk, never its content.
public struct ClipFile: Equatable, Codable, Sendable {
    public let path: String

    public init(path: String) {
        self.path = path
    }

    public var name: String {
        (path as NSString).lastPathComponent
    }

    public var fileExtension: String {
        (path as NSString).pathExtension
    }

    public var exists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    /// The files of a copy, read from its formats. The Finder writes reference URLs, which
    /// are resolved to the path they lead to at the moment of the copy.
    public static func files(in formats: [ClipRepresentation]) -> [ClipFile] {
        formats
            .filter { $0.type == ClipClassifier.fileURLType }
            .compactMap { format -> ClipFile? in
                guard let url = URL(dataRepresentation: format.data, relativeTo: nil),
                      let path = (url as NSURL).filePathURL?.path
                else { return nil }
                return ClipFile(path: path)
            }
    }
}
