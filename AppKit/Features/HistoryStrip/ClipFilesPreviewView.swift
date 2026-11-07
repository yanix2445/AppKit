import AppKit
import AppKitCore
import SwiftUI
import UniformTypeIdentifiers

/// The icon and the name of copied files, or what is left of a file that has gone.
struct ClipFilesPreviewView: View {
    let files: [ClipFile]

    @AppStorage(ProtectedFolderConsent.anyGrantedKey) private var consentRevision = 0
    @State private var isMissing = false
    @State private var icon: NSImage?

    private var first: ClipFile? { files.first }

    var body: some View {
        VStack(spacing: Spacing.small) {
            if isMissing {
                Image(systemName: "questionmark.folder")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text("Introuvable")
                    .font(.callout.weight(.semibold))
            } else {
                Image(nsImage: icon ?? NSWorkspace.shared.icon(for: .data))
                    .resizable()
                    .frame(width: StripMetrics.filePreviewIconSize, height: StripMetrics.filePreviewIconSize)
                    .accessibilityHidden(true)
            }
            Text(verbatim: first?.name ?? "")
                .font(.callout.weight(.semibold))
                .lineLimit(1)
                .truncationMode(.middle)
            if isMissing {
                Text("Déplacé ou supprimé")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, Spacing.medium)
        .task(id: consentRevision) { refresh() }
    }

    /// Reads nothing in a protected folder before the user has agreed.
    private func refresh() {
        guard let first, ProtectedFolderConsent.allowsReading(first.path) else { return }
        isMissing = !first.exists
        if !isMissing {
            icon = NSWorkspace.shared.icon(forFile: first.path)
        }
    }
}
