import AppShell
import CoreText
import Foundation
import SwiftUI

@main
struct ReadingSocietyApp: App {
    init() {
        AppFontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

private enum AppFontRegistrar {
    static func registerFonts() {
        [
            "CormorantGaramond[wght]",
            "IBMPlexMono-Regular",
            "IBMPlexMono-Medium",
            "Inter[opsz,wght]"
        ].forEach(registerFont(named:))
    }

    private static func registerFont(named name: String) {
        let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
            ?? Bundle.main.url(forResource: name, withExtension: "ttf")

        guard let url else {
            return
        }

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
