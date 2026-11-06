/// Tells how much room is left for the history.
public protocol DiskSpaceService: Sendable {
    func availableBytes() -> Int64?
}
