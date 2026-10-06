import SwiftUI
import CryptoKit

struct ActivationView: View {
    @AppStorage("SONCHOIGAME_KEY_VERIFIED") private var verified = false
    @Environment(\.openURL) private var openURL
    @State private var key = ""
    @State private var status = ""
    @State private var badKey = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, Color(red: 0.12, green: 0.01, blue: 0.22)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    Image("Avatar").resizable().scaledToFill().frame(width: 92, height: 92).clipShape(Circle()).overlay(Circle().stroke(.purple, lineWidth: 3)).shadow(color: .purple.opacity(0.8), radius: 18)
                    Text("SONCHOIGAME").font(.system(size: 30, weight: .black)).foregroundStyle(.white)
                    Text("KÍCH HOẠT P12 TOOL").font(.caption.bold()).foregroundStyle(.purple.opacity(0.9))

                    VStack(alignment: .leading, spacing: 9) {
                        Label("Kích hoạt một lần duy nhất", systemImage: "checkmark.shield.fill").font(.headline).foregroundStyle(.white)
                        Text("Sau khi xác minh key thành công, ứng dụng sẽ ghi nhớ trạng thái kích hoạt trên thiết bị. Những lần mở sau bạn có thể vào thẳng công cụ mà không cần nhập lại key.")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.72))
                    }.padding(16).background(.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 18))

                    SecureField("Nhập key kích hoạt", text: $key)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .padding().background(.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 16)).foregroundStyle(.white)

                    Button(action: verify) { Label("XÁC NHẬN KEY", systemImage: "key.fill").frame(maxWidth: .infinity).padding() }
                        .buttonStyle(.borderedProminent).tint(.purple)

                    Button { openURL(AppConfig.getKeyURL) } label: { Label("LẤY KEY TẠI ĐÂY", systemImage: "link").frame(maxWidth: .infinity).padding(10) }.buttonStyle(.bordered).tint(.purple)
                    Button { openURL(AppConfig.telegramURL) } label: { Label("NHÓM TELEGRAM", systemImage: "paperplane.fill").frame(maxWidth: .infinity).padding(10) }.buttonStyle(.bordered).tint(.purple)

                    if !status.isEmpty { Text(status).font(.footnote.bold()).foregroundStyle(badKey ? .red : .green) }
                    Text("SONCHOIGAME • P12 Certificate Utility").font(.caption2).foregroundStyle(.white.opacity(0.4)).padding(.top, 8)
                }.padding(24).frame(maxWidth: 520)
            }
        }
    }

    private func verify() {
        let clean = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { badKey = true; status = "Vui lòng nhập key."; return }
        let digest = SHA256.hash(data: Data(clean.utf8)).map { String(format: "%02x", $0) }.joined()
        if digest.caseInsensitiveCompare(AppConfig.keySHA256) == .orderedSame {
            badKey = false; status = "✓ Kích hoạt thành công"
            UserDefaults.standard.set(true, forKey: "SONCHOIGAME_KEY_VERIFIED")
            openURL(AppConfig.telegramURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { verified = true }
        } else {
            badKey = true; status = "✕ Key không hợp lệ"
        }
    }
}
