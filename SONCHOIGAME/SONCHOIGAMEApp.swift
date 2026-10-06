import SwiftUI

@main
struct SONCHOIGAMEApp: App {
    @AppStorage("SONCHOIGAME_KEY_VERIFIED") private var verified = false

    var body: some Scene {
        WindowGroup {
            if verified { P12ToolView() } else { ActivationView() }
        }
    }
}
