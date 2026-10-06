import SwiftUI
import UniformTypeIdentifiers

struct P12ToolView: View {
    @Environment(\.openURL) private var openURL

    private enum PickerTarget {
        case p12
        case provision
    }

    @State private var pickerTarget: PickerTarget = .p12
    @State private var showFilePicker = false

    @State private var p12URL: URL?
    @State private var provisionURL: URL?

    @State private var oldPass = ""
    @State private var newPass = ""
    @State private var confirmPass = ""
    @State private var outputName = "SONCHOIGAME"

    @State private var showOldPass = false
    @State private var showNewPass = false
    @State private var showConfirmPass = false

    @State private var status = ""
    @State private var statusIsError = false
    @State private var outputURL: URL?
    @State private var showShare = false
    @State private var isProcessing = false

    private let accent = Color(red: 0.72, green: 0.22, blue: 1.0)
    private let card = Color.white.opacity(0.085)

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    private var allowedTypes: [UTType] {
        switch pickerTarget {
        case .p12:
            return [
                UTType(filenameExtension: "p12") ?? .data,
                UTType(filenameExtension: "pfx") ?? .data
            ]
        case .provision:
            return [UTType(filenameExtension: "mobileprovision") ?? .data]
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                        fileCard
                        passwordCard
                        outputCard
                        processButton

                        if !status.isEmpty {
                            statusCard
                        }

                        if outputURL != nil {
                            shareButton
                        }

                        footer
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 36)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: allowedTypes,
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .sheet(isPresented: $showShare) {
            if let outputURL {
                ShareSheet(items: [outputURL])
            }
        }
    }

    private var background: some View {
        ZStack {
            Color(red: 0.025, green: 0.02, blue: 0.04)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.025, blue: 0.10),
                    Color(red: 0.025, green: 0.02, blue: 0.04),
                    Color(red: 0.09, green: 0.02, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(accent.opacity(0.15))
                .frame(width: 360, height: 360)
                .blur(radius: 110)
                .offset(x: 170, y: -300)

            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 110)
                .offset(x: -170, y: 380)
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Image("Avatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(accent.opacity(0.9), lineWidth: 2)
                    }
                    .shadow(color: accent.opacity(0.45), radius: 14)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SONCHOIGAME")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("P12 CERTIFICATE TOOL")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(accent)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(.green)
                            .frame(width: 7, height: 7)
                        Text("LOCAL • PRIVATE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }

                Spacer(minLength: 0)
            }

            HStack {
                Label("CERTIFICATE MANAGER", systemImage: "checkmark.shield.fill")
                Spacer()
                Text("Version \(version) • Build \(build)")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white.opacity(0.5))
        }
        .padding(18)
        .background(card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        }
    }

    private var fileCard: some View {
        sectionCard(title: "CHỌN TỆP", icon: "folder.fill") {
            VStack(spacing: 12) {
                fileButton(
                    title: "P12 / PFX",
                    subtitle: p12URL?.lastPathComponent ?? "Chạm để chọn chứng chỉ",
                    icon: "key.fill",
                    selected: p12URL != nil
                ) {
                    pickerTarget = .p12
                    showFilePicker = true
                }

                fileButton(
                    title: "MobileProvision",
                    subtitle: provisionURL?.lastPathComponent ?? "Chạm để chọn provisioning profile",
                    icon: "doc.badge.gearshape",
                    selected: provisionURL != nil
                ) {
                    pickerTarget = .provision
                    showFilePicker = true
                }
            }
        }
    }

    private var passwordCard: some View {
        sectionCard(title: "MẬT KHẨU", icon: "lock.fill") {
            VStack(spacing: 12) {
                passwordField("Mật khẩu P12 hiện tại", text: $oldPass, visible: $showOldPass)
                passwordField("Mật khẩu P12 mới", text: $newPass, visible: $showNewPass)
                passwordField("Xác nhận mật khẩu mới", text: $confirmPass, visible: $showConfirmPass)
            }
        }
    }

    private var outputCard: some View {
        sectionCard(title: "ĐẦU RA", icon: "archivebox.fill") {
            HStack(spacing: 12) {
                Image(systemName: "doc.zipper")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 24)

                TextField("Tên file ZIP", text: $outputName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .tint(accent)

                Text(".zip")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 15)
            .frame(height: 56)
            .background(Color.black.opacity(0.22))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.09), lineWidth: 1)
            }
        }
    }

    private var processButton: some View {
        Button(action: process) {
            HStack(spacing: 10) {
                if isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "bolt.fill")
                }

                Text(isProcessing ? "ĐANG XỬ LÝ..." : "ĐỔI MẬT KHẨU & TẠO ZIP")
                    .font(.system(size: 15, weight: .black))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                LinearGradient(
                    colors: [accent, Color(red: 0.46, green: 0.10, blue: 0.90)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: accent.opacity(0.28), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
        .opacity(isProcessing ? 0.7 : 1)
    }

    private var statusCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: statusIsError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
            Text(status)
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .foregroundStyle(statusIsError ? Color.orange : Color.green)
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((statusIsError ? Color.orange : Color.green).opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var shareButton: some View {
        Button {
            showShare = true
        } label: {
            Label("LƯU / CHIA SẺ FILE ZIP", systemImage: "square.and.arrow.up.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.green.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.green.opacity(0.32), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 14) {
            Button {
                openURL(AppConfig.telegramURL)
            } label: {
                Label("NHÓM TELEGRAM", systemImage: "paperplane.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
            }

            Text("P12 được xử lý cục bộ trên thiết bị. MobileProvision được giữ nguyên nội dung và chỉ đổi tên trong file ZIP.")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.42))
                .multilineTextAlignment(.center)

            Text("SONCHOIGAME • Version \(version) (\(build))")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.28))
        }
        .padding(.top, 6)
    }

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.white.opacity(0.72))

            content()
        }
        .padding(16)
        .background(card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private func fileButton(
        title: String,
        subtitle: String,
        icon: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill((selected ? Color.green : accent).opacity(0.14))
                        .frame(width: 48, height: 48)

                    Image(systemName: selected ? "checkmark.circle.fill" : icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(selected ? Color.green : accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(selected ? Color.green : Color.white.opacity(0.48))
                        .lineLimit(1)
                }

                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.28))
            }
            .padding(12)
            .background(Color.black.opacity(0.20))
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(selected ? Color.green.opacity(0.25) : Color.white.opacity(0.07), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func passwordField(
        _ title: String,
        text: Binding<String>,
        visible: Binding<Bool>
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: "lock.fill")
                .foregroundStyle(accent)
                .frame(width: 22)

            Group {
                if visible.wrappedValue {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundStyle(.white)
            .tint(accent)

            Button {
                visible.wrappedValue.toggle()
            } label: {
                Image(systemName: visible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 15)
        .frame(height: 56)
        .background(Color.black.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            outputURL = nil
            statusIsError = false

            switch pickerTarget {
            case .p12:
                p12URL = url
                status = "Đã chọn P12: \(url.lastPathComponent)"
            case .provision:
                provisionURL = url
                status = "Đã chọn MobileProvision: \(url.lastPathComponent)"
            }

        case .failure(let error):
            statusIsError = true
            status = "Không thể chọn file: \(error.localizedDescription)"
        }
    }

    private func process() {
        outputURL = nil
        status = ""
        statusIsError = true

        guard let p12URL else {
            status = "Hãy chọn file .p12 hoặc .pfx."
            return
        }

        guard let provisionURL else {
            status = "Hãy chọn file .mobileprovision."
            return
        }

        guard !oldPass.isEmpty else {
            status = "Hãy nhập mật khẩu P12 hiện tại."
            return
        }

        guard !newPass.isEmpty else {
            status = "Hãy nhập mật khẩu P12 mới."
            return
        }

        guard newPass == confirmPass else {
            status = "Mật khẩu xác nhận không khớp."
            return
        }

        let clean = outputName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")

        guard !clean.isEmpty else {
            status = "Tên file đầu ra không được để trống."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            let p12Access = p12URL.startAccessingSecurityScopedResource()
            defer {
                if p12Access { p12URL.stopAccessingSecurityScopedResource() }
            }

            let provisionAccess = provisionURL.startAccessingSecurityScopedResource()
            defer {
                if provisionAccess { provisionURL.stopAccessingSecurityScopedResource() }
            }

            let input = try Data(contentsOf: p12URL)
            let changed = try P12Bridge.changePassword(
                input,
                oldPassword: oldPass,
                newPassword: newPass
            )

            let provision = try Data(contentsOf: provisionURL)
            let pass = Data(newPass.utf8)

            let output = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(clean).zip")

            try? FileManager.default.removeItem(at: output)

            try ZipWriter.makeZip(
                files: [
                    ("\(clean).p12", changed),
                    ("\(clean).mobileprovision", provision),
                    ("pass.txt", pass)
                ],
                to: output
            )

            outputURL = output
            statusIsError = false
            status = "Hoàn tất • Đã tạo \(clean).zip"
        } catch {
            outputURL = nil
            statusIsError = true
            status = "Lỗi: \(error.localizedDescription)"
        }
    }
}
