import Foundation

/// One format of a copy, exactly as it was on the pasteboard.
public struct ClipRepresentation: Equatable, Codable, Sendable {
    public let type: String
    public let data: Data

    public init(type: String, data: Data) {
        self.type = type
        self.data = data
    }
}
