import SwiftUI

struct P12ToolView: View {
    @Environment(\.openURL) private var openURL

    private enum PickerTarget: String, Identifiable {
        case p12, provision
        var id: String { rawValue }
    }

    @State private var activePicker: PickerTarget?
    @State private var p12URL: URL?
    @State private var provisionURL: URL?
    @State private var oldPass = ""
    @State private var newPass = ""
    @State private var confirm = ""
    @State private var outputName = "SONCHOIGAME"
    @State private var showOld = false
    @State private var showNew = false
    @State private var showConfirm = false
    @State private var status = "Sẵn sàng • Chọn file và nhập mật khẩu để bắt đầu."
    @State private var statusOK = true
    @State private var outputURL: URL?
    @State private var showShare = false
    @State private var isProcessing = false

    private let accent = Color(red: 0.72, green: 0.12, blue: 1.0)
    private let card = Color(red: 0.075, green: 0.055, blue: 0.11)

    private var version: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0" }
    private var build: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1" }

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    hero
                    filesCard
                    passwordCard
                    outputCard
                    processButton
                    statusCard
                    if outputURL != nil { shareButton }
                    links
                    footer
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 34)
                .frame(maxWidth: 650)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activePicker) { target in
            SystemDocumentPicker(
                onPick: { url in importPickedFile(url, for: target) },
                onCancel: { activePicker = nil }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showShare) {
            if let outputURL { ShareSheet(items: [outputURL]) }
        }
    }

    private var background: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [
                    Color(red: 0.035, green: 0.012, blue: 0.06),
                    Color(red: 0.09, green: 0.018, blue: 0.14),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle().fill(accent.opacity(0.24)).frame(width: 330, height: 330).blur(radius: 105).offset(x: 180, y: -230)
            Circle().fill(Color.purple.opacity(0.16)).frame(width: 360, height: 360).blur(radius: 115).offset(x: -190, y: 420)
        }
        .ignoresSafeArea()
    }

    private var hero: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image("Avatar")
                    .resizable().scaledToFill()
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(accent, lineWidth: 2))
                    .shadow(color: accent.opacity(0.55), radius: 14)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SONCHOIGAME")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.65)
                    Text("P12 CERTIFICATE TOOL")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(accent)
                    Label("LOCAL • PRIVATE", systemImage: "circle.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.green)
                }
                Spacer(minLength: 0)
            }

            HStack {
                Label("CERTIFICATE MANAGER", systemImage: "checkmark.shield.fill")
                Spacer()
                Text("Version \(version) • Build \(build)")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white.opacity(0.55))
        }
        .padding(18)
        .background(panelBackground)
    }

    private var filesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("CHỌN TỆP", icon: "folder.fill", subtitle: "Chọn P12 và MobileProvision để xử lý")

            fileRow(
                title: "P12 / PFX",
                subtitle: p12URL?.lastPathComponent ?? "Chạm để chọn file .p12 hoặc .pfx",
                icon: "key.fill",
                selected: p12URL != nil
            ) { activePicker = .p12 }

            fileRow(
                title: "MobileProvision",
                subtitle: provisionURL?.lastPathComponent ?? "Chạm để chọn file .mobileprovision",
                icon: "doc.badge.gearshape.fill",
                selected: provisionURL != nil
            ) { activePicker = .provision }
        }
        .padding(16)
        .background(panelBackground)
    }

    private var passwordCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            title("MẬT KHẨU", icon: "lock.fill", subtitle: "Nhập mật khẩu hiện tại và mật khẩu mới")
            passwordRow("Mật khẩu P12 hiện tại", text: $oldPass, visible: $showOld, icon: "key.fill")
            passwordRow("Mật khẩu P12 mới", text: $newPass, visible: $showNew, icon: "lock.fill")
            passwordRow("Xác nhận mật khẩu mới", text: $confirm, visible: $showConfirm, icon: "checkmark.lock.fill")
        }
        .padding(16)
        .background(panelBackground)
    }

    private var outputCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            title("TÊN FILE ĐẦU RA", icon: "doc.badge.plus", subtitle: "Đặt tên cho bộ chứng chỉ mới")
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil").foregroundStyle(accent)
                TextField("SONCHOIGAME", text: $outputName)
                    .foregroundStyle(.white).tint(accent)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                Text(".zip").foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 14).frame(height: 54)
            .background(fieldBackground)
        }
        .padding(16)
        .background(panelBackground)
    }

    private var processButton: some View {
        Button(action: process) {
            HStack(spacing: 10) {
                if isProcessing { ProgressView().tint(.white) } else { Image(systemName: "bolt.fill") }
                Text(isProcessing ? "ĐANG XỬ LÝ..." : "XỬ LÝ & TẠO ZIP")
                    .font(.system(size: 16, weight: .black))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: 60)
            .background(LinearGradient(colors: [Color.purple, accent], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.22), lineWidth: 1))
            .shadow(color: accent.opacity(0.45), radius: 14, y: 5)
        }
        .buttonStyle(.plain).disabled(isProcessing)
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: statusOK ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
            Text(status).font(.system(size: 12, weight: .semibold))
            Spacer()
        }
        .foregroundStyle(statusOK ? Color.green : Color.orange)
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill((statusOK ? Color.green : Color.orange).opacity(0.09)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke((statusOK ? Color.green : Color.orange).opacity(0.24)))
    }

    private var shareButton: some View {
        Button { showShare = true } label: {
            Label("LƯU / CHIA SẺ ZIP", systemImage: "square.and.arrow.up.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(RoundedRectangle(cornerRadius: 17).fill(Color.green.opacity(0.16)))
                .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color.green.opacity(0.35)))
        }.buttonStyle(.plain)
    }

    private var links: some View {
        HStack(spacing: 10) {
            Button { openURL(AppConfig.telegramURL) } label: {
                Label("NHÓM TELEGRAM", systemImage: "paperplane.fill")
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(fieldBackground)
            }
            Button { statusOK = true; status = "Chọn P12/PFX + MobileProvision, nhập mật khẩu rồi nhấn XỬ LÝ & TẠO ZIP." } label: {
                Label("HƯỚNG DẪN", systemImage: "info.circle.fill")
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(fieldBackground)
            }
        }
        .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 5) {
            Text("P12 được xử lý trực tiếp trên thiết bị.")
            Text("MobileProvision chỉ được sao chép và đổi tên, không chỉnh sửa nội dung.")
            Text("SONCHOIGAME • Version \(version) (\(build))").padding(.top, 4)
        }
        .font(.system(size: 9, weight: .medium))
        .foregroundStyle(.white.opacity(0.38))
        .multilineTextAlignment(.center)
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(card.opacity(0.92))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white.opacity(0.055))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }

    private func title(_ text: String, icon: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(.white.opacity(0.8)).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(text).font(.system(size: 15, weight: .black)).foregroundStyle(.white)
                Text(subtitle).font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    private func fileRow(title: String, subtitle: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill((selected ? Color.green : accent).opacity(0.16)).frame(width: 52, height: 52)
                    Image(systemName: selected ? "checkmark.circle.fill" : icon)
                        .font(.system(size: 21, weight: .bold)).foregroundStyle(selected ? .green : accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    Text(subtitle).font(.system(size: 11, weight: .medium)).foregroundStyle(selected ? Color.green : Color.white.opacity(0.46)).lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.32))
            }
            .padding(12).background(fieldBackground)
        }.buttonStyle(.plain)
    }

    private func passwordRow(_ placeholder: String, text: Binding<String>, visible: Binding<Bool>, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(accent).frame(width: 20)
            Group {
                if visible.wrappedValue { TextField(placeholder, text: text) }
                else { SecureField(placeholder, text: text) }
            }
            .foregroundStyle(.white).tint(accent).textInputAutocapitalization(.never).autocorrectionDisabled()
            Button { visible.wrappedValue.toggle() } label: {
                Image(systemName: visible.wrappedValue ? "eye.slash.fill" : "eye.fill").foregroundStyle(.white.opacity(0.48))
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 14).frame(height: 52).background(fieldBackground)
    }

    private func importPickedFile(_ source: URL, for target: PickerTarget) {
        activePicker = nil
        let ext = source.pathExtension.lowercased()
        let valid = target == .p12 ? ["p12", "pfx"].contains(ext) : ext == "mobileprovision"
        guard valid else {
            statusOK = false
            status = target == .p12 ? "Sai định dạng. Hãy chọn file .p12 hoặc .pfx." : "Sai định dạng. Hãy chọn file .mobileprovision."
            return
        }

        do {
            let folder = FileManager.default.temporaryDirectory.appendingPathComponent("SONCHOIGAME-Imports", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let destination = folder.appendingPathComponent(UUID().uuidString + "-" + source.lastPathComponent)
            try? FileManager.default.removeItem(at: destination)

            let access = source.startAccessingSecurityScopedResource()
            defer { if access { source.stopAccessingSecurityScopedResource() } }
            try FileManager.default.copyItem(at: source, to: destination)

            if target == .p12 { p12URL = destination } else { provisionURL = destination }
            outputURL = nil
            statusOK = true
            status = "Đã nhập: \(source.lastPathComponent)"
        } catch {
            statusOK = false
            status = "Không thể nhập file: \(error.localizedDescription)"
        }
    }

    private func process() {
        outputURL = nil
        guard let p12URL else { statusOK = false; status = "Hãy chọn file P12/PFX."; return }
        guard let provisionURL else { statusOK = false; status = "Hãy chọn file MobileProvision."; return }
        guard !oldPass.isEmpty else { statusOK = false; status = "Hãy nhập mật khẩu P12 hiện tại."; return }
        guard !newPass.isEmpty else { statusOK = false; status = "Hãy nhập mật khẩu P12 mới."; return }
        guard newPass == confirm else { statusOK = false; status = "Mật khẩu xác nhận không khớp."; return }

        let clean = outputName.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "\\", with: "_")
        guard !clean.isEmpty else { statusOK = false; status = "Tên file đầu ra không được để trống."; return }

        isProcessing = true
        defer { isProcessing = false }
        do {
            let input = try Data(contentsOf: p12URL)
            let changed = try P12Bridge.changePassword(input, oldPassword: oldPass, newPassword: newPass)
            let provision = try Data(contentsOf: provisionURL)
            let pass = Data(newPass.utf8)
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("\(clean).zip")
            try? FileManager.default.removeItem(at: tmp)
            try ZipWriter.makeZip(files: [("\(clean).p12", changed), ("\(clean).mobileprovision", provision), ("pass.txt", pass)], to: tmp)
            outputURL = tmp
            statusOK = true
            status = "Hoàn tất • Đã tạo \(clean).zip"
        } catch {
            outputURL = nil
            statusOK = false
            status = "Lỗi: \(error.localizedDescription)"
        }
    }
}
