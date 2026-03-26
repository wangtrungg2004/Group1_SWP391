-- Script tạo các tài khoản mẫu cho hệ thống ITServiceFlow
-- Database: ITServiceFlow
-- Table: Users

-- Kiểm tra và lấy DepartmentId và LocationId hợp lệ đầu tiên (hoặc NULL nếu không có)
DECLARE @DefaultDeptId INT;
DECLARE @DefaultLocId INT;

-- Lấy DepartmentId đầu tiên có sẵn, nếu không có thì dùng NULL
SELECT TOP 1 @DefaultDeptId = Id FROM Departments ORDER BY Id;
-- Nếu không có Departments, set NULL
IF @DefaultDeptId IS NULL SET @DefaultDeptId = NULL;

-- Lấy LocationId đầu tiên có sẵn, nếu không có thì dùng NULL
SELECT TOP 1 @DefaultLocId = Id FROM Locations ORDER BY Id;
-- Nếu không có Locations, set NULL
IF @DefaultLocId IS NULL SET @DefaultLocId = NULL;

-- Tạo tài khoản Admin (chỉ tạo nếu chưa tồn tại)
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'admin')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('admin', 'admin@itserviceflow.com', '123456', N'Nguyễn Văn Admin', 'Admin', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: admin';
END
ELSE
BEGIN
    PRINT 'Tài khoản admin đã tồn tại, bỏ qua.';
END

-- Tạo tài khoản Manager
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'manager1')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('manager1', 'manager1@itserviceflow.com', '123456', N'Trần Thị Manager', 'Manager', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: manager1';
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'manager2')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('manager2', 'manager2@itserviceflow.com', '123456', N'Lê Văn Quản Lý', 'Manager', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: manager2';
END

-- Tạo tài khoản User thông thường
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user1')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('user1', 'user1@itserviceflow.com', '123456', N'Phạm Văn User', 'User', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: user1';
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user2')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('user2', 'user2@itserviceflow.com', '123456', N'Hoàng Thị Nhân Viên', 'User', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: user2';
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user3')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('user3', 'user3@itserviceflow.com', '123456', N'Vũ Văn Người Dùng', 'User', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: user3';
END

-- Tạo tài khoản IT Support
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'itsupport1')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('itsupport1', 'itsupport1@itserviceflow.com', '123456', N'Đỗ Văn IT Support', 'IT Support', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: itsupport1';
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'itsupport2')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('itsupport2', 'itsupport2@itserviceflow.com', '123456', N'Bùi Thị Hỗ Trợ', 'IT Support', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: itsupport2';
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'itsupport3')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('itsupport3', 'itsupport3@itserviceflow.com', '123456', N'Ngô Văn Kỹ Thuật', 'IT Support', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
    PRINT 'Đã tạo tài khoản: itsupport3';
END

-- Kiểm tra kết quả
SELECT Username, Email, FullName, Role, IsActive, CreatedAt 
FROM Users 
ORDER BY Role, Username;
