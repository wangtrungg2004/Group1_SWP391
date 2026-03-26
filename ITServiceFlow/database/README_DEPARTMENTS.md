# Hướng dẫn tạo dữ liệu Departments

## ⚠️ QUAN TRỌNG: Thứ tự chạy script

**LocationId là bắt buộc (NOT NULL) trong bảng Departments**, vì vậy bạn **PHẢI** chạy script Locations trước:

1. **Bước 1:** Chạy `sample_locations.sql` để tạo Locations
2. **Bước 2:** Chạy `sample_departments.sql` để tạo Departments

## Cách 1: Chạy Script SQL (Khuyến nghị)

### Bước 1: Tạo Locations
```sql
-- Chạy file database/sample_locations.sql trong SSMS
-- Sẽ tạo 4 locations: Hà Nội, Hồ Chí Minh, Đà Nẵng, Hải Phòng
```

### Bước 2: Tạo Departments
```sql
-- Chạy file database/sample_departments.sql trong SSMS
-- Script sẽ tự động:
--   - Lấy LocationId đầu tiên từ bảng Locations
--   - Nếu chưa có Location, sẽ tạo Location mặc định
--   - Tạo 6 departments với LocationId hợp lệ
```

## Cách 2: Sử dụng Web Interface

1. Đăng nhập với tài khoản Admin
2. Vào AdminDashboard → "Quản lý Departments"
3. **Quan trọng:** Đảm bảo đã có ít nhất 1 Location trong database
4. Điền form:
   - **Tên Department** (bắt buộc)
   - **Location ID** (bắt buộc) - Nhập ID của Location có sẵn
   - **Category ID** (tùy chọn)
   - **Manager ID** (tùy chọn)
   - **Trạng thái** (Active/Inactive)
5. Click "Tạo Department"

## Cấu trúc bảng Departments

- `Id` (INT, Identity/PRIMARY KEY)
- `Name` (NVARCHAR) - Tên department
- `LocationId` (INT, NOT NULL) - **BẮT BUỘC**
- `CategoryId` (INT, NULL) - Tùy chọn
- `ManagerId` (INT, NULL) - Tùy chọn
- `IsActive` (BIT) - Trạng thái

## Lưu ý

1. **LocationId là bắt buộc** - Không thể để NULL
2. Script SQL sẽ tự động lấy LocationId đầu tiên nếu không chỉ định
3. Nếu chưa có Location nào, script sẽ tạo Location mặc định
4. Khi tạo qua web, phải nhập LocationId hợp lệ (ID có trong bảng Locations)

## Sau khi tạo Departments

Sau khi có departments trong database, bạn có thể:
- Tạo user và gán DepartmentId hợp lệ
- Sử dụng DepartmentId khi tạo user mới
- Quản lý departments qua web interface
