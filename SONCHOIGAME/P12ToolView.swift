import SwiftUI

struct P12ToolView: View {
    @Environment(\.openURL) private var openURL
    @State private var p12URL: URL?
    @State private var provisionURL: URL?
    @State private var oldPass = ""
    @State private var newPass = ""
    @State private var confirm = ""
    @State private var outputName = "SONCHOIGAME"
    @State private var status = ""
    @State private var outputURL: URL?
    @State private var showShare = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, Color(red: 0.11, green: 0.01, blue: 0.20)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) { Image("Avatar").resizable().scaledToFill().frame(width: 54, height: 54).clipShape(Circle()).overlay(Circle().stroke(.purple, lineWidth: 2)); VStack(alignment: .leading) { Text("SONCHOIGAME").font(.title2.weight(.black)); Text("P12 CERTIFICATE TOOL").font(.caption.bold()).foregroundStyle(.purple) }; Spacer() }
                        .foregroundStyle(.white)

                        FileImporterButton(title: "Chọn file .p12", extensions: ["p12", "pfx"], selectedURL: $p12URL)
                        FileImporterButton(title: "Chọn .mobileprovision", extensions: ["mobileprovision"], selectedURL: $provisionURL)

                        Group {
                            SecureField("Mật khẩu P12 hiện tại", text: $oldPass)
                            SecureField("Mật khẩu P12 mới", text: $newPass)
                            SecureField("Xác nhận mật khẩu mới", text: $confirm)
                            TextField("Tên bộ chứng chỉ mới", text: $outputName)
                        }.padding().background(.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 15)).foregroundStyle(.white)

                        Button(action: process) { Label("XỬ LÝ & TẠO ZIP", systemImage: "bolt.fill").frame(maxWidth: .infinity).padding() }.buttonStyle(.borderedProminent).tint(.purple)

                        if !status.isEmpty { Text(status).font(.footnote.bold()).foregroundStyle(outputURL == nil ? .orange : .green).multilineTextAlignment(.center) }
                        if outputURL != nil {
                            Button { showShare = true } label: { Label("LƯU / CHIA SẺ ZIP", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity).padding(10) }.buttonStyle(.bordered).tint(.purple)
                        }
                        Divider().overlay(.white.opacity(0.2))
                        Button { openURL(AppConfig.telegramURL) } label: { Label("NHÓM TELEGRAM", systemImage: "paperplane.fill") }.tint(.purple)
                        Text("Đổi mật khẩu P12 cục bộ trên thiết bị. Mobileprovision chỉ được sao chép và đổi tên, không chỉnh sửa nội dung.").font(.caption).foregroundStyle(.white.opacity(0.5)).multilineTextAlignment(.center)
                    }.padding(20).frame(maxWidth: 560)
                }
            }.navigationBarHidden(true)
        }.sheet(isPresented: $showShare) { if let outputURL { ShareSheet(items: [outputURL]) } }
    }

    private func process() {
    outputURL = nil

    guard let p12URL, let provisionURL else {
        status = "Hãy chọn đủ .p12 và .mobileprovision."
        return
    }

    guard !oldPass.isEmpty, !newPass.isEmpty else {
        status = "Hãy nhập mật khẩu cũ và mật khẩu mới."
        return
    }

    guard newPass == confirm else {
        status = "Mật khẩu xác nhận không khớp."
        return
    }

    let clean = outputName
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "/", with: "_")

    guard !clean.isEmpty else {
        status = "Tên mới không được để trống."
        return
    }

    do {
        let p12Access = p12URL.startAccessingSecurityScopedResource()
        defer {
            if p12Access {
                p12URL.stopAccessingSecurityScopedResource()
            }
        }

        let provAccess = provisionURL.startAccessingSecurityScopedResource()
        defer {
            if provAccess {
                provisionURL.stopAccessingSecurityScopedResource()
            }
        }

        let input = try Data(contentsOf: p12URL)

        guard let changed = P12Bridge.changePassword(
            input,
            oldPassword: oldPass,
            newPassword: newPass
        ) else {
            throw NSError(
                domain: "SONCHOIGAME",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Không thể đổi mật khẩu P12."
                ]
            )
        }

        let provision = try Data(contentsOf: provisionURL)
        let pass = Data(newPass.utf8)

        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(clean).zip")

        try? FileManager.default.removeItem(at: tmp)

        try ZipWriter.makeZip(
            files: [
                ("\(clean).p12", changed),
                ("\(clean).mobileprovision", provision),
                ("pass.txt", pass)
            ],
            to: tmp
        )

        outputURL = tmp
        status = """
        ✓ Hoàn tất: \(clean).zip
        Gồm P12 mới + mobileprovision đổi tên + pass.txt
        """

    } catch {
        status = "Lỗi: \(error.localizedDescription)"
    }
}
}
