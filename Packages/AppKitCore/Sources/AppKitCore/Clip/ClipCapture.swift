/// A new copy and, for an image or a PDF, all its formats.
public struct ClipCapture: Sendable {
    public let clip: Clip
    public let formats: [ClipRepresentation]

    public init(clip: Clip, formats: [ClipRepresentation] = []) {
        self.clip = clip
        self.formats = formats
    }
}
