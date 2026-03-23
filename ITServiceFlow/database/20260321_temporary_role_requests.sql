IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TemporaryRoleRequests (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        CurrentRole NVARCHAR(50) NOT NULL,
        RequestedRole NVARCHAR(50) NOT NULL,
        Reason NVARCHAR(500) NULL,
        DurationMinutes INT NOT NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        RequestedAt DATETIME NOT NULL DEFAULT GETDATE(),
        ReviewedBy INT NULL,
        ReviewComment NVARCHAR(500) NULL,
        ReviewedAt DATETIME NULL,
        ApprovedAt DATETIME NULL,
        ExpiresAt DATETIME NULL,
        RevokedAt DATETIME NULL,
        CONSTRAINT FK_TemporaryRoleRequests_User
            FOREIGN KEY (UserId) REFERENCES dbo.Users(Id),
        CONSTRAINT FK_TemporaryRoleRequests_Reviewer
            FOREIGN KEY (ReviewedBy) REFERENCES dbo.Users(Id),
        CONSTRAINT CK_TemporaryRoleRequests_Status
            CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Revoked', 'Expired')),
        CONSTRAINT CK_TemporaryRoleRequests_Duration
            CHECK (DurationMinutes BETWEEN 30 AND 480)
    );
END
GO

IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_TemporaryRoleRequests_Status'
          AND parent_object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
    )
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests
        DROP CONSTRAINT CK_TemporaryRoleRequests_Status;
    END

    ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
    ADD CONSTRAINT CK_TemporaryRoleRequests_Status
        CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Revoked', 'Expired'));
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_TemporaryRoleRequests_UserStatus'
      AND object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
)
BEGIN
    CREATE INDEX IX_TemporaryRoleRequests_UserStatus
        ON dbo.TemporaryRoleRequests (UserId, Status, ExpiresAt);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_TemporaryRoleRequests_StatusRequestedAt'
      AND object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
)
BEGIN
    CREATE INDEX IX_TemporaryRoleRequests_StatusRequestedAt
        ON dbo.TemporaryRoleRequests (Status, RequestedAt DESC);
END
GO
