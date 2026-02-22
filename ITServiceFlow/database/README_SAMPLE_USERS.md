# Hướng dẫn tạo tài khoản mẫu

File này hướng dẫn cách tạo các tài khoản mẫu cho hệ thống ITServiceFlow.

## Có 2 cách để tạo tài khoản mẫu:

### Cách 1: Sử dụng Script SQL (Khuyến nghị)

1. Mở SQL Server Management Studio (SSMS)
2. Kết nối đến database `ITServiceFlow`
3. Mở file `database/sample_users.sql`
4. Chạy script SQL
5. Kiểm tra kết quả

### Cách 2: Sử dụng Servlet Web

1. Khởi động ứng dụng web
2. Truy cập URL: `http://localhost:8080/ITServiceFlow/CreateSampleUsers`
3. Servlet sẽ tự động tạo các tài khoản mẫu
4. Xem kết quả trên trang web

## Danh sách tài khoản mẫu:

### Admin (1 tài khoản)
- **Username:** admin
- **Password:** 123456
- **Email:** admin@itserviceflow.com
- **Full Name:** Nguyễn Văn Admin
- **Role:** Admin

### Manager (2 tài khoản)
- **Username:** manager1
- **Password:** 123456
- **Email:** manager1@itserviceflow.com
- **Full Name:** Trần Thị Manager
- **Role:** Manager

- **Username:** manager2
- **Password:** 123456
- **Email:** manager2@itserviceflow.com
- **Full Name:** Lê Văn Quản Lý
- **Role:** Manager

### User (3 tài khoản)
- **Username:** user1
- **Password:** 123456
- **Email:** user1@itserviceflow.com
- **Full Name:** Phạm Văn User
- **Role:** User

- **Username:** user2
- **Password:** 123456
- **Email:** user2@itserviceflow.com
- **Full Name:** Hoàng Thị Nhân Viên
- **Role:** User

- **Username:** user3
- **Password:** 123456
- **Email:** user3@itserviceflow.com
- **Full Name:** Vũ Văn Người Dùng
- **Role:** User

### IT Support (3 tài khoản)
- **Username:** itsupport1
- **Password:** 123456
- **Email:** itsupport1@itserviceflow.com
- **Full Name:** Đỗ Văn IT Support
- **Role:** IT Support

- **Username:** itsupport2
- **Password:** 123456
- **Email:** itsupport2@itserviceflow.com
- **Full Name:** Bùi Thị Hỗ Trợ
- **Role:** IT Support

- **Username:** itsupport3
- **Password:** 123456
- **Email:** itsupport3@itserviceflow.com
- **Full Name:** Ngô Văn Kỹ Thuật
- **Role:** IT Support

## Lưu ý:

1. **Tất cả mật khẩu mặc định:** 123456
2. **Script sẽ kiểm tra:** Nếu username đã tồn tại thì sẽ bỏ qua (không tạo lại)
3. **DepartmentId và LocationId:** Được set mặc định là 1, 2, 3, 4 (cần đảm bảo các ID này tồn tại trong database)
4. **IsActive:** Tất cả tài khoản đều được set là Active (1)
5. **CreatedAt:** Tự động set là thời gian hiện tại

## Sau khi tạo xong:

1. Đăng nhập với bất kỳ tài khoản nào ở trên
2. Kiểm tra phân quyền:
   - Admin → AdminDashboard.jsp
   - Manager/User → UserDashboard.jsp
   - IT Support → ITDashboard.jsp

## Xóa tài khoản mẫu (nếu cần):

```sql
DELETE FROM Users WHERE Username IN (
    'admin', 'manager1', 'manager2', 
    'user1', 'user2', 'user3', 
    'itsupport1', 'itsupport2', 'itsupport3'
);
```
