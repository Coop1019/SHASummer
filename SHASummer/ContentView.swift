import SwiftUI

struct ContentView: View {
    @ObservedObject var controller: HashingController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SHASummer 2.0")
                .font(.system(size: 28, weight: .semibold))

            Text("Calculate a file's SHA-256 hash and copy it to the clipboard.")
                .foregroundColor(.secondary)

            Divider()

            Text("Selected File")
                .font(.headline)

            Text(controller.selectedFilePath)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(controller.selectedURL == nil ? .secondary : .primary)
                .fixedSize(horizontal: false, vertical: true)

            Button(controller.isHashing ? "Calculating…" : "Select File") {
                controller.promptForFileSelection()
            }
            .disabled(controller.isHashing)

            Divider()

            Text("SHA-256")
                .font(.headline)

            Text(controller.hashDisplayValue)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(controller.hashValue.isEmpty ? .secondary : .primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(controller.statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)

            Spacer()

            Text("© 2026 LeComp Simulation Services LLC")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(width: 680, height: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(controller: HashingController())
    }
}
