import SwiftUI
import UniformTypeIdentifiers

struct P12ToolView: View {

    @Environment(\.openURL) private var openURL

    // MARK: - File
    @State private var p12URL: URL?
    @State private var provisionURL: URL?

    @State private var showP12Picker = false
    @State private var showProvisionPicker = false

    // MARK: - Input
    @State private var oldPass = ""
    @State private var newPass = ""
    @State private var confirm = ""
    @State private var outputName = "SONCHOIGAME"

    // MARK: - Password visibility
    @State private var showOldPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false

    // MARK: - Status
    @State private var status = ""
    @State private var outputURL: URL?
    @State private var showShare = false
    @State private var isProcessing = false

    private let accent = Color(
        red: 0.78,
        green: 0.16,
        blue: 1.00
    )

    private var versionText: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0"
    }

    private var buildText: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(
                    .vertical,
                    showsIndicators: false
                ) {
                    VStack(spacing: 22) {

                        header

                        fileSection

                        passwordSection

                        outputSection

                        processButton

                        statusSection

                        if outputURL != nil {
                            shareButton
                        }

                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                    .frame(
                        maxWidth: 620,
                        alignment: .center
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }

        // MARK: P12 Picker
        .fileImporter(
            isPresented: $showP12Picker,
            allowedContentTypes: p12Types,
            allowsMultipleSelection: false
        ) { result in
            handleP12Import(result)
        }

        // MARK: Provision Picker
        .fileImporter(
            isPresented: $showProvisionPicker,
            allowedContentTypes: provisionTypes,
            allowsMultipleSelection: false
        ) { result in
            handleProvisionImport(result)
        }

        // MARK: Share
        .sheet(isPresented: $showShare) {
            if let outputURL {
                ShareSheet(items: [outputURL])
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black,
                    Color(
                        red: 0.055,
                        green: 0.015,
                        blue: 0.085
                    ),
                    Color(
                        red: 0.12,
                        green: 0.015,
                        blue: 0.20
                    )
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(accent.opacity(0.16))
                .frame(
                    width: 360,
                    height: 360
                )
                .blur(radius: 100)
                .offset(
                    x: -170,
                    y: 400
                )

            Circle()
                .fill(
                    Color.blue.opacity(0.08)
                )
                .frame(
                    width: 300,
                    height: 300
                )
                .blur(radius: 100)
                .offset(
                    x: 170,
                    y: -300
                )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 18) {

            HStack(spacing: 15) {

                ZStack {
                    Circle()
                        .fill(accent.opacity(0.18))
                        .frame(
                            width: 76,
                            height: 76
                        )

                    Image("Avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: 68,
                            height: 68
                        )
                        .clipShape(Circle())
                }
                .overlay {
                    Circle()
                        .stroke(
                            accent,
                            lineWidth: 2
                        )
                }
                .shadow(
                    color: accent.opacity(0.55),
                    radius: 14
                )

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text("SONCHOIGAME")
                        .font(
                            .system(
                                size: 27,
                                weight: .black,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text("P12 CERTIFICATE TOOL")
                        .font(
                            .system(
                                size: 14,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(accent)

                    HStack(spacing: 5) {
                        Circle()
                            .fill(.green)
                            .frame(
                                width: 7,
                                height: 7
                            )

                        Text("LOCAL PROCESSING")
                            .font(
                                .system(
                                    size: 10,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                .white.opacity(0.55)
                            )
                    }
                }

                Spacer()
            }

            HStack {
                Label(
                    "P12 TOOL",
                    systemImage: "lock.shield.fill"
                )

                Spacer()

                Text(
                    "v\(versionText) • Build \(buildText)"
                )
            }
            .font(
                .system(
                    size: 11,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                .white.opacity(0.6)
            )
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Files

    private var fileSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                "CHỨNG CHỈ",
                icon: "doc.badge.gearshape"
            )

            fileButton(
                title: "Chọn file P12",
                subtitle: p12URL?.lastPathComponent
                    ?? "Hỗ trợ .p12 và .pfx",
                icon: "key.horizontal.fill",
                selected: p12URL != nil
            ) {
                showP12Picker = true
            }

            fileButton(
                title: "Chọn MobileProvision",
                subtitle: provisionURL?.lastPathComponent
                    ?? "Chọn file .mobileprovision",
                icon: "doc.badge.plus",
                selected: provisionURL != nil
            ) {
                showProvisionPicker = true
            }
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
            HStack(spacing: 14) {

                ZStack {
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                    .fill(
                        selected
                            ? Color.green.opacity(0.16)
                            : accent.opacity(0.16)
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )

                    Image(
                        systemName: selected
                            ? "checkmark.circle.fill"
                            : icon
                    )
                    .font(.system(size: 22))
                    .foregroundStyle(
                        selected
                            ? .green
                            : accent
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(title)
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(
                            .system(
                                size: 12,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            selected
                                ? Color.green
                                : Color.white.opacity(0.52)
                        )
                        .lineLimit(1)
                }

                Spacer()

                Image(
                    systemName: "chevron.right"
                )
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    .white.opacity(0.35)
                )
            }
            .padding(15)
            .background {
                RoundedRectangle(
                    cornerRadius: 20
                )
                .fill(
                    Color.white.opacity(0.075)
                )
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 20
                )
                .stroke(
                    selected
                        ? Color.green.opacity(0.35)
                        : Color.white.opacity(0.10),
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Password

    private var passwordSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                "MẬT KHẨU",
                icon: "lock.fill"
            )

            passwordField(
                title: "Mật khẩu P12 hiện tại",
                text: $oldPass,
                visible: $showOldPassword
            )

            passwordField(
                title: "Mật khẩu P12 mới",
                text: $newPass,
                visible: $showNewPassword
            )

            passwordField(
                title: "Xác nhận mật khẩu mới",
                text: $confirm,
                visible: $showConfirmPassword
            )
        }
    }

    private func passwordField(
        title: String,
        text: Binding<String>,
        visible: Binding<Bool>
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: "lock.fill")
                .foregroundStyle(accent)
                .frame(width: 22)

            Group {
                if visible.wrappedValue {
                    TextField(
                        title,
                        text: text
                    )
                } else {
                    SecureField(
                        title,
                        text: text
                    )
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundStyle(.white)
            .tint(accent)

            Button {
                visible.wrappedValue.toggle()
            } label: {
                Image(
                    systemName:
                        visible.wrappedValue
                        ? "eye.slash.fill"
                        : "eye.fill"
                )
                .foregroundStyle(
                    .white.opacity(0.55)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 58)
        .background {
            RoundedRectangle(
                cornerRadius: 17
            )
            .fill(
                Color.white.opacity(0.075)
            )
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 17
            )
            .stroke(
                Color.white.opacity(0.10),
                lineWidth: 1
            )
        }
    }

    // MARK: - Output

    private var outputSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                "TÊN FILE ĐẦU RA",
                icon: "square.and.pencil"
            )

            HStack(spacing: 12) {
                Image(
                    systemName: "archivebox.fill"
                )
                .foregroundStyle(accent)

                TextField(
                    "Tên bộ chứng chỉ",
                    text: $outputName
                )
                .foregroundStyle(.white)
                .tint(accent)

                Text(".zip")
                    .foregroundStyle(
                        .white.opacity(0.4)
                    )
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background {
                RoundedRectangle(
                    cornerRadius: 17
                )
                .fill(
                    Color.white.opacity(0.075)
                )
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 17
                )
                .stroke(
                    Color.white.opacity(0.10),
                    lineWidth: 1
                )
            }
        }
    }

    // MARK: - Process Button

    private var processButton: some View {
        Button {
            process()
        } label: {
            HStack(spacing: 10) {

                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(
                        systemName: "bolt.fill"
                    )
                }

                Text(
                    isProcessing
                        ? "ĐANG XỬ LÝ..."
                        : "XỬ LÝ & TẠO ZIP"
                )
                .font(
                    .system(
                        size: 16,
                        weight: .black
                    )
                )
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                LinearGradient(
                    colors: [
                        accent,
                        Color(
                            red: 0.48,
                            green: 0.08,
                            blue: 0.92
                        )
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 19
                )
            )
            .shadow(
                color: accent.opacity(0.35),
                radius: 16,
                y: 6
            )
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
        .opacity(
            isProcessing ? 0.7 : 1
        )
    }

    // MARK: - Status

    @ViewBuilder
    private var statusSection: some View {
        if !status.isEmpty {
            HStack(
                alignment: .top,
                spacing: 10
            ) {
                Image(
                    systemName:
                        outputURL == nil
                        ? "exclamationmark.triangle.fill"
                        : "checkmark.circle.fill"
                )

                Text(status)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )

                Spacer()
            }
            .foregroundStyle(
                outputURL == nil
                    ? Color.orange
                    : Color.green
            )
            .padding(15)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background {
                RoundedRectangle(
                    cornerRadius: 16
                )
                .fill(
                    outputURL == nil
                        ? Color.orange.opacity(0.10)
                        : Color.green.opacity(0.10)
                )
            }
        }
    }

    // MARK: - Share

    private var shareButton: some View {
        Button {
            showShare = true
        } label: {
            Label(
                "LƯU / CHIA SẺ FILE ZIP",
                systemImage: "square.and.arrow.up.fill"
            )
            .font(
                .system(
                    size: 15,
                    weight: .bold
                )
            )
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(
                    cornerRadius: 18
                )
                .fill(
                    Color.green.opacity(0.16)
                )
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 18
                )
                .stroke(
                    Color.green.opacity(0.35),
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 16) {

            Divider()
                .overlay(
                    Color.white.opacity(0.12)
                )

            Button {
                openURL(
                    AppConfig.telegramURL
                )
            } label: {
                HStack(spacing: 10) {
                    Image(
                        systemName: "paperplane.fill"
                    )

                    Text("NHÓM TELEGRAM")
                        .fontWeight(.bold)
                }
                .foregroundStyle(accent)
            }

            Text(
                "P12 được xử lý trực tiếp trên thiết bị. MobileProvision chỉ được sao chép và đổi tên."
            )
            .font(.system(size: 11))
            .foregroundStyle(
                .white.opacity(0.42)
            )
            .multilineTextAlignment(.center)

            Text(
                "SONCHOIGAME • v\(versionText) (\(buildText))"
            )
            .font(
                .system(
                    size: 10,
                    weight: .bold
                )
            )
            .foregroundStyle(
                .white.opacity(0.28)
            )
        }
        .padding(.top, 4)
    }

    // MARK: - Section title

    private func sectionTitle(
        _ title: String,
        icon: String
    ) -> some View {

        HStack(spacing: 7) {
            Image(systemName: icon)
                .foregroundStyle(accent)

            Text(title)
                .foregroundStyle(
                    .white.opacity(0.72)
                )
        }
        .font(
            .system(
                size: 12,
                weight: .bold
            )
        )
    }

    // MARK: - UTTypes

    private var p12Types: [UTType] {
        var types: [UTType] = []

        if let p12 = UTType(
            filenameExtension: "p12"
        ) {
            types.append(p12)
        }

        if let pfx = UTType(
            filenameExtension: "pfx"
        ) {
            types.append(pfx)
        }

        if types.isEmpty {
            types.append(.data)
        }

        return types
    }

    private var provisionTypes: [UTType] {
        if let type = UTType(
            filenameExtension: "mobileprovision"
        ) {
            return [type]
        }

        return [.data]
    }

    // MARK: - Import P12

    private func handleP12Import(
        _ result: Result<[URL], Error>
    ) {
        switch result {

        case .success(let urls):

            guard let url = urls.first else {
                return
            }

            p12URL = url
            outputURL = nil

            status =
                "✓ Đã chọn P12: \(url.lastPathComponent)"

        case .failure(let error):

            status =
                "Không thể chọn P12: \(error.localizedDescription)"
        }
    }

    // MARK: - Import Provision

    private func handleProvisionImport(
        _ result: Result<[URL], Error>
    ) {
        switch result {

        case .success(let urls):

            guard let url = urls.first else {
                return
            }

            provisionURL = url
            outputURL = nil

            status =
                "✓ Đã chọn: \(url.lastPathComponent)"

        case .failure(let error):

            status =
                "Không thể chọn MobileProvision: \(error.localizedDescription)"
        }
    }

    // MARK: - Process

    private func process() {

        outputURL = nil
        status = ""

        guard let p12URL else {
            status = "Hãy chọn file .p12 trước."
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

        guard newPass == confirm else {
            status =
                "Mật khẩu xác nhận không khớp."
            return
        }

        let clean = outputName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "/",
                with: "_"
            )
            .replacingOccurrences(
                of: "\\",
                with: "_"
            )

        guard !clean.isEmpty else {
            status =
                "Tên file đầu ra không được để trống."
            return
        }

        isProcessing = true

        defer {
            isProcessing = false
        }

        do {
            let p12Access =
                p12URL.startAccessingSecurityScopedResource()

            defer {
                if p12Access {
                    p12URL
                        .stopAccessingSecurityScopedResource()
                }
            }

            let provisionAccess =
                provisionURL.startAccessingSecurityScopedResource()

            defer {
                if provisionAccess {
                    provisionURL
                        .stopAccessingSecurityScopedResource()
                }
            }

            let input = try Data(
                contentsOf: p12URL
            )

            let changed =
                try P12Bridge.changePassword(
                    input,
                    oldPassword: oldPass,
                    newPassword: newPass
                )

            let provision =
                try Data(
                    contentsOf: provisionURL
                )

            let pass =
                Data(newPass.utf8)

            let tmp =
                FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent(
                        "\(clean).zip"
                    )

            try? FileManager.default
                .removeItem(at: tmp)

            try ZipWriter.makeZip(
                files: [
                    (
                        "\(clean).p12",
                        changed
                    ),
                    (
                        "\(clean).mobileprovision",
                        provision
                    ),
                    (
                        "pass.txt",
                        pass
                    )
                ],
                to: tmp
            )

            outputURL = tmp

            status = """
            ✓ Xử lý thành công
            Đã tạo \(clean).zip
            """

        } catch {
            outputURL = nil

            status =
                "Lỗi: \(error.localizedDescription)"
        }
    }
}
