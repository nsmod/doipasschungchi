import SwiftUI
import UniformTypeIdentifiers

struct FileImporterButton: View {
    let title: String
    let extensions: [String]
    @Binding var selectedURL: URL?
    @State private var showing = false

    var body: some View {
        Button { showing = true } label: {
            HStack { Image(systemName: "doc.badge.plus"); VStack(alignment: .leading) { Text(title).bold(); Text(selectedURL?.lastPathComponent ?? "Chưa chọn file").font(.caption).opacity(0.7) }; Spacer(); Image(systemName: "chevron.right") }
                .padding().background(.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 16))
        }.buttonStyle(.plain)
        .fileImporter(isPresented: $showing, allowedContentTypes: extensions.compactMap { UTType(filenameExtension: $0) }, allowsMultipleSelection: false) { result in
            if case .success(let urls) = result { selectedURL = urls.first }
        }
    }
}
