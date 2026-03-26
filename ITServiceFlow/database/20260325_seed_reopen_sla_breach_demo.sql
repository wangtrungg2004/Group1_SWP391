SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME = GETDATE();
    DECLARE @PwdHash NVARCHAR(255) = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2));

    /* ============================================================
       1) Baseline data: Location, Category, Priority
       ============================================================ */
    DECLARE @LocId INT = NULL;
    DECLARE @CategoryId INT = NULL;
    DECLARE @PriorityCritical INT = NULL;
    DECLARE @PriorityHigh INT = NULL;
    DECLARE @PriorityMedium INT = NULL;

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
    WHERE UPPER(LTRIM(RTRIM(Name))) = N'DEMO REOPEN SLA'
    ORDER BY Id;

    IF @LocId IS NULL AND @LocHasCode = 1
    BEGIN
        SELECT TOP 1 @LocId = Id
        FROM dbo.Locations
        WHERE UPPER(LTRIM(RTRIM(CAST(Code AS NVARCHAR(50))))) = N'RSLA'
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
                @Name = N'Demo Reopen SLA',
                @Code = N'RSLA',
                @IsActive = 1;
            SELECT TOP 1 @LocId = NewId FROM @LocOut;
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() IN (2601, 2627)
            BEGIN
                SELECT TOP 1 @LocId = Id
                FROM dbo.Locations
                WHERE UPPER(LTRIM(RTRIM(Name))) = N'DEMO REOPEN SLA'
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
    WHERE UPPER(LTRIM(RTRIM(c.Name))) = N'DEMO REOPEN SLA CATEGORY'
    ORDER BY c.Id;

    IF @CategoryId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Categories (Name, ParentId, [Level], FullPath, IsActive)
            VALUES (N'Demo Reopen SLA Category', NULL, 1, N'Demo Reopen SLA Category', 1);
            SET @CategoryId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Categories (Name, IsActive)
                VALUES (N'Demo Reopen SLA Category', 1);
                SET @CategoryId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                BEGIN TRY
                    INSERT INTO dbo.Categories (Name)
                    VALUES (N'Demo Reopen SLA Category');
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
    SELECT TOP 1 @PriorityMedium = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('medium', 'p3') ORDER BY Id;

    IF @PriorityCritical IS NULL SELECT TOP 1 @PriorityCritical = Id FROM dbo.Priorities ORDER BY Id;
    IF @PriorityHigh IS NULL SELECT TOP 1 @PriorityHigh = Id FROM dbo.Priorities WHERE Id <> @PriorityCritical ORDER BY Id;
    IF @PriorityMedium IS NULL SELECT TOP 1 @PriorityMedium = Id FROM dbo.Priorities WHERE Id NOT IN (@PriorityCritical, @PriorityHigh) ORDER BY Id;
    IF @PriorityHigh IS NULL SET @PriorityHigh = @PriorityCritical;
    IF @PriorityMedium IS NULL SET @PriorityMedium = @PriorityHigh;

    /* ============================================================
       2) Seed users used in demo
       Default password: 123456
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
        (N'anhblv.admin',      N'anhblv.admin@itserviceflow.local',      N'AnhBLV Admin',        N'Admin',      NULL),
        (N'anhblv.manager',    N'anhblv.manager@itserviceflow.local',    N'AnhBLV Manager',      N'Manager',    NULL),
        (N'anhblv.itsupport1', N'anhblv.itsupport1@itserviceflow.local', N'AnhBLV IT Support 1', N'IT Support', NULL),
        (N'anhblv.itsupport2', N'anhblv.itsupport2@itserviceflow.local', N'AnhBLV IT Support 2', N'IT Support', NULL),
        (N'anhblv.user1',      N'anhblv.user1@itserviceflow.local',      N'AnhBLV End User 1',   N'User',       NULL),
        (N'anhblv.user2',      N'anhblv.user2@itserviceflow.local',      N'AnhBLV End User 2',   N'User',       NULL);

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
        @ManagerId INT,
        @Support1Id INT,
        @Support2Id INT,
        @User1Id INT,
        @User2Id INT;

    SELECT @ManagerId = Id FROM dbo.Users WHERE Username = N'anhblv.manager';
    SELECT @Support1Id = Id FROM dbo.Users WHERE Username = N'anhblv.itsupport1';
    SELECT @Support2Id = Id FROM dbo.Users WHERE Username = N'anhblv.itsupport2';
    SELECT @User1Id = Id FROM dbo.Users WHERE Username = N'anhblv.user1';
    SELECT @User2Id = Id FROM dbo.Users WHERE Username = N'anhblv.user2';

    /* ============================================================
       3) Seed tickets for Reopen + SLA Breach demo
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
        (N'INC-ANHBLV-REOPEN-001', N'AnhBLV Reopen Demo - VPN issue resolved then reopened', N'Resolved',    @User1Id, @Support1Id, @PriorityHigh,   2, 2, -120, NULL, NULL, NULL),
        (N'INC-ANHBLV-REOPEN-002', N'AnhBLV Reopen Demo - Mail outage closed then reopened', N'Closed',      @User2Id, @Support2Id, @PriorityMedium, 2, 3, -240,  -90, NULL, NULL),
        (N'INC-ANHBLV-SLA-BR-001', N'AnhBLV SLA Demo - Authentication service down',          N'Open',        @User1Id, @Support1Id, @PriorityCritical,1, 1, NULL, NULL,  -90,  -45),
        (N'INC-ANHBLV-SLA-NB-001', N'AnhBLV SLA Demo - API timeout near breach 30m',          N'In Progress', @User2Id, @Support2Id, @PriorityHigh,   1, 2, NULL, NULL,  -30,   20),
        (N'INC-ANHBLV-SLA-NB-002', N'AnhBLV SLA Demo - DB latency near breach 2h',            N'Open',        @User1Id, @Support1Id, @PriorityMedium, 2, 2, NULL, NULL,   10,  110);

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
                (@TicketNumber, N'Incident', @Title, N'[SEED-REOPEN-SLA] Demo ticket for reopen & sla breach',
                 @CategoryId, @LocId, @Impact, @Urgency, @PriorityId, NULL,
                 0, @Status, @CreatedBy, @AssignedTo, @ResolvedAt, @ClosedAt, DATEADD(HOUR, -4, @Now), @Now);

            SET @TicketId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Tickets
            SET TicketType = N'Incident',
                Title = @Title,
                Description = N'[SEED-REOPEN-SLA] Demo ticket for reopen & sla breach',
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
                DATEADD(HOUR, -3, @Now)
            );
        END;

        SET @Ti = @Ti + 1;
    END;

    /* ============================================================
       4) Optional notifications for quick UI demo
       ============================================================ */
    IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.Notifications
        WHERE [Message] LIKE '[SEED-REOPEN-SLA]%'
           OR [Title] LIKE '[SEED-REOPEN-SLA]%';

        DECLARE
            @ReopenTicketId1 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-REOPEN-001'),
            @ReopenTicketId2 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-REOPEN-002'),
            @SlaTicketId1 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-SLA-BR-001'),
            @SlaTicketId2 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-ANHBLV-SLA-NB-001');

        INSERT INTO dbo.Notifications (UserId, [Message], RelatedTicketId, IsRead, CreatedAt, Title, [Type])
        VALUES
            (@User1Id,    N'[SEED-REOPEN-SLA] Reopen request created for INC-ANHBLV-REOPEN-001', @ReopenTicketId1, 0, @Now, N'[SEED-REOPEN-SLA] Ticket Reopened', N'Ticket'),
            (@Support1Id, N'[SEED-REOPEN-SLA] Reopen request created for INC-ANHBLV-REOPEN-001', @ReopenTicketId1, 0, @Now, N'[SEED-REOPEN-SLA] Ticket Reopened', N'Ticket'),
            (@User2Id,    N'[SEED-REOPEN-SLA] Reopen request created for INC-ANHBLV-REOPEN-002', @ReopenTicketId2, 0, @Now, N'[SEED-REOPEN-SLA] Ticket Reopened', N'Ticket'),
            (@Support2Id, N'[SEED-REOPEN-SLA] Reopen request created for INC-ANHBLV-REOPEN-002', @ReopenTicketId2, 0, @Now, N'[SEED-REOPEN-SLA] Ticket Reopened', N'Ticket'),
            (@User1Id,    N'[SEED-REOPEN-SLA] SLA breached on INC-ANHBLV-SLA-BR-001',             @SlaTicketId1,    0, @Now, N'[SEED-REOPEN-SLA] SLA Breached',   N'Ticket'),
            (@Support1Id, N'[SEED-REOPEN-SLA] SLA breached on INC-ANHBLV-SLA-BR-001',             @SlaTicketId1,    0, @Now, N'[SEED-REOPEN-SLA] SLA Breached',   N'Ticket'),
            (@ManagerId,  N'[SEED-REOPEN-SLA] SLA breached on INC-ANHBLV-SLA-BR-001',             @SlaTicketId1,    0, @Now, N'[SEED-REOPEN-SLA] SLA Breached',   N'Ticket'),
            (@User2Id,    N'[SEED-REOPEN-SLA] SLA near breach on INC-ANHBLV-SLA-NB-001',          @SlaTicketId2,    0, @Now, N'[SEED-REOPEN-SLA] SLA Warning',    N'Ticket'),
            (@Support2Id, N'[SEED-REOPEN-SLA] SLA near breach on INC-ANHBLV-SLA-NB-001',          @SlaTicketId2,    0, @Now, N'[SEED-REOPEN-SLA] SLA Warning',    N'Ticket'),
            (@ManagerId,  N'[SEED-REOPEN-SLA] SLA near breach on INC-ANHBLV-SLA-NB-001',          @SlaTicketId2,    0, @Now, N'[SEED-REOPEN-SLA] SLA Warning',    N'Ticket');
    END;

    COMMIT TRANSACTION;

    PRINT 'Seed completed for Reopen + SLA Breach demo.';
    PRINT 'Demo password for seeded users: 123456';

    SELECT Id, Username, Email, FullName, [Role], IsActive
    FROM dbo.Users
    WHERE Username LIKE 'anhblv.%'
    ORDER BY [Role], Username;

    SELECT Id, TicketNumber, Title, [Status], CreatedBy, AssignedTo, ResolvedAt, ClosedAt
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
