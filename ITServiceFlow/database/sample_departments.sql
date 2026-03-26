-- Script tạo dữ liệu mẫu cho bảng Departments
-- Database: ITServiceFlow
-- Table: Departments
-- Cấu trúc: Id (PK), Name, LocationId (NOT NULL), CategoryId, ManagerId, IsActive

-- LƯU Ý: LocationId là bắt buộc (NOT NULL), cần có Locations trong database trước
-- Chạy script sample_locations.sql trước hoặc đảm bảo có ít nhất 1 Location trong database

-- Lấy LocationId đầu tiên có sẵn (hoặc tạo mặc định nếu chưa có)
DECLARE @DefaultLocationId INT;

-- Lấy LocationId đầu tiên từ bảng Locations
SELECT TOP 1 @DefaultLocationId = Id FROM Locations ORDER BY Id;

-- Nếu không có Location nào, tạo một Location mặc định
IF @DefaultLocationId IS NULL
BEGIN
    INSERT INTO Locations (Name, IsActive)
    VALUES (N'Hà Nội', 1);
    SET @DefaultLocationId = SCOPE_IDENTITY();
    PRINT 'Đã tạo Location mặc định với ID: ' + CAST(@DefaultLocationId AS VARCHAR);
END

-- Tạo các Department mẫu với LocationId mặc định
IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'IT Department')
BEGIN
    INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive)
    VALUES (N'IT Department', @DefaultLocationId, NULL, NULL, 1);
END

IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'HR Department')
BEGIN
    INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive)
    VALUES (N'HR Department', @DefaultLocationId, NULL, NULL, 1);
END

IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'Finance Department')
BEGIN
    INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive)
    VALUES (N'Finance Department', @DefaultLocationId, NULL, NULL, 1);
END

IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'Operations Department')
BEGIN
    INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive)
    VALUES (N'Operations Department', @DefaultLocationId, NULL, NULL, 1);
END

IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'Sales Department')
BEGIN
    INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive)
    VALUES (N'Sales Department', @DefaultLocationId, NULL, NULL, 1);
END

IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'Marketing Department')
BEGIN
    INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive)
    VALUES (N'Marketing Department', @DefaultLocationId, NULL, NULL, 1);
END

-- Kiểm tra kết quả
SELECT Id, Name, LocationId, CategoryId, ManagerId, IsActive 
FROM Departments 
ORDER BY Id;

-- Hiển thị thông báo
DECLARE @Count INT;
SELECT @Count = COUNT(*) FROM Departments;
PRINT 'Đã tạo ' + CAST(@Count AS VARCHAR) + ' departments mẫu.';
