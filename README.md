# SONCHOIGAME P12 TOOL

Ứng dụng iOS SwiftUI theo đúng luồng đã chốt:

- Lần đầu: nhập key -> SHA-256 so với hash -> lưu trạng thái kích hoạt -> mở Telegram.
- Các lần sau: vào thẳng P12 Tool.
- Lấy key: https://tasksub.io/NMiObz
- Telegram: https://t.me/sonchoigame23
- Chọn `.p12` + `.mobileprovision`.
- Nhập pass cũ, pass mới, xác nhận và tên mới.
- Đổi password P12 bằng OpenSSL.
- Mobileprovision KHÔNG sửa nội dung, chỉ copy + đổi tên.
- Tạo `pass.txt` chứa pass mới.
- Đóng gói 3 file thành `<Tên>.zip` và mở Share Sheet để Save to Files/chia sẻ.

## Tạo Xcode project

Project dùng XcodeGen để tránh phải gửi một `.pbxproj` sinh thủ công.

1. Trên macOS cài Xcode + XcodeGen.
2. Trong thư mục này chạy: `xcodegen generate`
3. Mở `SONCHOIGAME.xcodeproj`.
4. Chọn Signing Team của bạn.
5. Build lên iPhone hoặc Archive để xuất IPA theo phương thức ký bạn đang dùng.

Dependency OpenSSL đã khai báo trong `project.yml` bằng Swift Package `21-DOT-DEV/swift-openssl` 0.1.0, product `libcrypto`.

## Lưu ý bảo mật

Cơ chế key hiện tại là hash nằm trong app, giống code nguồn bạn đưa. Nó phù hợp với yêu cầu hiện tại nhưng không chống reverse-engineering mạnh. Muốn quản lý/revoke key từ xa thì cần chuyển xác minh sang server/API.
