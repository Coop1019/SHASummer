import AppKit
import CryptoKit
import SwiftUI

final class HashingController: ObservableObject {
    @Published private(set) var selectedURL: URL?
    @Published private(set) var hashValue = ""
    @Published private(set) var statusMessage = "Select a file to calculate its SHA-256 hash."
    @Published private(set) var isHashing = false

    var selectedFilePath: String {
        selectedURL?.path ?? "No file selected"
    }

    var hashDisplayValue: String {
        hashValue.isEmpty ? "The SHA-256 hash will appear here." : hashValue
    }

    func promptForFileSelection() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "Hash"

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        hashFile(at: url)
    }

    func open(urls: [URL], quitWhenFinished: Bool) {
        guard let url = urls.first else {
            return
        }

        hashFile(at: url, quitWhenFinished: quitWhenFinished)
    }

    private func hashFile(at url: URL, quitWhenFinished: Bool = false) {
        selectedURL = url
        hashValue = ""
        statusMessage = "Calculating SHA-256…"
        isHashing = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let digest = try FileHasher.sha256(for: url)

                DispatchQueue.main.async {
                    Clipboard.copy(digest)
                    self.hashValue = digest
                    self.statusMessage = "SHA-256 copied to the clipboard."
                    self.isHashing = false

                    if quitWhenFinished {
                        NSApp.terminate(nil)
                    }
                }
            } catch {
                let message = "Couldn't hash \(url.lastPathComponent): \(error.localizedDescription)"

                DispatchQueue.main.async {
                    self.hashValue = ""
                    self.statusMessage = message
                    self.isHashing = false
                    self.presentError(message: message)

                    if quitWhenFinished {
                        NSApp.terminate(nil)
                    }
                }
            }
        }
    }

    private func presentError(message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Hashing Failed"
        alert.informativeText = message
        alert.runModal()
    }
}

private enum Clipboard {
    static func copy(_ value: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }
}

private enum FileHasher {
    static func sha256(for url: URL) throws -> String {
        let didAccessSecurityScopedResource = url.startAccessingSecurityScopedResource()
        defer {
            if didAccessSecurityScopedResource {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let fileHandle = try FileHandle(forReadingFrom: url)
        defer {
            try? fileHandle.close()
        }

        let bufferSize = 1024 * 1024
        var hasher = SHA256()

        while autoreleasepool(invoking: {
            let data = fileHandle.readData(ofLength: bufferSize)
            guard !data.isEmpty else {
                return false
            }

            hasher.update(data: data)
            return true
        }) { }

        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private let hashingController = HashingController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView(controller: hashingController)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 360),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.center()
        window.title = "SHASummer"
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

        self.window = window
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        hashingController.open(urls: urls, quitWhenFinished: true)
    }
}
