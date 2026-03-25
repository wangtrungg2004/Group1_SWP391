SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME = GETDATE();
    DECLARE @PwdHash NVARCHAR(255) = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2));
    DECLARE @SeedTag NVARCHAR(100) = N'SEED-DEMO-FLOW';

    /* ============================================================
       0) Ensure required feature tables exist
       ============================================================ */
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
    SET RequestedAt = ISNULL(RequestedAt, GETDATE())
    WHERE RequestedAt IS NULL;

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

    IF OBJECT_ID('dbo.FK_TemporaryRoleRequests_User', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
        ADD CONSTRAINT FK_TemporaryRoleRequests_User
            FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
    END;

    IF OBJECT_ID('dbo.FK_TemporaryRoleRequests_Reviewer', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.TemporaryRoleRequests WITH CHECK
        ADD CONSTRAINT FK_TemporaryRoleRequests_Reviewer
            FOREIGN KEY (ReviewedBy) REFERENCES dbo.Users(Id);
    END;

    IF OBJECT_ID('dbo.SLAEscalationHistory', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.SLAEscalationHistory (
            Id INT IDENTITY(1,1) NOT NULL
                CONSTRAINT PK_SLAEscalationHistory PRIMARY KEY,
            TicketId INT NOT NULL,
            StageCode NVARCHAR(40) NOT NULL,
            StageLabel NVARCHAR(100) NOT NULL,
            ResolutionDeadline DATETIME NOT NULL,
            RemainingMinutes INT NULL,
            NotificationTargetType NVARCHAR(40) NOT NULL
                CONSTRAINT DF_SLAEscalationHistory_TargetType DEFAULT ('BROADCAST'),
            NotificationTargetId INT NULL,
            NotificationTitle NVARCHAR(200) NOT NULL,
            NotificationMessage NVARCHAR(1000) NOT NULL,
            AutoAction NVARCHAR(100) NULL,
            EscalatedToRole NVARCHAR(50) NULL,
            EscalatedToUserId INT NULL,
            TriggeredAt DATETIME NOT NULL
                CONSTRAINT DF_SLAEscalationHistory_TriggeredAt DEFAULT (GETDATE())
        );
    END;

    UPDATE dbo.SLAEscalationHistory
    SET StageCode = CASE
        WHEN StageCode IN ('NEAR_BREACH_2H', 'NEAR_BREACH_30M', 'BREACHED') THEN StageCode
        WHEN RemainingMinutes IS NOT NULL AND RemainingMinutes < 0 THEN 'BREACHED'
        WHEN RemainingMinutes IS NOT NULL AND RemainingMinutes <= 30 THEN 'NEAR_BREACH_30M'
        ELSE 'NEAR_BREACH_2H'
    END
    WHERE StageCode IS NULL
       OR StageCode NOT IN ('NEAR_BREACH_2H', 'NEAR_BREACH_30M', 'BREACHED');

    IF OBJECT_ID('dbo.FK_SLAEscalationHistory_Ticket', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.SLAEscalationHistory WITH CHECK
        ADD CONSTRAINT FK_SLAEscalationHistory_Ticket
            FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id);
    END;

    IF OBJECT_ID('dbo.FK_SLAEscalationHistory_TargetUser', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.SLAEscalationHistory WITH CHECK
        ADD CONSTRAINT FK_SLAEscalationHistory_TargetUser
            FOREIGN KEY (NotificationTargetId) REFERENCES dbo.Users(Id);
    END;

    IF OBJECT_ID('dbo.FK_SLAEscalationHistory_EscalatedUser', 'F') IS NULL
    BEGIN
        ALTER TABLE dbo.SLAEscalationHistory WITH CHECK
        ADD CONSTRAINT FK_SLAEscalationHistory_EscalatedUser
            FOREIGN KEY (EscalatedToUserId) REFERENCES dbo.Users(Id);
    END;

    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_SLAEscalationHistory_StageCode'
          AND parent_object_id = OBJECT_ID('dbo.SLAEscalationHistory')
    )
    BEGIN
        ALTER TABLE dbo.SLAEscalationHistory
        DROP CONSTRAINT CK_SLAEscalationHistory_StageCode;
    END;

    ALTER TABLE dbo.SLAEscalationHistory WITH CHECK
    ADD CONSTRAINT CK_SLAEscalationHistory_StageCode
        CHECK (StageCode IN ('NEAR_BREACH_2H', 'NEAR_BREACH_30M', 'BREACHED'));

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'UX_SLAEscalationHistory_TicketStageDeadline'
          AND object_id = OBJECT_ID('dbo.SLAEscalationHistory')
    )
    BEGIN
        CREATE UNIQUE INDEX UX_SLAEscalationHistory_TicketStageDeadline
            ON dbo.SLAEscalationHistory (TicketId, StageCode, ResolutionDeadline);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_SLAEscalationHistory_TriggeredAt'
          AND object_id = OBJECT_ID('dbo.SLAEscalationHistory')
    )
    BEGIN
        CREATE INDEX IX_SLAEscalationHistory_TriggeredAt
            ON dbo.SLAEscalationHistory (TriggeredAt DESC);
    END;

    /* ============================================================
       1) Baseline data: Location, Category, Priority
       ============================================================ */
    DECLARE @LocId INT = NULL;
    DECLARE @CategoryId INT = NULL;
    DECLARE @PriorityCritical INT = NULL;
    DECLARE @PriorityHigh INT = NULL;

    DECLARE @LocHasCode BIT = CASE WHEN COL_LENGTH('dbo.Locations', 'Code') IS NULL THEN 0 ELSE 1 END;
    DECLARE @LocHasIsActive BIT = CASE WHEN COL_LENGTH('dbo.Locations', 'IsActive') IS NULL THEN 0 ELSE 1 END;
    DECLARE @LocInsertSql NVARCHAR(MAX);

    SET @LocInsertSql = N'INSERT INTO dbo.Locations (Name';
    IF @LocHasCode = 1 SET @LocInsertSql += N', Code';
    IF @LocHasIsActive = 1 SET @LocInsertSql += N', IsActive';
    SET @LocInsertSql += N') VALUES (@Name';
    IF @LocHasCode = 1 SET @LocInsertSql += N', @Code';
    IF @LocHasIsActive = 1 SET @LocInsertSql += N', @IsActive';
    SET @LocInsertSql += N'); SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;';

    SELECT TOP 1 @LocId = Id
    FROM dbo.Locations
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'DEMO MINIMAL FLOW'
    ORDER BY Id;

    IF @LocId IS NULL AND @LocHasCode = 1
    BEGIN
        SELECT TOP 1 @LocId = Id
        FROM dbo.Locations
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(50))))) = N'DMFLOW'
        ORDER BY Id;
    END;

    IF @LocId IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @LocOut TABLE (NewId INT);
            INSERT INTO @LocOut (NewId)
            EXEC sp_executesql
                @LocInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @IsActive BIT',
                @Name = N'Demo Minimal Flow',
                @Code = N'DMFLOW',
                @IsActive = 1;
            SELECT TOP 1 @LocId = NewId FROM @LocOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                SELECT TOP 1 @LocId = Id
                FROM dbo.Locations
                WHERE UPPER(LTRIM(RTRIM(Name))) = N'DEMO MINIMAL FLOW'
                ORDER BY Id;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    IF @LocId IS NULL
    BEGIN
        SELECT TOP 1 @LocId = Id FROM dbo.Locations ORDER BY Id;
    END;

    IF @LocId IS NULL
    BEGIN
        THROW 53001, 'Cannot resolve LocationId for demo seed.', 1;
    END;

    SELECT TOP 1 @CategoryId = c.Id
    FROM dbo.Categories c
    WHERE UPPER(LTRIM(RTRIM(c.Name))) = N'DEMO MINIMAL FLOW CATEGORY'
    ORDER BY c.Id;

    IF @CategoryId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Categories (Name, ParentId, [Level], FullPath, IsActive)
            VALUES (N'Demo Minimal Flow Category', NULL, 1, N'Demo Minimal Flow Category', 1);
            SET @CategoryId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Categories (Name, IsActive)
                VALUES (N'Demo Minimal Flow Category', 1);
                SET @CategoryId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                BEGIN TRY
                    INSERT INTO dbo.Categories (Name)
                    VALUES (N'Demo Minimal Flow Category');
                    SET @CategoryId = SCOPE_IDENTITY();
                END TRY
                BEGIN CATCH
                    SELECT TOP 1 @CategoryId = Id FROM dbo.Categories ORDER BY Id;
                END CATCH
            END CATCH
        END CATCH;
    END;

    IF @CategoryId IS NULL
    BEGIN
        SELECT TOP 1 @CategoryId = Id FROM dbo.Categories ORDER BY Id;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Priorities)
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Priorities (Impact, Urgency, [Level], ResponseHours, ResolutionHours)
            VALUES
                (1, 1, N'Critical', 1, 4),
                (1, 2, N'High', 2, 8),
                (2, 2, N'Medium', 4, 24);
        END TRY
        BEGIN CATCH
            INSERT INTO dbo.Priorities ([Level])
            VALUES (N'Critical'), (N'High'), (N'Medium');
        END CATCH
    END;

    SELECT TOP 1 @PriorityCritical = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('critical', 'p1') ORDER BY Id;
    SELECT TOP 1 @PriorityHigh = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('high', 'p2') ORDER BY Id;

    IF @PriorityCritical IS NULL SELECT TOP 1 @PriorityCritical = Id FROM dbo.Priorities ORDER BY Id;
    IF @PriorityHigh IS NULL SELECT TOP 1 @PriorityHigh = Id FROM dbo.Priorities WHERE Id <> @PriorityCritical ORDER BY Id;
    IF @PriorityHigh IS NULL SET @PriorityHigh = @PriorityCritical;

    /* ============================================================
       2) Seed users (password for all: 123456)
       ============================================================ */
    DECLARE @SeedUsers TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50),
        Email NVARCHAR(150),
        FullName NVARCHAR(150),
        [Role] NVARCHAR(50),
        DepartmentId INT NULL
    );

    INSERT INTO @SeedUsers (Username, Email, FullName, [Role], DepartmentId)
    VALUES
        (N'demo.admin',   N'demo.admin@itserviceflow.local',   N'Demo Admin',   N'Admin',      NULL),
        (N'demo.manager', N'demo.manager@itserviceflow.local', N'Demo Manager', N'Manager',    NULL),
        (N'demo.it',      N'demo.it@itserviceflow.local',      N'Demo IT',      N'IT Support', NULL),
        (N'demo.user',    N'demo.user@itserviceflow.local',    N'Demo User',    N'User',       NULL);

    DECLARE
        @Ui INT = 1,
        @Umax INT,
        @Username NVARCHAR(50),
        @Email NVARCHAR(150),
        @FullName NVARCHAR(150),
        @Role NVARCHAR(50),
        @DepartmentId INT;

    SELECT @Umax = COUNT(*) FROM @SeedUsers;
    WHILE @Ui <= @Umax
    BEGIN
        SELECT
            @Username = Username,
            @Email = Email,
            @FullName = FullName,
            @Role = [Role],
            @DepartmentId = DepartmentId
        FROM @SeedUsers
        WHERE RowNo = @Ui;

        IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
        BEGIN
            UPDATE dbo.Users
            SET Email = @Email,
                FullName = @FullName,
                [Role] = @Role,
                PasswordHash = @PwdHash,
                DepartmentId = @DepartmentId,
                LocationId = @LocId,
                IsActive = 1
            WHERE Username = @Username;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, [Role], DepartmentId, LocationId, IsActive, CreatedAt)
            VALUES (@Username, @Email, @PwdHash, @FullName, @Role, @DepartmentId, @LocId, 1, @Now);
        END;

        SET @Ui = @Ui + 1;
    END;

    DECLARE
        @AdminId INT,
        @ManagerId INT,
        @ItId INT,
        @UserId INT;

    SELECT @AdminId = Id FROM dbo.Users WHERE Username = N'demo.admin';
    SELECT @ManagerId = Id FROM dbo.Users WHERE Username = N'demo.manager';
    SELECT @ItId = Id FROM dbo.Users WHERE Username = N'demo.it';
    SELECT @UserId = Id FROM dbo.Users WHERE Username = N'demo.user';

    IF @AdminId IS NULL OR @ManagerId IS NULL OR @ItId IS NULL OR @UserId IS NULL
    BEGIN
        THROW 53002, 'Cannot resolve seeded user ids.', 1;
    END;

    /* ============================================================
       3) Seed tickets
          - 1 ticket for Reopen flow
          - 1 ticket for SLA flow (deadline +5 minutes)
       ============================================================ */
    DECLARE @SeedTickets TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        TicketNumber NVARCHAR(50),
        Title NVARCHAR(255),
        [Status] NVARCHAR(30),
        CreatedBy INT,
        AssignedTo INT NULL,
        PriorityId INT NULL,
        Impact INT NULL,
        Urgency INT NULL,
        ResolvedOffsetMin INT NULL,
        ClosedOffsetMin INT NULL,
        SlaResponseOffsetMin INT NULL,
        SlaResolutionOffsetMin INT NULL
    );

    INSERT INTO @SeedTickets
        (TicketNumber, Title, [Status], CreatedBy, AssignedTo, PriorityId, Impact, Urgency, ResolvedOffsetMin, ClosedOffsetMin, SlaResponseOffsetMin, SlaResolutionOffsetMin)
    VALUES
        (N'INC-DEMO-REOPEN-001', N'Demo Reopen - user reopens resolved VPN incident', N'Resolved',    @UserId, @ItId, @PriorityHigh,     2, 2, -120, NULL, NULL, NULL),
        (N'INC-DEMO-SLA-001',    N'Demo SLA - should breach in about 5 minutes',      N'In Progress', @UserId, @ItId, @PriorityCritical, 1, 1, NULL, NULL,   2,    5);

    DECLARE
        @Ti INT = 1,
        @Tmax INT,
        @TicketNumber NVARCHAR(50),
        @Title NVARCHAR(255),
        @Status NVARCHAR(30),
        @CreatedBy INT,
        @AssignedTo INT,
        @PriorityId INT,
        @Impact INT,
        @Urgency INT,
        @ResolvedOffsetMin INT,
        @ClosedOffsetMin INT,
        @SlaResponseOffsetMin INT,
        @SlaResolutionOffsetMin INT,
        @TicketId INT,
        @ResolvedAt DATETIME,
        @ClosedAt DATETIME;

    SELECT @Tmax = COUNT(*) FROM @SeedTickets;
    WHILE @Ti <= @Tmax
    BEGIN
        SET @TicketId = NULL;

        SELECT
            @TicketNumber = TicketNumber,
            @Title = Title,
            @Status = [Status],
            @CreatedBy = CreatedBy,
            @AssignedTo = AssignedTo,
            @PriorityId = PriorityId,
            @Impact = Impact,
            @Urgency = Urgency,
            @ResolvedOffsetMin = ResolvedOffsetMin,
            @ClosedOffsetMin = ClosedOffsetMin,
            @SlaResponseOffsetMin = SlaResponseOffsetMin,
            @SlaResolutionOffsetMin = SlaResolutionOffsetMin
        FROM @SeedTickets
        WHERE RowNo = @Ti;

        SET @ResolvedAt = CASE WHEN @ResolvedOffsetMin IS NULL THEN NULL ELSE DATEADD(MINUTE, @ResolvedOffsetMin, @Now) END;
        SET @ClosedAt = CASE WHEN @ClosedOffsetMin IS NULL THEN NULL ELSE DATEADD(MINUTE, @ClosedOffsetMin, @Now) END;

        SELECT @TicketId = Id FROM dbo.Tickets WHERE TicketNumber = @TicketNumber;

        IF @TicketId IS NULL
        BEGIN
            INSERT INTO dbo.Tickets
                (TicketNumber, TicketType, Title, Description, CategoryId, LocationId, Impact, Urgency, PriorityId, ServiceCatalogId,
                 RequiresApproval, [Status], CreatedBy, AssignedTo, ResolvedAt, ClosedAt, CreatedAt, UpdatedAt)
            VALUES
                (@TicketNumber, N'Incident', @Title, @SeedTag + N' Demo ticket for reopen + SLA flow',
                 @CategoryId, @LocId, @Impact, @Urgency, @PriorityId, NULL,
                 0, @Status, @CreatedBy, @AssignedTo, @ResolvedAt, @ClosedAt, DATEADD(HOUR, -2, @Now), @Now);

            SET @TicketId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Tickets
            SET TicketType = N'Incident',
                Title = @Title,
                Description = @SeedTag + N' Demo ticket for reopen + SLA flow',
                CategoryId = @CategoryId,
                LocationId = @LocId,
                Impact = @Impact,
                Urgency = @Urgency,
                PriorityId = @PriorityId,
                ServiceCatalogId = NULL,
                RequiresApproval = 0,
                [Status] = @Status,
                CreatedBy = @CreatedBy,
                AssignedTo = @AssignedTo,
                ResolvedAt = @ResolvedAt,
                ClosedAt = @ClosedAt,
                UpdatedAt = @Now
            WHERE Id = @TicketId;
        END;

        IF OBJECT_ID('dbo.SLATracking', 'U') IS NOT NULL
           AND @SlaResolutionOffsetMin IS NOT NULL
        BEGIN
            DELETE FROM dbo.SLATracking WHERE TicketId = @TicketId;

            INSERT INTO dbo.SLATracking (TicketId, ResponseDeadline, ResolutionDeadline, IsBreached, CreatedAt)
            VALUES (
                @TicketId,
                DATEADD(MINUTE, @SlaResponseOffsetMin, @Now),
                DATEADD(MINUTE, @SlaResolutionOffsetMin, @Now),
                CASE WHEN @SlaResolutionOffsetMin < 0 THEN 1 ELSE 0 END,
                DATEADD(MINUTE, -1, @Now)
            );
        END;

        SET @Ti = @Ti + 1;
    END;

    DECLARE
        @ReopenTicketId INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-DEMO-REOPEN-001'),
        @SlaTicketId INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-DEMO-SLA-001');

    IF OBJECT_ID('dbo.SLAEscalationHistory', 'U') IS NOT NULL AND @SlaTicketId IS NOT NULL
    BEGIN
        DELETE FROM dbo.SLAEscalationHistory WHERE TicketId = @SlaTicketId;
    END;

    IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.Notifications
        WHERE ([Title] LIKE @SeedTag + N'%'
               OR [Message] LIKE @SeedTag + N'%')
           OR (RelatedTicketId = @SlaTicketId AND [Title] LIKE N'SLA%');
    END;

    /* ============================================================
       4) Seed Temporary Access requests for Admin demo
          - one Pending (to Approve)
          - one Approved active (to Revoke)
       ============================================================ */
    IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.TemporaryRoleRequests
        WHERE Reason LIKE @SeedTag + N'%';

        INSERT INTO dbo.TemporaryRoleRequests
            (UserId, CurrentRole, RequestedRole, Reason, DurationMinutes, Status, RequestedAt, ReviewedBy, ReviewComment, ReviewedAt, ApprovedAt, ExpiresAt, RevokedAt)
        VALUES
            (@UserId, N'User', N'IT Support', @SeedTag + N' Pending request for Admin approve demo', 60, N'Pending',
                DATEADD(MINUTE, -10, @Now), NULL, NULL, NULL, NULL, NULL, NULL),
            (@ItId, N'IT Support', N'Manager', @SeedTag + N' Approved request for Admin revoke demo', 120, N'Approved',
                DATEADD(MINUTE, -30, @Now), @AdminId, N'Approved for demo', DATEADD(MINUTE, -25, @Now),
                DATEADD(MINUTE, -25, @Now), DATEADD(MINUTE, 95, @Now), NULL);
    END;

    COMMIT TRANSACTION;

    PRINT 'Seed completed: minimal Reopen + SLA + Temporary Access demo.';
    PRINT 'Login users/password: demo.admin / demo.manager / demo.it / demo.user  (all use 123456)';
    PRINT 'SLA ticket INC-DEMO-SLA-001 has ResolutionDeadline = GETDATE()+5 minutes.';
    PRINT 'After ~5 minutes and after hitting any non-static page, SLA escalation notifications should appear (if SLAEscalationFilter is enabled).';

    SELECT Id, Username, Email, FullName, [Role], IsActive
    FROM dbo.Users
    WHERE Username IN (N'demo.admin', N'demo.manager', N'demo.it', N'demo.user')
    ORDER BY [Role], Username;

    SELECT Id, TicketNumber, Title, [Status], CreatedBy, AssignedTo, ResolvedAt, ClosedAt, UpdatedAt
    FROM dbo.Tickets
    WHERE TicketNumber IN (N'INC-DEMO-REOPEN-001', N'INC-DEMO-SLA-001')
    ORDER BY TicketNumber;

    IF OBJECT_ID('dbo.SLATracking', 'U') IS NOT NULL
    BEGIN
        SELECT
            t.TicketNumber,
            st.ResponseDeadline,
            st.ResolutionDeadline,
            DATEDIFF(MINUTE, GETDATE(), st.ResolutionDeadline) AS RemainingMinutes,
            st.IsBreached
        FROM dbo.SLATracking st
        INNER JOIN dbo.Tickets t ON t.Id = st.TicketId
        WHERE t.TicketNumber = N'INC-DEMO-SLA-001';
    END;

    IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NOT NULL
    BEGIN
        SELECT Id, UserId, CurrentRole, RequestedRole, DurationMinutes, Status, RequestedAt, ReviewedBy, ExpiresAt, RevokedAt
        FROM dbo.TemporaryRoleRequests
        WHERE Reason LIKE @SeedTag + N'%'
        ORDER BY Id DESC;
    END;

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
