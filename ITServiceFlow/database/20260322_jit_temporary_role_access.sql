SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.TemporaryRoleRequests (
            Id INT IDENTITY(1,1) NOT NULL
                CONSTRAINT PK_TemporaryRoleRequests PRIMARY KEY,
            UserId INT NOT NULL,
            CurrentRole NVARCHAR(50) NOT NULL,
            RequestedRole NVARCHAR(50) NOT NULL,
            Reason NVARCHAR(500) NULL,
            DurationMinutes INT NOT NULL,
            Status NVARCHAR(20) NOT NULL
                CONSTRAINT DF_TemporaryRoleRequests_Status DEFAULT ('Pending'),
            RequestedAt DATETIME NOT NULL
                CONSTRAINT DF_TemporaryRoleRequests_RequestedAt DEFAULT (GETDATE()),
            ReviewedBy INT NULL,
            ReviewComment NVARCHAR(500) NULL,
            ReviewedAt DATETIME NULL,
            ApprovedAt DATETIME NULL,
            ExpiresAt DATETIME NULL,
            RevokedAt DATETIME NULL
        );
    END;

    -- Backfill/sanitize existing rows (for older environments)
    IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NOT NULL
    BEGIN
        UPDATE dbo.TemporaryRoleRequests
        SET Status = 'Pending'
        WHERE Status IS NULL
           OR Status NOT IN ('Pending', 'Approved', 'Rejected', 'Revoked', 'Expired');

        UPDATE dbo.TemporaryRoleRequests
        SET DurationMinutes = 60
        WHERE DurationMinutes IS NULL
           OR DurationMinutes < 30
           OR DurationMinutes > 480;

        UPDATE dbo.TemporaryRoleRequests
        SET RequestedAt = GETDATE()
        WHERE RequestedAt IS NULL;
    END;

    -- Recreate status check safely
    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_TemporaryRoleRequests_Status'
          AND parent_object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
    )
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests
        DROP CONSTRAINT CK_TemporaryRoleRequests_Status;
    END;

    ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
    ADD CONSTRAINT CK_TemporaryRoleRequests_Status
        CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Revoked', 'Expired'));

    -- Recreate duration check safely
    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_TemporaryRoleRequests_Duration'
          AND parent_object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
    )
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests
        DROP CONSTRAINT CK_TemporaryRoleRequests_Duration;
    END;

    ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
    ADD CONSTRAINT CK_TemporaryRoleRequests_Duration
        CHECK (DurationMinutes BETWEEN 30 AND 480);

    -- Foreign key: requester
    IF OBJECT_ID('dbo.FK_TemporaryRoleRequests_User', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
        ADD CONSTRAINT FK_TemporaryRoleRequests_User
            FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
    END;

    -- Foreign key: reviewer
    IF OBJECT_ID('dbo.FK_TemporaryRoleRequests_Reviewer', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
        ADD CONSTRAINT FK_TemporaryRoleRequests_Reviewer
            FOREIGN KEY (ReviewedBy) REFERENCES dbo.Users(Id);
    END;

    -- Helpful index for user view + active-check
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_TemporaryRoleRequests_UserStatus'
          AND object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
    )
    BEGIN
        CREATE INDEX IX_TemporaryRoleRequests_UserStatus
            ON dbo.TemporaryRoleRequests (UserId, Status, ExpiresAt);
    END;

    -- Helpful index for approver queue
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_TemporaryRoleRequests_StatusRequestedAt'
          AND object_id = OBJECT_ID('dbo.TemporaryRoleRequests')
    )
    BEGIN
        CREATE INDEX IX_TemporaryRoleRequests_StatusRequestedAt
            ON dbo.TemporaryRoleRequests (Status, RequestedAt DESC);
    END;

    COMMIT TRANSACTION;
    PRINT 'TemporaryRoleRequests migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();

    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
END CATCH;
GO