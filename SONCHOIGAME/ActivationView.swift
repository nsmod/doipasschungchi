import SwiftUI
import CryptoKit

struct ActivationView: View {
    @AppStorage("SONCHOIGAME_KEY_VERIFIED") private var verified = false
    @Environment(\.openURL) private var openURL

    @State private var key = ""
    @State private var status = ""
    @State private var badKey = false
    @State private var showKey = false

    private let accent = Color(red: 0.72, green: 0.22, blue: 1.0)

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.055, green: 0.02, blue: 0.09),
                    Color(red: 0.02, green: 0.018, blue: 0.035),
                    Color(red: 0.10, green: 0.02, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(accent.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 110)
                .offset(x: 160, y: -280)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer(minLength: 20)

                    Image("Avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 108, height: 108)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(accent, lineWidth: 2.5)
                        }
                        .shadow(color: accent.opacity(0.5), radius: 20)

                    VStack(spacing: 6) {
                        Text("SONCHOIGAME")
                            .font(.system(size: 31, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("P12 CERTIFICATE TOOL")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(accent)

                        Text("Version \(version) • Build \(build)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label("KÍCH HOẠT ỨNG DỤNG", systemImage: "checkmark.shield.fill")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)

                        Text("Nhập key để mở P12 Tool. Sau khi xác minh thành công, trạng thái kích hoạt được lưu trên thiết bị.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.58))
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 11) {
                            Image(systemName: "key.fill")
                                .foregroundStyle(accent)

                            Group {
                                if showKey {
                                    TextField("Nhập key kích hoạt", text: $key)
                                } else {
                                    SecureField("Nhập key kích hoạt", text: $key)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .foregroundStyle(.white)
                            .tint(accent)

                            Button {
                                showKey.toggle()
                            } label: {
                                Image(systemName: showKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 15)
                        .frame(height: 58)
                        .background(Color.black.opacity(0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(.white.opacity(0.09), lineWidth: 1)
                        }

                        Button(action: verify) {
                            Label("XÁC NHẬN KEY", systemImage: "bolt.fill")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background {
                                    LinearGradient(
                                        colors: [accent, Color(red: 0.46, green: 0.10, blue: 0.90)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        if !status.isEmpty {
                            Label(status, systemImage: badKey ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(badKey ? Color.orange : Color.green)
                                .padding(.top, 2)
                        }
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.09), lineWidth: 1)
                    }

                    HStack(spacing: 12) {
                        linkButton("LẤY KEY", icon: "link") {
                            openURL(AppConfig.getKeyURL)
                        }

                        linkButton("TELEGRAM", icon: "paperplane.fill") {
                            openURL(AppConfig.telegramURL)
                        }
                    }

                    Text("SONCHOIGAME • P12 Certificate Utility")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func linkButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.09), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func verify() {
        let clean = key.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !clean.isEmpty else {
            badKey = true
            status = "Vui lòng nhập key."
            return
        }

        let digest = SHA256.hash(data: Data(clean.utf8))
            .map { String(format: "%02x", $0) }
            .joined()

        if digest.caseInsensitiveCompare(AppConfig.keySHA256) == .orderedSame {
            badKey = false
            status = "Kích hoạt thành công"
            UserDefaults.standard.set(true, forKey: "SONCHOIGAME_KEY_VERIFIED")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                verified = true
            }
        } else {
            badKey = true
            status = "Key không hợp lệ"
        }
    }
}
