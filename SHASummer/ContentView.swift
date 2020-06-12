//
//  ContentView.swift
//  SHASummer
//
//  Created by Cooper LeComp on 6/11/20.
//  Copyright © 2020 Cooper LeComp. All rights reserved.
//

import SwiftUI
import CommonCrypto

//Formula for calcuating SHA1 source
func sha1(url: URL) -> String {
    do {
        let bufferSize = 1024 * 1024
        // Open file for reading:
        let file = try FileHandle(forReadingFrom: url)
        defer {
            file.closeFile()
        }

        // Create and initialize SHA256 context:
        var context = CC_SHA1_CTX()
        CC_SHA1_Init(&context)

        // Read up to `bufferSize` bytes, until EOF is reached, and update SHA256 context:
        while autoreleasepool(invoking: {
            // Read up to `bufferSize` bytes
            let data = file.readData(ofLength: bufferSize)
            if data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_SHA1_Update(&context, $0, numericCast(data.count))
                }
                // Continue
                return true
            } else {
                // End of file
                return false
            }
        }) { }

        // Compute the SHA256 digest:
        var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes {
            _ = CC_SHA1_Final($0, &context)
        }

        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    } catch {
        print(error)
        return " "
    }
}

func copyToClipBoard(textToCopy: String) {
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.setString(textToCopy, forType: .string)
}

var selectedURL: URL?
var shasum: String = " "

func setShaSum(inString: String) -> Void{
    shasum = inString
}

struct ContentView: View {
    
    @State var A_selectedURL: URL?
    @State var A_shasum: String = " "
    
    var body: some View {
        VStack {
            Group {
                Text("SHASummer").font(.title)
                Divider()
            }
            Group {
                if self.A_selectedURL != nil {
                    Text("Selected: \(self.A_selectedURL!.absoluteString)").frame(height: 50)
                } else {
                    Text("No selection").frame(height: 50)
                }
                Button(action: {
                    let panel = NSOpenPanel()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let result = panel.runModal()
                        if result == .OK {
                            self.A_selectedURL = panel.url
                            let passURL: URL = self.A_selectedURL!
                            self.A_shasum = sha1(url: passURL)
                            copyToClipBoard(textToCopy: self.A_shasum)
                        }
                    }
                })
                {
                Text("Select file")
                }
                Text(" ")
            }
            Group {
                Text("SHA1 SUM:").font(.headline)
                Text(" ")
                Text(self.A_shasum).fontWeight(.bold)
                Text(" ")
                Text("SHA1 sum is automatically copied to the clipboard").italic().fontWeight(.light)
                Divider()
            }
            Group {
                Text("© 2020 LeComp Simulation Services LLC")
            }
            
        }
        .frame(width: 640, height: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
