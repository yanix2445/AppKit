import AppKitCore
import AppKitSystem

public struct FakeFrontmostAppService: FrontmostAppService {
    private let source: ClipSource?

    public init(source: ClipSource?) {
        self.source = source
    }

    public func frontmostApp() -> ClipSource? {
        source
    }
}
