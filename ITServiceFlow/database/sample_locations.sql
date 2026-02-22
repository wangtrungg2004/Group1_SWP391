-- Script tạo dữ liệu mẫu cho bảng Locations
-- Database: ITServiceFlow
-- Table: Locations
-- LƯU Ý: Chạy script này TRƯỚC khi chạy sample_departments.sql vì LocationId là bắt buộc trong Departments

-- Cấu trúc bảng Locations: Id (PK), Name, IsActive (có thể có thêm các cột khác)

-- Xóa dữ liệu cũ nếu cần (tùy chọn)
-- DELETE FROM Locations;

-- Tạo các Location mẫu
-- Chỉ dùng các cột: Name và IsActive (Id tự động tăng)

IF NOT EXISTS (SELECT 1 FROM Locations WHERE Name = N'Hà Nội')
BEGIN
    INSERT INTO Locations (Name, IsActive)
    VALUES (N'Hà Nội', 1);
END

IF NOT EXISTS (SELECT 1 FROM Locations WHERE Name = N'Hồ Chí Minh')
BEGIN
    INSERT INTO Locations (Name, IsActive)
    VALUES (N'Hồ Chí Minh', 1);
END

IF NOT EXISTS (SELECT 1 FROM Locations WHERE Name = N'Đà Nẵng')
BEGIN
    INSERT INTO Locations (Name, IsActive)
    VALUES (N'Đà Nẵng', 1);
END

IF NOT EXISTS (SELECT 1 FROM Locations WHERE Name = N'Hải Phòng')
BEGIN
    INSERT INTO Locations (Name, IsActive)
    VALUES (N'Hải Phòng', 1);
END

-- Kiểm tra kết quả
SELECT Id, Name, IsActive 
FROM Locations 
ORDER BY Id;

-- Hiển thị thông báo
DECLARE @LocCount INT;
SELECT @LocCount = COUNT(*) FROM Locations;
PRINT 'Đã tạo ' + CAST(@LocCount AS VARCHAR) + ' locations mẫu.';
PRINT 'Bây giờ bạn có thể chạy script sample_departments.sql để tạo departments.';
