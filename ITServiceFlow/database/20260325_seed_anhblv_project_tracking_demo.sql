SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME = GETDATE();
    DECLARE @PwdHash NVARCHAR(255) = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2));

    /* ============================================================
       1) Ensure baseline master data (Departments, Locations, Categories, Priorities)
       ============================================================ */
    DECLARE @DeptIT INT = NULL, @DeptOps INT = NULL, @DeptFinance INT = NULL;
    DECLARE @LocHN INT = NULL, @LocHCM INT = NULL, @LocDC INT = NULL;
    DECLARE @CategoryId INT = NULL;
    DECLARE @PriorityCritical INT = NULL, @PriorityHigh INT = NULL, @PriorityMedium INT = NULL;

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

    SELECT TOP 1 @LocHN = Id
    FROM dbo.Locations
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'HANOI HQ'
    ORDER BY Id;
    IF @LocHN IS NULL AND @LocHasCode = 1
    BEGIN
        SELECT TOP 1 @LocHN = Id
        FROM dbo.Locations
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'HN'
        ORDER BY Id;
    END;
    IF @LocHN IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @LocHNOut TABLE (NewId INT);
            INSERT INTO @LocHNOut(NewId)
            EXEC sp_executesql
                @LocInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @IsActive BIT',
                @Name = N'Hanoi HQ',
                @Code = N'HN',
                @IsActive = 1;
            SELECT TOP 1 @LocHN = NewId FROM @LocHNOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                IF @LocHasCode = 1
                BEGIN
                    SELECT TOP 1 @LocHN = Id
                    FROM dbo.Locations
                    WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'HN'
                    ORDER BY Id;
                END;

                IF @LocHN IS NULL
                BEGIN
                    SELECT TOP 1 @LocHN = Id
                    FROM dbo.Locations
                    WHERE UPPER(LTRIM(RTRIM(Name))) = N'HANOI HQ'
                    ORDER BY Id;
                END;

                IF @LocHN IS NULL THROW;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    SELECT TOP 1 @LocHCM = Id
    FROM dbo.Locations
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'HCM BRANCH'
    ORDER BY Id;
    IF @LocHCM IS NULL AND @LocHasCode = 1
    BEGIN
        SELECT TOP 1 @LocHCM = Id
        FROM dbo.Locations
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'HCM'
        ORDER BY Id;
    END;
    IF @LocHCM IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @LocHCMOut TABLE (NewId INT);
            INSERT INTO @LocHCMOut(NewId)
            EXEC sp_executesql
                @LocInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @IsActive BIT',
                @Name = N'HCM Branch',
                @Code = N'HCM',
                @IsActive = 1;
            SELECT TOP 1 @LocHCM = NewId FROM @LocHCMOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                IF @LocHasCode = 1
                BEGIN
                    SELECT TOP 1 @LocHCM = Id
                    FROM dbo.Locations
                    WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'HCM'
                    ORDER BY Id;
                END;

                IF @LocHCM IS NULL
                BEGIN
                    SELECT TOP 1 @LocHCM = Id
                    FROM dbo.Locations
                    WHERE UPPER(LTRIM(RTRIM(Name))) = N'HCM BRANCH'
                    ORDER BY Id;
                END;

                IF @LocHCM IS NULL THROW;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    SELECT TOP 1 @LocDC = Id
    FROM dbo.Locations
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'DATA CENTER'
    ORDER BY Id;
    IF @LocDC IS NULL AND @LocHasCode = 1
    BEGIN
        SELECT TOP 1 @LocDC = Id
        FROM dbo.Locations
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'DC'
        ORDER BY Id;
    END;
    IF @LocDC IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @LocDCOut TABLE (NewId INT);
            INSERT INTO @LocDCOut(NewId)
            EXEC sp_executesql
                @LocInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @IsActive BIT',
                @Name = N'Data Center',
                @Code = N'DC',
                @IsActive = 1;
            SELECT TOP 1 @LocDC = NewId FROM @LocDCOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                IF @LocHasCode = 1
                BEGIN
                    SELECT TOP 1 @LocDC = Id
                    FROM dbo.Locations
                    WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'DC'
                    ORDER BY Id;
                END;

                IF @LocDC IS NULL
                BEGIN
                    SELECT TOP 1 @LocDC = Id
                    FROM dbo.Locations
                    WHERE UPPER(LTRIM(RTRIM(Name))) = N'DATA CENTER'
                    ORDER BY Id;
                END;

                IF @LocDC IS NULL THROW;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    DECLARE @DeptHasCode BIT = CASE WHEN COL_LENGTH('dbo.Departments', 'Code') IS NULL THEN 0 ELSE 1 END;
    DECLARE @DeptHasLocationId BIT = CASE WHEN COL_LENGTH('dbo.Departments', 'LocationId') IS NULL THEN 0 ELSE 1 END;
    DECLARE @DeptHasIsActive BIT = CASE WHEN COL_LENGTH('dbo.Departments', 'IsActive') IS NULL THEN 0 ELSE 1 END;
    DECLARE @DeptInsertSql NVARCHAR(MAX);

    SET @DeptInsertSql = N'INSERT INTO dbo.Departments (Name';
    IF @DeptHasCode = 1 SET @DeptInsertSql += N', Code';
    IF @DeptHasLocationId = 1 SET @DeptInsertSql += N', LocationId';
    IF @DeptHasIsActive = 1 SET @DeptInsertSql += N', IsActive';
    SET @DeptInsertSql += N') VALUES (@Name';
    IF @DeptHasCode = 1 SET @DeptInsertSql += N', @Code';
    IF @DeptHasLocationId = 1 SET @DeptInsertSql += N', @LocationId';
    IF @DeptHasIsActive = 1 SET @DeptInsertSql += N', @IsActive';
    SET @DeptInsertSql += N'); SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;';

    SELECT TOP 1 @DeptIT = Id
    FROM dbo.Departments
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'IT DEPARTMENT'
    ORDER BY Id;
    IF @DeptIT IS NULL AND @DeptHasCode = 1
    BEGIN
        SELECT TOP 1 @DeptIT = Id
        FROM dbo.Departments
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'IT'
        ORDER BY Id;
    END;
    IF @DeptIT IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @DeptITOut TABLE (NewId INT);
            INSERT INTO @DeptITOut(NewId)
            EXEC sp_executesql
                @DeptInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @LocationId INT, @IsActive BIT',
                @Name = N'IT Department',
                @Code = N'IT',
                @LocationId = @LocHN,
                @IsActive = 1;
            SELECT TOP 1 @DeptIT = NewId FROM @DeptITOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                IF @DeptHasCode = 1
                BEGIN
                    SELECT TOP 1 @DeptIT = Id
                    FROM dbo.Departments
                    WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'IT'
                    ORDER BY Id;
                END;

                IF @DeptIT IS NULL
                BEGIN
                    SELECT TOP 1 @DeptIT = Id
                    FROM dbo.Departments
                    WHERE UPPER(LTRIM(RTRIM(Name))) = N'IT DEPARTMENT'
                    ORDER BY Id;
                END;

                IF @DeptIT IS NULL THROW;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    SELECT TOP 1 @DeptOps = Id
    FROM dbo.Departments
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'OPERATIONS DEPARTMENT'
    ORDER BY Id;
    IF @DeptOps IS NULL AND @DeptHasCode = 1
    BEGIN
        SELECT TOP 1 @DeptOps = Id
        FROM dbo.Departments
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'OPS'
        ORDER BY Id;
    END;
    IF @DeptOps IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @DeptOpsOut TABLE (NewId INT);
            INSERT INTO @DeptOpsOut(NewId)
            EXEC sp_executesql
                @DeptInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @LocationId INT, @IsActive BIT',
                @Name = N'Operations Department',
                @Code = N'OPS',
                @LocationId = @LocHN,
                @IsActive = 1;
            SELECT TOP 1 @DeptOps = NewId FROM @DeptOpsOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                IF @DeptHasCode = 1
                BEGIN
                    SELECT TOP 1 @DeptOps = Id
                    FROM dbo.Departments
                    WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'OPS'
                    ORDER BY Id;
                END;

                IF @DeptOps IS NULL
                BEGIN
                    SELECT TOP 1 @DeptOps = Id
                    FROM dbo.Departments
                    WHERE UPPER(LTRIM(RTRIM(Name))) = N'OPERATIONS DEPARTMENT'
                    ORDER BY Id;
                END;

                IF @DeptOps IS NULL THROW;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    SELECT TOP 1 @DeptFinance = Id
    FROM dbo.Departments
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'FINANCE DEPARTMENT'
    ORDER BY Id;
    IF @DeptFinance IS NULL AND @DeptHasCode = 1
    BEGIN
        SELECT TOP 1 @DeptFinance = Id
        FROM dbo.Departments
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'FIN'
        ORDER BY Id;
    END;
    IF @DeptFinance IS NULL
    BEGIN
        BEGIN TRY
            DECLARE @DeptFinOut TABLE (NewId INT);
            INSERT INTO @DeptFinOut(NewId)
            EXEC sp_executesql
                @DeptInsertSql,
                N'@Name NVARCHAR(200), @Code NVARCHAR(50), @LocationId INT, @IsActive BIT',
                @Name = N'Finance Department',
                @Code = N'FIN',
                @LocationId = @LocHCM,
                @IsActive = 1;
            SELECT TOP 1 @DeptFinance = NewId FROM @DeptFinOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                IF @DeptHasCode = 1
                BEGIN
                    SELECT TOP 1 @DeptFinance = Id
                    FROM dbo.Departments
                    WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(100))))) = N'FIN'
                    ORDER BY Id;
                END;

                IF @DeptFinance IS NULL
                BEGIN
                    SELECT TOP 1 @DeptFinance = Id
                    FROM dbo.Departments
                    WHERE UPPER(LTRIM(RTRIM(Name))) = N'FINANCE DEPARTMENT'
                    ORDER BY Id;
                END;

                IF @DeptFinance IS NULL THROW;
            END
            ELSE
            BEGIN
                THROW;
            END;
        END CATCH;
    END;

    SELECT TOP 1 @CategoryId = c.Id
    FROM dbo.Categories c
    ORDER BY c.Id;

    IF @CategoryId IS NULL
    BEGIN
        DECLARE @CatHasParentId BIT = CASE WHEN COL_LENGTH('dbo.Categories', 'ParentId') IS NULL THEN 0 ELSE 1 END;
        DECLARE @CatHasLevel BIT = CASE WHEN COL_LENGTH('dbo.Categories', 'Level') IS NULL THEN 0 ELSE 1 END;
        DECLARE @CatHasFullPath BIT = CASE WHEN COL_LENGTH('dbo.Categories', 'FullPath') IS NULL THEN 0 ELSE 1 END;
        DECLARE @CatHasIsActive BIT = CASE WHEN COL_LENGTH('dbo.Categories', 'IsActive') IS NULL THEN 0 ELSE 1 END;
        DECLARE @CatInsertSql NVARCHAR(MAX) = N'INSERT INTO dbo.Categories (Name';

        IF @CatHasParentId = 1 SET @CatInsertSql += N', ParentId';
        IF @CatHasLevel = 1 SET @CatInsertSql += N', [Level]';
        IF @CatHasFullPath = 1 SET @CatInsertSql += N', FullPath';
        IF @CatHasIsActive = 1 SET @CatInsertSql += N', IsActive';

        SET @CatInsertSql += N') VALUES (@Name';
        IF @CatHasParentId = 1 SET @CatInsertSql += N', @ParentId';
        IF @CatHasLevel = 1 SET @CatInsertSql += N', @Level';
        IF @CatHasFullPath = 1 SET @CatInsertSql += N', @FullPath';
        IF @CatHasIsActive = 1 SET @CatInsertSql += N', @IsActive';

        SET @CatInsertSql += N'); SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;';

        BEGIN TRY
            DECLARE @CatOut TABLE (NewId INT);
            INSERT INTO @CatOut(NewId)
            EXEC sp_executesql
                @CatInsertSql,
                N'@Name NVARCHAR(200), @ParentId INT, @Level NVARCHAR(50), @FullPath NVARCHAR(500), @IsActive BIT',
                @Name = N'AnhBLV Demo Category',
                @ParentId = NULL,
                @Level = N'1',
                @FullPath = N'AnhBLV Demo Category',
                @IsActive = 1;

            SELECT TOP 1 @CategoryId = NewId FROM @CatOut;
        END TRY
        BEGIN CATCH
            SELECT TOP 1 @CategoryId = c.Id
            FROM dbo.Categories c
            WHERE UPPER(LTRIM(RTRIM(c.Name))) = N'ANHBLV DEMO CATEGORY'
            ORDER BY c.Id;

            IF @CategoryId IS NULL
                THROW;
        END CATCH;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Priorities)
    BEGIN
        IF COL_LENGTH('dbo.Priorities', 'Impact') IS NOT NULL
           AND COL_LENGTH('dbo.Priorities', 'Urgency') IS NOT NULL
           AND COL_LENGTH('dbo.Priorities', 'Level') IS NOT NULL
           AND COL_LENGTH('dbo.Priorities', 'ResponseHours') IS NOT NULL
           AND COL_LENGTH('dbo.Priorities', 'ResolutionHours') IS NOT NULL
        BEGIN
            EXEC sp_executesql N'
                INSERT INTO dbo.Priorities (Impact, Urgency, [Level], ResponseHours, ResolutionHours)
                VALUES
                    (1, 1, N''Critical'', 1, 4),
                    (1, 2, N''High'', 2, 8),
                    (2, 2, N''Medium'', 4, 24);';
        END
        ELSE IF COL_LENGTH('dbo.Priorities', 'Level') IS NOT NULL
        BEGIN
            EXEC sp_executesql N'
                INSERT INTO dbo.Priorities ([Level])
                VALUES (N''Critical''), (N''High''), (N''Medium'');';
        END
    END;

    SELECT TOP 1 @PriorityCritical = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('critical', 'p1') ORDER BY Id;
    SELECT TOP 1 @PriorityHigh = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('high', 'p2') ORDER BY Id;
    SELECT TOP 1 @PriorityMedium = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('medium', 'p3') ORDER BY Id;

    IF @PriorityCritical IS NULL SELECT TOP 1 @PriorityCritical = Id FROM dbo.Priorities ORDER BY Id;
    IF @PriorityHigh IS NULL SELECT TOP 1 @PriorityHigh = Id FROM dbo.Priorities WHERE Id <> @PriorityCritical ORDER BY Id;
    IF @PriorityHigh IS NULL SET @PriorityHigh = @PriorityCritical;
    IF @PriorityMedium IS NULL SELECT TOP 1 @PriorityMedium = Id FROM dbo.Priorities WHERE Id NOT IN (@PriorityCritical, @PriorityHigh) ORDER BY Id;
    IF @PriorityMedium IS NULL SET @PriorityMedium = @PriorityHigh;

    /* ============================================================
       2) Seed users for Login / Google Login / Create User / User Management / Role Permission
       Default password for all seeded users: 123456
       ============================================================ */
    DECLARE @SeedUsers TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50),
        Email NVARCHAR(150),
        FullName NVARCHAR(150),
        [Role] NVARCHAR(50),
        DepartmentId INT,
        LocationId INT
    );

    INSERT INTO @SeedUsers (Username, Email, FullName, [Role], DepartmentId, LocationId)
    VALUES
        (N'anhblv.admin',      N'anhblv.admin@itserviceflow.local',      N'AnhBLV Admin',      N'Admin',      @DeptIT,      @LocHN),
        (N'anhblv.manager',    N'anhblv.manager@itserviceflow.local',    N'AnhBLV Manager',    N'Manager',    @DeptOps,     @LocHN),
        (N'anhblv.itsupport1', N'anhblv.itsupport1@itserviceflow.local', N'AnhBLV IT Support 1', N'IT Support', @DeptIT,    @LocDC),
        (N'anhblv.itsupport2', N'anhblv.itsupport2@itserviceflow.local', N'AnhBLV IT Support 2', N'IT Support', @DeptIT,    @LocHCM),
        (N'anhblv.user1',      N'anhblv.user1@itserviceflow.local',      N'AnhBLV End User 1', N'User',       @DeptFinance, @LocHCM),
        (N'anhblv.user2',      N'anhblv.user2@itserviceflow.local',      N'AnhBLV End User 2', N'User',       @DeptOps,     @LocHN);

    DECLARE
        @Ui INT = 1,
        @Umax INT,
        @Username NVARCHAR(50),
        @Email NVARCHAR(150),
        @FullName NVARCHAR(150),
        @Role NVARCHAR(50),
        @DepartmentId INT,
        @LocationId INT;

    SELECT @Umax = COUNT(*) FROM @SeedUsers;
    WHILE @Ui <= @Umax
    BEGIN
        SELECT
            @Username = Username,
            @Email = Email,
            @FullName = FullName,
            @Role = [Role],
            @DepartmentId = DepartmentId,
            @LocationId = LocationId
        FROM @SeedUsers
        WHERE RowNo = @Ui;

        IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
        BEGIN
            UPDATE dbo.Users
            SET Email = @Email,
                PasswordHash = @PwdHash,
                FullName = @FullName,
                [Role] = @Role,
                DepartmentId = @DepartmentId,
                LocationId = @LocationId,
                IsActive = 1
            WHERE Username = @Username;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, [Role], DepartmentId, LocationId, IsActive, CreatedAt)
            VALUES (@Username, @Email, @PwdHash, @FullName, @Role, @DepartmentId, @LocationId, 1, @Now);
        END;

        SET @Ui = @Ui + 1;
    END;

    DECLARE
        @AdminId INT,
        @ManagerId INT,
        @Support1Id INT,
        @Support2Id INT,
        @User1Id INT,
        @User2Id INT;

    SELECT @AdminId = Id FROM dbo.Users WHERE Username = N'anhblv.admin';
    SELECT @ManagerId = Id FROM dbo.Users WHERE Username = N'anhblv.manager';
    SELECT @Support1Id = Id FROM dbo.Users WHERE Username = N'anhblv.itsupport1';
    SELECT @Support2Id = Id FROM dbo.Users WHERE Username = N'anhblv.itsupport2';
    SELECT @User1Id = Id FROM dbo.Users WHERE Username = N'anhblv.user1';
    SELECT @User2Id = Id FROM dbo.Users WHERE Username = N'anhblv.user2';

    /* ============================================================
       3) Seed PasswordResetTokens (Forgot Password / Reset Password demo)
       ============================================================ */
    IF OBJECT_ID('dbo.PasswordResetTokens', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.PasswordResetTokens WHERE Token LIKE 'ANHBLV-RESET-%';

        INSERT INTO dbo.PasswordResetTokens (UserId, Token, ExpiresAt, IsUsed)
        VALUES
            (@User1Id, 'ANHBLV-RESET-VALID-001', DATEADD(MINUTE, 30, @Now), 0),
            (@User2Id, 'ANHBLV-RESET-EXPIRED-001', DATEADD(MINUTE, -30, @Now), 0),
            (@User1Id, 'ANHBLV-RESET-USED-001', DATEADD(MINUTE, 15, @Now), 1);
    END;

    /* ============================================================
       4) Seed TemporaryRoleRequests (Temporary Permission Assignment demo)
       ============================================================ */
    IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.TemporaryRoleRequests
        WHERE Reason LIKE '[SEED-ANHBLV]%';

        INSERT INTO dbo.TemporaryRoleRequests
            (UserId, CurrentRole, RequestedRole, Reason, DurationMinutes, Status, RequestedAt, ReviewedBy, ReviewComment, ReviewedAt, ApprovedAt, ExpiresAt, RevokedAt)
        VALUES
            (@User1Id, N'User', N'IT Support', N'[SEED-ANHBLV] Need temporary IT support rights for outage triage', 60, N'Pending', DATEADD(MINUTE, -20, @Now), NULL, NULL, NULL, NULL, NULL, NULL),
            (@User2Id, N'User', N'Manager', N'[SEED-ANHBLV] Need temporary manager rights for urgent approval', 120, N'Approved', DATEADD(HOUR, -2, @Now), @ManagerId, N'Approved for emergency window', DATEADD(HOUR, -1, @Now), DATEADD(HOUR, -1, @Now), DATEADD(MINUTE, 60, @Now), NULL),
            (@Support1Id, N'IT Support', N'Manager', N'[SEED-ANHBLV] Request elevated rights for incident command', 60, N'Rejected', DATEADD(HOUR, -3, @Now), @AdminId, N'Not enough business justification', DATEADD(HOUR, -2, @Now), NULL, NULL, NULL);
    END;

    /* ============================================================
       5) Seed Tickets for Reopen + SLA demo
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
        (N'INC-ANHBLV-REOPEN-001', N'AnhBLV Reopen Demo - VPN issue resolved then reopened', N'Resolved',    @User1Id,   @Support1Id, @PriorityHigh,    2, 2,  -80, NULL, NULL, NULL),
        (N'INC-ANHBLV-REOPEN-002', N'AnhBLV Reopen Demo - Mail outage closed then reopened', N'Closed',      @User2Id,   @Support2Id, @PriorityMedium,  2, 3, -180,  -90, NULL, NULL),
        (N'INC-ANHBLV-SLA-BR-001', N'AnhBLV SLA Demo - Authentication service down',         N'Open',        @User1Id,   @Support1Id, @PriorityCritical,1, 1, NULL, NULL, -120,  -70),
        (N'INC-ANHBLV-SLA-NB-001', N'AnhBLV SLA Demo - API timeout near breach 30m',         N'In Progress', @User2Id,   @Support2Id, @PriorityHigh,    1, 2, NULL, NULL,  -30,   25),
        (N'INC-ANHBLV-SLA-NB-002', N'AnhBLV SLA Demo - DB latency near breach 2h',           N'Open',        @User1Id,   @Support1Id, @PriorityMedium,  2, 2, NULL, NULL,   15,   95);

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
                (@TicketNumber, N'Incident', @Title, N'[SEED-ANHBLV] Demo ticket for project tracking functions',
                 @CategoryId, @LocHN, @Impact, @Urgency, @PriorityId, NULL,
                 0, @Status, @CreatedBy, @AssignedTo, @ResolvedAt, @ClosedAt, DATEADD(HOUR, -4, @Now), @Now);

            SET @TicketId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Tickets
            SET TicketType = N'Incident',
                Title = @Title,
                Description = N'[SEED-ANHBLV] Demo ticket for project tracking functions',
                CategoryId = @CategoryId,
                LocationId = @LocHN,
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
                DATEADD(HOUR, -3, @Now)
            );
        END;

        SET @Ti = @Ti + 1;
    END;

    /* ============================================================
       6) Seed targeted notifications (related users only) for demo screens
       ============================================================ */
    IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.Notifications
        WHERE [Message] LIKE '[SEED-ANHBLV]%'
           OR [Title] LIKE '[SEED-ANHBLV]%';

        DECLARE
            @ReopenTicketId1 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-REOPEN-001'),
            @ReopenTicketId2 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-REOPEN-002'),
            @SlaTicketId1 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-SLA-BR-001'),
            @SlaTicketId2 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-SLA-NB-001');

        INSERT INTO dbo.Notifications (UserId, [Message], RelatedTicketId, IsRead, CreatedAt, Title, [Type])
        VALUES
            (@User1Id,   N'[SEED-ANHBLV] Ticket reopen request has been logged for INC-ANHBLV-REOPEN-001', @ReopenTicketId1, 0, @Now, N'[SEED-ANHBLV] Ticket Reopened', N'Ticket'),
            (@Support1Id,N'[SEED-ANHBLV] Ticket reopen request has been logged for INC-ANHBLV-REOPEN-001', @ReopenTicketId1, 0, @Now, N'[SEED-ANHBLV] Ticket Reopened', N'Ticket'),
            (@User2Id,   N'[SEED-ANHBLV] Ticket reopen request has been logged for INC-ANHBLV-REOPEN-002', @ReopenTicketId2, 0, @Now, N'[SEED-ANHBLV] Ticket Reopened', N'Ticket'),
            (@Support2Id,N'[SEED-ANHBLV] Ticket reopen request has been logged for INC-ANHBLV-REOPEN-002', @ReopenTicketId2, 0, @Now, N'[SEED-ANHBLV] Ticket Reopened', N'Ticket'),
            (@User1Id,   N'[SEED-ANHBLV] SLA breached on INC-ANHBLV-SLA-BR-001', @SlaTicketId1, 0, @Now, N'[SEED-ANHBLV] SLA Breached', N'Ticket'),
            (@Support1Id,N'[SEED-ANHBLV] SLA breached on INC-ANHBLV-SLA-BR-001', @SlaTicketId1, 0, @Now, N'[SEED-ANHBLV] SLA Breached', N'Ticket'),
            (@ManagerId, N'[SEED-ANHBLV] SLA breached on INC-ANHBLV-SLA-BR-001', @SlaTicketId1, 0, @Now, N'[SEED-ANHBLV] SLA Breached', N'Ticket'),
            (@User2Id,   N'[SEED-ANHBLV] SLA near breach on INC-ANHBLV-SLA-NB-001', @SlaTicketId2, 0, @Now, N'[SEED-ANHBLV] SLA Warning', N'Ticket'),
            (@Support2Id,N'[SEED-ANHBLV] SLA near breach on INC-ANHBLV-SLA-NB-001', @SlaTicketId2, 0, @Now, N'[SEED-ANHBLV] SLA Warning', N'Ticket'),
            (@ManagerId, N'[SEED-ANHBLV] SLA near breach on INC-ANHBLV-SLA-NB-001', @SlaTicketId2, 0, @Now, N'[SEED-ANHBLV] SLA Warning', N'Ticket');
    END;

    COMMIT TRANSACTION;

    PRINT 'Seed completed for AnhBLV project tracking demo.';
    PRINT 'Default password for seeded users: 123456';

    SELECT Id, Username, Email, FullName, [Role], DepartmentId, LocationId, IsActive
    FROM dbo.Users
    WHERE Username LIKE 'anhblv.%'
    ORDER BY [Role], Username;

    SELECT Id, TicketNumber, Title, [Status], CreatedBy, AssignedTo, PriorityId, CreatedAt, UpdatedAt
    FROM dbo.Tickets
    WHERE TicketNumber LIKE 'INC-ANHBLV-%'
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
        WHERE t.TicketNumber LIKE 'INC-ANHBLV-SLA-%'
        ORDER BY st.ResolutionDeadline;
    END;

    IF OBJECT_ID('dbo.TemporaryRoleRequests', 'U') IS NOT NULL
    BEGIN
        SELECT Id, UserId, CurrentRole, RequestedRole, DurationMinutes, Status, RequestedAt, ReviewedBy, ExpiresAt
        FROM dbo.TemporaryRoleRequests
        WHERE Reason LIKE '[SEED-ANHBLV]%'
        ORDER BY Id DESC;
    END;

    IF OBJECT_ID('dbo.PasswordResetTokens', 'U') IS NOT NULL
    BEGIN
        SELECT UserId, Token, ExpiresAt, IsUsed
        FROM dbo.PasswordResetTokens
        WHERE Token LIKE 'ANHBLV-RESET-%'
        ORDER BY Token;
    END;

    IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
    BEGIN
        SELECT TOP 50 Id, UserId, Title, [Type], RelatedTicketId, CreatedAt
        FROM dbo.Notifications
        WHERE Title LIKE '[SEED-ANHBLV]%'
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
