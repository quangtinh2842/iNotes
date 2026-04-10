## Các việc đã làm trong dự án `iNotes`

- **Khởi tạo app iOS bằng SwiftUI**
  - Tạo entry point `iNotesApp`, cấu hình `AppDelegate`, gọi `FirebaseApp.configure()`.
  - Thiết lập luồng vào app theo trạng thái đăng nhập (`MainEntryView`).

- **Xây dựng luồng xác thực người dùng**
  - Màn hình đăng nhập email/password (`LogInView`).
  - Tích hợp `FirebaseAuth` để `signIn`, xử lý lỗi và trạng thái loading/toast.
  - Lấy user hiện tại từ Firebase, tạo model `MUser`.
  - Thêm đăng xuất (`MUser.signOutEverywhere`) ở `ProfileView`.

- **Thiết kế mô hình dữ liệu**
  - Tạo base model `MBase` cho CRUD + mapping + validation.
  - Tạo model `MNote` (id, uid, nội dung, thời gian tạo/sửa, trạng thái sync).
  - Tạo model `MUser` (uid, provider, email, avatar...).
  - Dùng `ObjectMapper` để map JSON <-> model.

- **Tích hợp Firebase Realtime Database**
  - Viết logic query danh sách note theo user.
  - Lưu/cập nhật note lên Firebase qua `save()` ở `MBase`.
  - Xóa note trên Firebase (`MNote.deleteWithId`, `FirebaseManager.deleteNotes`).

- **Tích hợp Realm cho local storage**
  - Tạo `RealmManager` để khởi tạo DB, insert/update/delete note.
  - Đọc note local theo `uid`.
  - Kết hợp Realm + Firebase để hỗ trợ offline-first.

- **Xây dựng cơ chế đồng bộ offline/online**
  - Theo dõi mạng bằng `Reachability` (`ReachabilityHelper`).
  - Đồng bộ note chưa sync khi có mạng (`wasSynced == false`).
  - Dọn “spare notes” trên Firebase so với local.
  - Lưu cờ “đã từng lưu trên thiết bị” bằng `UserDefaultsHelper` để quyết định ưu tiên load local hay cloud.

- **Xây UI chính của ứng dụng**
  - `MainTabView` với 2 tab: Home + Profile.
  - `HomeView`: danh sách note, thêm note, sửa note, xóa note.
  - `EditNoteView`: chỉnh sửa note bằng `TextEditor`, auto cập nhật `changedTime`.
  - Hiển thị thời gian “time ago” và icon trạng thái sync cloud.

- **Xây khu vực hồ sơ và thông tin phụ**
  - `ProfileView`: hiển thị thông tin user, avatar (Kingfisher), UID, logout.
  - `TOSView`: trang Terms of Service.
  - `ResourcesView` + `ResourcesStore`: danh sách tài nguyên tham khảo.

- **Viết lớp observer/view-model cho từng màn hình**
  - `HomeViewObserver`, `EditNoteViewObserver`, `LogInViewObserver`, `ProfileViewObserver`.

- **Bổ sung tiện ích dùng chung**
  - `Date` extension: format timestamp + “x minutes ago”.
  - `CommonTypes`: typealias callback, enum query/validation, `processAfterSignIn`.

- **Cấu hình project & dependencies**
  - Thêm CocoaPods (`Podfile`, `Pods`).
  - Tích hợp nhiều thư viện: Firebase (Auth/Database/...),
    Realm, ObjectMapper, AlertToast, HUD, Kingfisher, Reachability.
  - Thêm `GoogleService-Info.plist` để kết nối Firebase.