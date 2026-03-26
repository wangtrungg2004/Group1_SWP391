SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME = GETDATE();

    DECLARE @CategoryId INT = NULL;
    DECLARE @LocationId INT = NULL;
    DECLARE @RequesterId INT = NULL;
    DECLARE @Agent1Id INT = NULL;
    DECLARE @Agent2Id INT = NULL;
    DECLARE @Agent3Id INT = NULL;

    DECLARE @CriticalPriorityId INT = NULL;
    DECLARE @HighPriorityId INT = NULL;
    DECLARE @MediumPriorityId INT = NULL;
    DECLARE @FirstPriorityId INT = NULL;
    DECLARE @SecondPriorityId INT = NULL;
    DECLARE @ThirdPriorityId INT = NULL;

    SELECT TOP 1 @CategoryId = c.Id
    FROM dbo.Categories c
    WHERE ISNULL(c.IsActive, 1) = 1
    ORDER BY c.Id;

    IF @CategoryId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Categories (Name, ParentId, [Level], FullPath, IsActive)
            VALUES (N'SLA Escalation Demo', NULL, 1, N'SLA Escalation Demo', 1);
            SET @CategoryId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Categories (Name, IsActive)
                VALUES (N'SLA Escalation Demo', 1);
                SET @CategoryId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                INSERT INTO dbo.Categories (Name)
                VALUES (N'SLA Escalation Demo');
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
            VALUES (N'SLA Escalation Demo', 'SLAE', 1);
            SET @LocationId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Locations (Name, IsActive)
                VALUES (N'SLA Escalation Demo', 1);
                SET @LocationId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                INSERT INTO dbo.Locations (Name)
                VALUES (N'SLA Escalation Demo');
                SET @LocationId = SCOPE_IDENTITY();
            END CATCH
        END CATCH
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Priorities)
    BEGIN
        INSERT INTO dbo.Priorities (Impact, Urgency, [Level], ResponseHours, ResolutionHours)
        VALUES
            (1, 1, N'Critical', 1, 4),
            (1, 2, N'High', 2, 8),
            (2, 2, N'Medium', 4, 24);
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

    SELECT @FirstPriorityId = MIN(Id) FROM dbo.Priorities;
    SELECT @SecondPriorityId = MIN(Id) FROM dbo.Priorities WHERE Id > ISNULL(@FirstPriorityId, 0);
    SELECT @ThirdPriorityId = MIN(Id) FROM dbo.Priorities WHERE Id > ISNULL(@SecondPriorityId, 0);

    IF @CriticalPriorityId IS NULL SET @CriticalPriorityId = @FirstPriorityId;
    IF @HighPriorityId IS NULL SET @HighPriorityId = ISNULL(@SecondPriorityId, @CriticalPriorityId);
    IF @MediumPriorityId IS NULL SET @MediumPriorityId = ISNULL(@ThirdPriorityId, @HighPriorityId);

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
        THROW 52001, 'No active users found. Please run database/sample_users.sql first.', 1;

    SELECT TOP 1 @Agent1Id = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1 AND u.Role = 'IT Support'
    ORDER BY u.Id;

    IF @Agent1Id IS NULL SET @Agent1Id = @RequesterId;

    SELECT TOP 1 @Agent2Id = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1 AND u.Id <> @Agent1Id
    ORDER BY u.Id;
    IF @Agent2Id IS NULL SET @Agent2Id = @Agent1Id;

    SELECT TOP 1 @Agent3Id = u.Id
    FROM dbo.Users u
    WHERE u.IsActive = 1 AND u.Id NOT IN (@Agent1Id, @Agent2Id)
    ORDER BY u.Id;
    IF @Agent3Id IS NULL SET @Agent3Id = @Agent2Id;

    DECLARE @Seed TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        TicketNumber NVARCHAR(50) NOT NULL,
        Title NVARCHAR(255) NOT NULL,
        [Status] NVARCHAR(30) NOT NULL,
        PriorityId INT NULL,
        AssignedTo INT NULL,
        ResponseOffsetMin INT NOT NULL,
        ResolutionOffsetMin INT NOT NULL,
        ExpectedStage NVARCHAR(50) NOT NULL
    );

    /*
      Requested demo data (+5m):
      - <=120m + 5m  => 125m remaining now (2h warning after ~5m)
      - <=30m  + 5m  =>  35m remaining now (30m warning after ~5m)
      - <0m    + 5m  =>  -5m remaining now (already breached by 5m)
    */
    INSERT INTO @Seed (
        TicketNumber, Title, [Status], PriorityId, AssignedTo, ResponseOffsetMin, ResolutionOffsetMin, ExpectedStage
    )
    VALUES
        (N'INC-SLAESC-2H5M', N'SLA Escalation demo - threshold 120m + 5m', N'Open',        @HighPriorityId,   @Agent1Id,  30,  125, N'NEAR_BREACH_2H (in ~5m)'),
        (N'INC-SLAESC-30M5M',N'SLA Escalation demo - threshold 30m + 5m',  N'In Progress', @MediumPriorityId, @Agent2Id,  20,   35, N'NEAR_BREACH_30M (in ~5m)'),
        (N'INC-SLAESC-BR5M', N'SLA Escalation demo - breached +5m',        N'Open',        @CriticalPriorityId,@Agent3Id, -40,   -5, N'BREACHED (already)'); 

    DECLARE @Result TABLE (
        TicketId INT NOT NULL,
        TicketNumber NVARCHAR(50) NOT NULL,
        ExpectedStage NVARCHAR(50) NOT NULL
    );

    DECLARE @i INT = 1;
    DECLARE @max INT;
    SELECT @max = COUNT(*) FROM @Seed;

    WHILE @i <= @max
    BEGIN
        DECLARE @TicketNumber NVARCHAR(50);
        DECLARE @Title NVARCHAR(255);
        DECLARE @Status NVARCHAR(30);
        DECLARE @PriorityId INT;
        DECLARE @AssignedTo INT;
        DECLARE @ResponseOffsetMin INT;
        DECLARE @ResolutionOffsetMin INT;
        DECLARE @ExpectedStage NVARCHAR(50);
        DECLARE @TicketId INT = NULL;

        SELECT
            @TicketNumber = s.TicketNumber,
            @Title = s.Title,
            @Status = s.[Status],
            @PriorityId = s.PriorityId,
            @AssignedTo = s.AssignedTo,
            @ResponseOffsetMin = s.ResponseOffsetMin,
            @ResolutionOffsetMin = s.ResolutionOffsetMin,
            @ExpectedStage = s.ExpectedStage
        FROM @Seed s
        WHERE s.RowNo = @i;

        SELECT @TicketId = t.Id
        FROM dbo.Tickets t
        WHERE t.TicketNumber = @TicketNumber;

        IF @TicketId IS NULL
        BEGIN
            INSERT INTO dbo.Tickets (
                TicketNumber, TicketType, Title, Description,
                CategoryId, LocationId,
                Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval,
                Status, CreatedBy, AssignedTo, CreatedAt, UpdatedAt
            )
            VALUES (
                @TicketNumber, 'Incident', @Title, N'Demo data for SLA Escalation Rule Engine (+5m).',
                @CategoryId, @LocationId,
                2, 2, @PriorityId, NULL, 0,
                @Status, @RequesterId, @AssignedTo, DATEADD(HOUR, -2, @Now), @Now
            );
            SET @TicketId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Tickets
            SET
                TicketType = 'Incident',
                Title = @Title,
                Description = N'Demo data for SLA Escalation Rule Engine (+5m).',
                CategoryId = @CategoryId,
                LocationId = @LocationId,
                Impact = 2,
                Urgency = 2,
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
            TicketId, ResponseDeadline, ResolutionDeadline, IsBreached, CreatedAt
        )
        VALUES (
            @TicketId,
            DATEADD(MINUTE, @ResponseOffsetMin, @Now),
            DATEADD(MINUTE, @ResolutionOffsetMin, @Now),
            CASE WHEN @ResolutionOffsetMin < 0 THEN 1 ELSE 0 END,
            @Now
        );

        IF OBJECT_ID('dbo.SLAEscalationHistory', 'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.SLAEscalationHistory WHERE TicketId = @TicketId;
        END;

        IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.Notifications
            WHERE RelatedTicketId = @TicketId
              AND Title LIKE 'SLA%';
        END;

        INSERT INTO @Result (TicketId, TicketNumber, ExpectedStage)
        VALUES (@TicketId, @TicketNumber, @ExpectedStage);

        SET @i = @i + 1;
    END;

    COMMIT TRANSACTION;

    SELECT
        r.TicketId,
        r.TicketNumber,
        r.ExpectedStage,
        t.Status,
        u.FullName AS AssignedTo,
        st.ResolutionDeadline,
        DATEDIFF(MINUTE, GETDATE(), st.ResolutionDeadline) AS RemainingMinutes
    FROM @Result r
    JOIN dbo.Tickets t ON t.Id = r.TicketId
    JOIN dbo.SLATracking st ON st.TicketId = r.TicketId
    LEFT JOIN dbo.Users u ON u.Id = t.AssignedTo
    ORDER BY st.ResolutionDeadline ASC;

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
