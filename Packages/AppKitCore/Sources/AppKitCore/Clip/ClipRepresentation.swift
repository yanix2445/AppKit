import Foundation

/// One format of one element of a copy, exactly as it was on the pasteboard. A copy can hold
/// several elements, such as several files, each with its own formats.
public struct ClipRepresentation: Equatable, Codable, Sendable {
    public let type: String
    public let data: Data
    public let itemIndex: Int

    public init(type: String, data: Data, itemIndex: Int = 0) {
        self.type = type
        self.data = data
        self.itemIndex = itemIndex
    }

    private enum CodingKeys: String, CodingKey {
        case type, data, itemIndex
    }

    /// Copies stored before elements were kept apart have no index: they hold a single element.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        data = try container.decode(Data.self, forKey: .data)
        itemIndex = try container.decodeIfPresent(Int.self, forKey: .itemIndex) ?? 0
    }
}
