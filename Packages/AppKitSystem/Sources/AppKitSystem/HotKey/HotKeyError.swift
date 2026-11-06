public enum HotKeyError: Error, Equatable {
    case alreadyTaken
    case failed(Int32)
}
