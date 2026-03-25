SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME = GETDATE();

    /* ------------------------------------------------------------
       1) Ensure baseline data (Categories, Locations, Users, Priorities)
       ------------------------------------------------------------ */
    DECLARE @CategoryId INT = NULL;
    DECLARE @LocationId INT = NULL;
    DECLARE @RequesterId INT = NULL;
    DECLARE @Agent1Id INT = NULL;
    DECLARE @Agent2Id INT = NULL;
    DECLARE @Agent3Id INT = NULL;

    DECLARE @CriticalPriorityId INT = NULL;
    DECLARE @HighPriorityId INT = NULL;
    DECLARE @MediumPriorityId INT = NULL;
    DECLARE @LowPriorityId INT = NULL;

    SELECT TOP 1 @CategoryId = c.Id
    FROM dbo.Categories c
    WHERE ISNULL(c.IsActive, 1) = 1
    ORDER BY c.Id;

    IF @CategoryId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Categories (Name, ParentId, [Level], FullPath, IsActive)
            VALUES (N'SLA Demo Category', NULL, 1, N'SLA Demo Category', 1);
            SET @CategoryId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Categories (Name, IsActive)
                VALUES (N'SLA Demo Category', 1);
                SET @CategoryId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                INSERT INTO dbo.Categories (Name)
                VALUES (N'SLA Demo Category');
                SET @CategoryId = SCOPE_IDENTITY();
            END CATCH
        END CATCH
    END;

    SELECT TOP 1 @LocationId = l.Id
    FROM dbo.Locations l
    WHERE ISNULL(l.IsActive, 1) = 1
    ORDER BY l.Id;

    IF @LocationId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Locations (Name, Code, IsActive)
            VALUES (N'SLA Demo Location', 'SLA', 1);
            SET @LocationId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Locations (Name, IsActive)
                VALUES (N'SLA Demo Location', 1);
                SET @LocationId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                INSERT INTO dbo.Locations (Name)
                VALUES (N'SLA Demo Location');
                SET @LocationId = SCOPE_IDENTITY();
            END CATCH
        END CATCH
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Priorities)
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Priorities (Impact, Urgency, [Level], ResponseHours, ResolutionHours)
            VALUES
                (1, 1, N'Critical', 1, 4),
                (1, 2, N'High', 2, 8),
                (2, 2, N'Medium', 4, 24),
                (3, 3, N'Low', 8, 48);
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Priorities ([Level])
                VALUES (N'Critical'), (N'High'), (N'Medium'), (N'Low');
            END TRY
            BEGIN CATCH
                THROW 51001, 'Cannot auto-seed dbo.Priorities. Please insert at least 1 row first.', 1;
            END CATCH
        END CATCH
    END;

    SELECT TOP 1 @CriticalPriorityId = p.Id
    FROM dbo.Priorities p
    WHERE LOWER(p.[Level]) IN ('critical', 'p1')
    ORDER BY CASE WHEN LOWER(p.[Level]) = 'critical' THEN 1 ELSE 2 END, p.Id;

    SELECT TOP 1 @HighPriorityId = p.Id
    FROM dbo.Priorities p
    WHERE LOWER(p.[Level]) IN ('high', 'p2')
    ORDER BY CASE WHEN LOWER(p.[Level]) = 'high' THEN 1 ELSE 2 END, p.Id;

    SELECT TOP 1 @MediumPriorityId = p.Id
    FROM dbo.Priorities p
    WHERE LOWER(p.[Level]) IN ('medium', 'p3')
    ORDER BY CASE WHEN LOWER(p.[Level]) = 'medium' THEN 1 ELSE 2 END, p.Id;

    SELECT TOP 1 @LowPriorityId = p.Id
    FROM dbo.Priorities p
    WHERE LOWER(p.[Level]) IN ('low', 'p4')
    ORDER BY CASE WHEN LOWER(p.[Level]) = 'low' THEN 1 ELSE 2 END, p.Id;

    DECLARE @FirstPriorityId INT = NULL;
    DECLARE @SecondPriorityId INT = NULL;
    DECLARE @ThirdPriorityId INT = NULL;
    DECLARE @FourthPriorityId INT = NULL;

    SELECT @FirstPriorityId = MIN(Id) FROM dbo.Priorities;
    SELECT @SecondPriorityId = MIN(Id) FROM dbo.Priorities WHERE Id > ISNULL(@FirstPriorityId, 0);
    SELECT @ThirdPriorityId = MIN(Id) FROM dbo.Priorities WHERE Id > ISNULL(@SecondPriorityId, 0);
    SELECT @FourthPriorityId = MIN(Id) FROM dbo.Priorities WHERE Id > ISNULL(@ThirdPriorityId, 0);

    IF @CriticalPriorityId IS NULL SET @CriticalPriorityId = @FirstPriorityId;
    IF @HighPriorityId IS NULL SET @HighPriorityId = ISNULL(@SecondPriorityId, @CriticalPriorityId);
    IF @MediumPriorityId IS NULL SET @MediumPriorityId = ISNULL(@ThirdPriorityId, @HighPriorityId);
    IF @LowPriorityId IS NULL SET @LowPriorityId = ISNULL(@FourthPriorityId, @MediumPriorityId);

    IF @CriticalPriorityId IS NULL
        THROW 51002, 'No priority rows found in dbo.Priorities.', 1;

    SELECT TOP 1 @RequesterId = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1 AND u.Role = 'User'
    ORDER BY u.Id;

    IF @RequesterId IS NULL
    BEGIN
        SELECT TOP 1 @RequesterId = u.Id
        FROM dbo.Users u
        WHERE u.IsActive = 1
        ORDER BY u.Id;
    END;

    IF @RequesterId IS NULL
        THROW 51003, 'No active users found. Please run database/sample_users.sql first.', 1;

    SELECT TOP 1 @Agent1Id = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1
      AND u.Role = 'IT Support'
    ORDER BY u.Id;

    IF @Agent1Id IS NULL
    BEGIN
        SELECT TOP 1 @Agent1Id = u.Id
        FROM dbo.Users u
        WHERE u.IsActive = 1
          AND u.Role IN ('Manager', 'Admin')
        ORDER BY u.Id;
    END;

    IF @Agent1Id IS NULL SET @Agent1Id = @RequesterId;

    SELECT TOP 1 @Agent2Id = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1
      AND u.Id <> @Agent1Id
      AND u.Role IN ('IT Support', 'Manager', 'Admin')
    ORDER BY CASE WHEN u.Role = 'IT Support' THEN 1 WHEN u.Role = 'Manager' THEN 2 ELSE 3 END, u.Id;

    IF @Agent2Id IS NULL
    BEGIN
        SELECT TOP 1 @Agent2Id = u.Id
        FROM dbo.Users u
        WHERE u.IsActive = 1
          AND u.Id <> @Agent1Id
        ORDER BY u.Id;
    END;

    IF @Agent2Id IS NULL SET @Agent2Id = @Agent1Id;

    SELECT TOP 1 @Agent3Id = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1
      AND u.Id NOT IN (@Agent1Id, @Agent2Id)
      AND u.Role IN ('IT Support', 'Manager', 'Admin')
    ORDER BY CASE WHEN u.Role = 'IT Support' THEN 1 WHEN u.Role = 'Manager' THEN 2 ELSE 3 END, u.Id;

    IF @Agent3Id IS NULL
    BEGIN
        SELECT TOP 1 @Agent3Id = u.Id
        FROM dbo.Users u
        WHERE u.IsActive = 1
          AND u.Id NOT IN (@Agent1Id, @Agent2Id)
        ORDER BY u.Id;
    END;

    IF @Agent3Id IS NULL SET @Agent3Id = @Agent2Id;

    /* ------------------------------------------------------------
       2) Seed demo tickets for SLA Breach screen (idempotent)
          - Breached: deadline in the past
          - Near breach: deadline < 2 hours
          - Watch list: deadline < 4 hours (appears in Breach List screen)
       ------------------------------------------------------------ */
    DECLARE @Seed TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        TicketNumber NVARCHAR(50) NOT NULL,
        Title NVARCHAR(255) NOT NULL,
        [Status] NVARCHAR(30) NOT NULL,
        Impact INT NULL,
        Urgency INT NULL,
        PriorityId INT NULL,
        AssignedTo INT NULL,
        ResponseOffsetMin INT NOT NULL,
        ResolutionOffsetMin INT NOT NULL
    );

    INSERT INTO @Seed (
        TicketNumber, Title, [Status], Impact, Urgency, PriorityId, AssignedTo, ResponseOffsetMin, ResolutionOffsetMin
    )
    VALUES
        (N'INC-SLADEMO-BR1', N'SLA demo - VPN outage at branch office',      N'Open',        1, 1, @CriticalPriorityId, @Agent1Id, -130, -90),
        (N'INC-SLADEMO-BR2', N'SLA demo - Email queue stuck for executives',   N'In Progress', 1, 2, @HighPriorityId,     @Agent2Id, -70,  -25),
        (N'INC-SLADEMO-NB1', N'SLA demo - SSO intermittent login failures',    N'Open',        1, 2, @HighPriorityId,     @Agent1Id, -20,   20),
        (N'INC-SLADEMO-NB2', N'SLA demo - HR portal timeout during payroll',   N'In Progress', 2, 2, @MediumPriorityId,   @Agent3Id,  10,   75),
        (N'INC-SLADEMO-NB3', N'SLA demo - Printer spooler unstable',           N'On Hold',     2, 3, @MediumPriorityId,   @Agent2Id,  15,  110),
        (N'INC-SLADEMO-WL1', N'SLA demo - Shared drive latency spike',         N'Open',        3, 3, @LowPriorityId,      @Agent1Id,  45,  190);

    DECLARE @Created TABLE (
        TicketId INT NOT NULL,
        TicketNumber NVARCHAR(50) NOT NULL,
        Title NVARCHAR(255) NOT NULL
    );

    DECLARE @i INT = 1;
    DECLARE @max INT;
    SELECT @max = COUNT(*) FROM @Seed;

    WHILE @i <= @max
    BEGIN
        DECLARE @TicketNumber NVARCHAR(50);
        DECLARE @Title NVARCHAR(255);
        DECLARE @Status NVARCHAR(30);
        DECLARE @Impact INT;
        DECLARE @Urgency INT;
        DECLARE @PriorityId INT;
        DECLARE @AssignedTo INT;
        DECLARE @ResponseOffsetMin INT;
        DECLARE @ResolutionOffsetMin INT;
        DECLARE @TicketId INT = NULL;

        SELECT
            @TicketNumber = s.TicketNumber,
            @Title = s.Title,
            @Status = s.[Status],
            @Impact = s.Impact,
            @Urgency = s.Urgency,
            @PriorityId = s.PriorityId,
            @AssignedTo = s.AssignedTo,
            @ResponseOffsetMin = s.ResponseOffsetMin,
            @ResolutionOffsetMin = s.ResolutionOffsetMin
        FROM @Seed s
        WHERE s.RowNo = @i;

        SELECT @TicketId = t.Id
        FROM dbo.Tickets t
        WHERE t.TicketNumber = @TicketNumber;

        IF @TicketId IS NULL
        BEGIN
            INSERT INTO dbo.Tickets (
                TicketNumber,
                TicketType,
                Title,
                Description,
                CategoryId,
                LocationId,
                Impact,
                Urgency,
                PriorityId,
                ServiceCatalogId,
                RequiresApproval,
                Status,
                CreatedBy,
                AssignedTo,
                CreatedAt,
                UpdatedAt
            )
            VALUES (
                @TicketNumber,
                'Incident',
                @Title,
                N'Demo data for SLA Breach screen.',
                @CategoryId,
                @LocationId,
                @Impact,
                @Urgency,
                @PriorityId,
                NULL,
                0,
                @Status,
                @RequesterId,
                @AssignedTo,
                DATEADD(HOUR, -3, @Now),
                @Now
            );

            SET @TicketId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Tickets
            SET
                TicketType = 'Incident',
                Title = @Title,
                Description = N'Demo data for SLA Breach screen.',
                CategoryId = @CategoryId,
                LocationId = @LocationId,
                Impact = @Impact,
                Urgency = @Urgency,
                PriorityId = @PriorityId,
                RequiresApproval = 0,
                Status = @Status,
                CreatedBy = @RequesterId,
                AssignedTo = @AssignedTo,
                ResolvedAt = NULL,
                ClosedAt = NULL,
                UpdatedAt = @Now
            WHERE Id = @TicketId;
        END;

        DELETE FROM dbo.SLATracking WHERE TicketId = @TicketId;

        INSERT INTO dbo.SLATracking (
            TicketId,
            ResponseDeadline,
            ResolutionDeadline,
            IsBreached,
            CreatedAt
        )
        VALUES (
            @TicketId,
            DATEADD(MINUTE, @ResponseOffsetMin, @Now),
            DATEADD(MINUTE, @ResolutionOffsetMin, @Now),
            CASE WHEN @ResolutionOffsetMin < 0 THEN 1 ELSE 0 END,
            DATEADD(HOUR, -2, @Now)
        );

        INSERT INTO @Created (TicketId, TicketNumber, Title)
        VALUES (@TicketId, @TicketNumber, @Title);

        SET @i = @i + 1;
    END;

    COMMIT TRANSACTION;

    PRINT 'SLA demo seed completed successfully.';

    /* ------------------------------------------------------------
       3) Verification output (matches application logic)
       ------------------------------------------------------------ */
    SELECT
        t.Id,
        t.TicketNumber,
        t.Title,
        t.Status,
        p.[Level] AS PriorityLevel,
        u.FullName AS AssignedTo,
        st.ResponseDeadline,
        st.ResolutionDeadline,
        DATEDIFF(MINUTE, GETDATE(), st.ResolutionDeadline) AS RemainingMinutes,
        CASE
            WHEN st.ResolutionDeadline < GETDATE() THEN 'Breached'
            WHEN st.ResolutionDeadline <= DATEADD(HOUR, 2, GETDATE()) THEN 'NearBreach(<2h)'
            WHEN st.ResolutionDeadline <= DATEADD(HOUR, 4, GETDATE()) THEN 'WatchList(<4h)'
            ELSE 'Safe'
        END AS SLAState
    FROM @Created c
    INNER JOIN dbo.Tickets t ON t.Id = c.TicketId
    INNER JOIN dbo.SLATracking st ON st.TicketId = t.Id
    LEFT JOIN dbo.Priorities p ON p.Id = t.PriorityId
    LEFT JOIN dbo.Users u ON u.Id = t.AssignedTo
    ORDER BY st.ResolutionDeadline ASC;

    SELECT
        SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled')
                   AND st.ResolutionDeadline < GETDATE() THEN 1 ELSE 0 END) AS Breached,
        SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled')
                   AND st.ResolutionDeadline BETWEEN GETDATE() AND DATEADD(HOUR, 2, GETDATE()) THEN 1 ELSE 0 END) AS NearBreach,
        SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled')
                   AND st.ResolutionDeadline < DATEADD(HOUR, 4, GETDATE()) THEN 1 ELSE 0 END) AS BreachListWindow,
        COUNT(*) AS TotalSeeded
    FROM @Created c
    INNER JOIN dbo.Tickets t ON t.Id = c.TicketId
    INNER JOIN dbo.SLATracking st ON st.TicketId = t.Id;

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
