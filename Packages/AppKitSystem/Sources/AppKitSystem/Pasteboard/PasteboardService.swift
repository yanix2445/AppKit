import AppKitCore

/// Read and write access to a pasteboard.
public protocol PasteboardService: Sendable {
    var changeCount: Int { get }
    func readTypes() -> Set<String>
    func readText() -> String?
    /// A marker's value, such as the app that made the copy.
    func readString(forType type: String) -> String?
    /// The color on the pasteboard, in sRGB.
    func readColor() -> ClipColor?
    /// Every format of the copy, byte for byte.
    func readFormats() -> [ClipRepresentation]

    /// Replaces the content with this text, and returns the new change count.
    func write(text: String) -> Int
    /// Replaces the content with these formats, and returns the new change count.
    func write(formats: [ClipRepresentation]) -> Int
}
