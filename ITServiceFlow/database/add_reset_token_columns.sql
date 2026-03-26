-- Thêm cột cho chức năng Quên mật khẩu
-- Chạy script này trên database ITServiceFlow (SQL Server)

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'ResetToken'
)
BEGIN
    ALTER TABLE dbo.Users ADD ResetToken NVARCHAR(255) NULL;
    PRINT 'Added column: ResetToken';
END

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'ResetTokenExpiry'
)
BEGIN
    ALTER TABLE dbo.Users ADD ResetTokenExpiry DATETIME NULL;
    PRINT 'Added column: ResetTokenExpiry';
END
GO
