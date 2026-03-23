USE [ITServiceFlow];
GO

-- Sample users for login/forgot-password flow.
-- Raw default password for all users: 123456
-- Stored as SHA-256 lowercase hex to match PasswordUtil.sha256().
DECLARE @PwdHash NVARCHAR(255) = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2));
DECLARE @DefaultDeptId INT;
DECLARE @DefaultLocId INT;

SELECT TOP 1 @DefaultDeptId = Id FROM dbo.Departments ORDER BY Id;
SELECT TOP 1 @DefaultLocId = Id FROM dbo.Locations ORDER BY Id;

-- LocationId is NOT NULL + FK in Users, create one if missing.
IF @DefaultLocId IS NULL
BEGIN
    INSERT INTO dbo.Locations (Name, Code, IsActive)
    VALUES (N'Head Office', 'HO', 1);
    SET @DefaultLocId = SCOPE_IDENTITY();
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = 'admin')
BEGIN
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('admin', 'admin@itserviceflow.com', @PwdHash, N'Admin Account', 'Admin', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = 'manager1')
BEGIN
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('manager1', 'manager1@itserviceflow.com', @PwdHash, N'Manager One', 'Manager', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = 'user1')
BEGIN
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('user1', 'user1@itserviceflow.com', @PwdHash, N'End User One', 'User', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = 'user2')
BEGIN
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('user2', 'user2@itserviceflow.com', @PwdHash, N'End User Two', 'User', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = 'itsupport1')
BEGIN
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('itsupport1', 'itsupport1@itserviceflow.com', @PwdHash, N'IT Support One', 'IT Support', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = 'itsupport2')
BEGIN
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
    VALUES ('itsupport2', 'itsupport2@itserviceflow.com', @PwdHash, N'IT Support Two', 'IT Support', @DefaultDeptId, @DefaultLocId, 1, GETDATE());
END;
GO

SELECT Id, Username, Email, FullName, Role, IsActive, CreatedAt
FROM dbo.Users
ORDER BY Role, Username;
GO
