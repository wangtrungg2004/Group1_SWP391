SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME = GETDATE();
    DECLARE @PwdHash NVARCHAR(255) = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2));
    DECLARE @SeedTag NVARCHAR(100) = N'SEED-COMPREHENSIVE-SLA-BREACH';

    /* ============================================================
       0) Ensure demo users exist (password: 123456)
       ============================================================ */
    DECLARE @LocId INT;
    SELECT TOP 1 @LocId = Id FROM dbo.Locations WHERE IsActive = 1 ORDER BY Id;

    IF @LocId IS NULL
    BEGIN
        INSERT INTO dbo.Locations (Name, Code, IsActive)
        VALUES (N'Demo Location', 'DEMO', 1);
        SET @LocId = SCOPE_IDENTITY();
    END;

    DECLARE @SeedUsers TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50),
        Email NVARCHAR(150),
        FullName NVARCHAR(150),
        [Role] NVARCHAR(50)
    );

    INSERT INTO @SeedUsers (Username, Email, FullName, [Role])
    VALUES
        (N'demo.admin',   N'demo.admin@itserviceflow.local',   N'Demo Admin',   N'Admin'),
        (N'demo.manager', N'demo.manager@itserviceflow.local', N'Demo Manager', N'Manager'),
        (N'demo.it',      N'demo.it@itserviceflow.local',      N'Demo IT',      N'IT Support'),
        (N'demo.user',    N'demo.user@itserviceflow.local',    N'Demo User',    N'User');

    DECLARE @Ui INT = 1, @Umax INT, @Username NVARCHAR(50), @Email NVARCHAR(150), @FullName NVARCHAR(150), @Role NVARCHAR(50);
    SELECT @Umax = COUNT(*) FROM @SeedUsers;
    WHILE @Ui <= @Umax
    BEGIN
        SELECT @Username = Username, @Email = Email, @FullName = FullName, @Role = [Role]
        FROM @SeedUsers WHERE RowNo = @Ui;

        IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
        BEGIN
            INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, [Role], LocationId, IsActive, CreatedAt)
            VALUES (@Username, @Email, @PwdHash, @FullName, @Role, @LocId, 1, @Now);
        END
        ELSE
        BEGIN
            UPDATE dbo.Users
            SET Email = @Email, FullName = @FullName, [Role] = @Role, PasswordHash = @PwdHash, LocationId = @LocId, IsActive = 1
            WHERE Username = @Username;
        END;
        SET @Ui = @Ui + 1;
    END;

    /* ============================================================
       1) Get demo user IDs
       ============================================================ */
    DECLARE @AdminId INT, @ManagerId INT, @ItId INT, @UserId INT;
    SELECT @AdminId = Id FROM dbo.Users WHERE Username = N'demo.admin';
    SELECT @ManagerId = Id FROM dbo.Users WHERE Username = N'demo.manager';
    SELECT @ItId = Id FROM dbo.Users WHERE Username = N'demo.it';
    SELECT @UserId = Id FROM dbo.Users WHERE Username = N'demo.user';

    IF @AdminId IS NULL OR @ManagerId IS NULL OR @ItId IS NULL OR @UserId IS NULL
    BEGIN
        THROW 53001, 'Cannot resolve seeded user ids.', 1;
    END;

    /* ============================================================
       2) Ensure baseline data (Categories, Priorities)
       ============================================================ */
    DECLARE @CategoryId INT;
    SELECT TOP 1 @CategoryId = Id FROM dbo.Categories WHERE IsActive = 1 ORDER BY Id;

    IF @CategoryId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Categories (Name, IsActive)
            VALUES (N'SLA Demo Category', 1);
            SET @CategoryId = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
            SELECT TOP 1 @CategoryId = Id FROM dbo.Categories ORDER BY Id;
        END CATCH
    END;

    /* ============================================================
       3) Ensure Priorities exist
       ============================================================ */
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
            END CATCH
        END CATCH
    END;

    DECLARE @CriticalPId INT, @HighPId INT, @MediumPId INT, @LowPId INT;
    SELECT TOP 1 @CriticalPId = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('critical', 'p1') ORDER BY Id;
    SELECT TOP 1 @HighPId = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('high', 'p2') ORDER BY Id;
    SELECT TOP 1 @MediumPId = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('medium', 'p3') ORDER BY Id;
    SELECT TOP 1 @LowPId = Id FROM dbo.Priorities WHERE LOWER([Level]) IN ('low', 'p4') ORDER BY Id;

    IF @CriticalPId IS NULL SELECT TOP 1 @CriticalPId = Id FROM dbo.Priorities ORDER BY Id;
    IF @HighPId IS NULL SELECT TOP 1 @HighPId = Id FROM dbo.Priorities WHERE Id <> @CriticalPId ORDER BY Id;
    IF @MediumPId IS NULL SELECT TOP 1 @MediumPId = Id FROM dbo.Priorities WHERE Id > @HighPId ORDER BY Id;
    IF @LowPId IS NULL SELECT TOP 1 @LowPId = Id FROM dbo.Priorities WHERE Id > @MediumPId ORDER BY Id;

    IF @HighPId IS NULL SET @HighPId = @CriticalPId;
    IF @MediumPId IS NULL SET @MediumPId = @HighPId;
    IF @LowPId IS NULL SET @LowPId = @MediumPId;

    /* ============================================================
       4) Delete existing seed tickets to avoid duplicates
       ============================================================ */
    DELETE FROM dbo.SLATracking
    WHERE TicketId IN (SELECT Id FROM dbo.Tickets WHERE TicketNumber LIKE N'INC-COMPREHENSIVE-SLA%');

    DELETE FROM dbo.Tickets
    WHERE TicketNumber LIKE N'INC-COMPREHENSIVE-SLA%';

    /* ============================================================
       5) Create comprehensive SLA Breach demo tickets
          
       BREACHED tickets (deadline in the past):
       - INC-COMPREHENSIVE-SLA-BR-001: Critical VPN outage (Breach by 130 min)
       - INC-COMPREHENSIVE-SLA-BR-002: Email critical (Breach by 70 min)
       - INC-COMPREHENSIVE-SLA-BR-003: Database down (Breach by 150 min)
       
       NEAR BREACH tickets (deadline < 2 hours):
       - INC-COMPREHENSIVE-SLA-BR-NB-001: SSO failures (Deadline -20 min)
       - INC-COMPREHENSIVE-SLA-BR-NB-002: HR system timeout (Deadline +10 min)
       - INC-COMPREHENSIVE-SLA-BR-NB-003: Printer issues (Deadline +15 min)
       
       WATCH LIST tickets (deadline < 4 hours):
       - INC-COMPREHENSIVE-SLA-BR-WL-001: Shared drive latency (Deadline +45 min)
       - INC-COMPREHENSIVE-SLA-BR-WL-002: Network fluctuation (Deadline +60 min)
       - INC-COMPREHENSIVE-SLA-BR-WL-003: Performance issues (Deadline +90 min)
       
       RESOLVED/REOPENED tickets:
       - INC-COMPREHENSIVE-SLA-REOPEN-001: Resolved VPN, will be reopened
       - INC-COMPREHENSIVE-SLA-REOPEN-002: Resolved Email, will be reopened
       - INC-COMPREHENSIVE-SLA-REOPEN-003: Closed then Reopened
       ============================================================ */
    DECLARE @SeedTickets TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        TicketNumber NVARCHAR(50),
        Title NVARCHAR(255),
        [Status] NVARCHAR(30),
        Description NVARCHAR(MAX),
        CreatedBy INT,
        AssignedTo INT,
        PriorityId INT,
        Impact INT,
        Urgency INT,
        CreatedOffsetHour INT,
        ResolvedOffsetMin INT NULL,
        ClosedOffsetMin INT NULL,
        SlaResponseOffsetMin INT,
        SlaResolutionOffsetMin INT,
        IsReopened BIT
    );

    INSERT INTO @SeedTickets (TicketNumber, Title, [Status], Description, CreatedBy, AssignedTo, PriorityId, Impact, Urgency, CreatedOffsetHour, ResolvedOffsetMin, ClosedOffsetMin, SlaResponseOffsetMin, SlaResolutionOffsetMin, IsReopened)
    VALUES
        -- BREACHED tickets
        (N'INC-COMPREHENSIVE-SLA-BR-001', N'Critical: VPN outage at main office - multiple users affected', N'Open',        N'VPN service down for 50+ users in main office. Unable to access resources.', @UserId, @ItId, @CriticalPId, 1, 1, -3, NULL, NULL, -130, -90, 0),
        (N'INC-COMPREHENSIVE-SLA-BR-002', N'High: Email service queue stuck - Executive communications blocked', N'In Progress', N'Mail queue processing stopped. Critical for executive communications.', @UserId, @ItId, @HighPId,     1, 2, -2, NULL, NULL, -70,  -25, 0),
        (N'INC-COMPREHENSIVE-SLA-BR-003', N'Critical: Main database down - Service unavailable', N'Open',        N'Primary database instances not responding. All applications affected.', @UserId, @ManagerId, @CriticalPId, 1, 1, -4, NULL, NULL, -150, -110, 0),
        
        -- NEAR BREACH tickets
        (N'INC-COMPREHENSIVE-SLA-BR-NB-001', N'High: SSO intermittent login failures', N'Open',        N'Users experiencing intermittent SSO failures during peak hours.', @UserId, @ItId, @HighPId,     1, 2, -2, NULL, NULL, -20,   20, 0),
        (N'INC-COMPREHENSIVE-SLA-BR-NB-002', N'Medium: HR portal timeout during payroll processing', N'In Progress', N'Portal slow and timing out during critical payroll window.', @UserId, @ManagerId, @MediumPId,   2, 2, -1, NULL, NULL, 10,    75, 0),
        (N'INC-COMPREHENSIVE-SLA-BR-NB-003', N'Medium: Printer spooler unstable - queue backlog', N'On Hold',     N'Printer queues unstable, causing service disruptions across floors.', @UserId, @ItId, @MediumPId,   2, 3, -1, NULL, NULL, 15,    110, 0),
        
        -- WATCH LIST tickets
        (N'INC-COMPREHENSIVE-SLA-BR-WL-001', N'Low: Shared drive latency spike', N'Open',        N'Shared drive experiencing high latency affecting user workflows.', @UserId, @ItId, @LowPId,      3, 3, -1, NULL, NULL, 45,    190, 0),
        (N'INC-COMPREHENSIVE-SLA-BR-WL-002', N'Medium: Network connectivity fluctuation', N'In Progress', N'Network experiencing intermittent drops and performance issues.', @UserId, @ManagerId, @MediumPId,   2, 2, -2, NULL, NULL, 60,    250, 0),
        (N'INC-COMPREHENSIVE-SLA-BR-WL-003', N'Low: Application performance degradation', N'Open',        N'Several applications showing unusual performance metrics.', @UserId, @ItId, @LowPId,      3, 3, -1, NULL, NULL, 90,    350, 0),
        
        -- RESOLVED/REOPENED tickets
        (N'INC-COMPREHENSIVE-SLA-REOPEN-001', N'Resolved: VPN outage - resolved by temporary connection', N'Resolved',    N'VPN temporarily restored. User will reopen when needed.', @UserId, @ItId, @HighPId,     1, 2, -5, -120, NULL, NULL, NULL, 0),
        (N'INC-COMPREHENSIVE-SLA-REOPEN-002', N'Resolved: Email service restored - partial workaround', N'Resolved',    N'Email partially restored. Marked resolved but may need follow-up.', @UserId, @ItId, @HighPId,     1, 2, -4, -90,  NULL, NULL, NULL, 0),
        (N'INC-COMPREHENSIVE-SLA-REOPEN-003', N'Closed: Temporary internet issue - resolved', N'Closed',      N'Issue was temporary connectivity problem. Marked closed.', @UserId, @ManagerId, @LowPId,      3, 3, -3, -60,  -30,  NULL, NULL, 0);

    /* ============================================================
       6) Insert tickets
       ============================================================ */
    DECLARE @Ti INT = 1, @Tmax INT, @TicketNumber NVARCHAR(50), @Title NVARCHAR(255), @Status NVARCHAR(30), 
            @Description NVARCHAR(MAX), @CreatedBy INT, @AssignedTo INT, @PriorityId INT, @Impact INT, @Urgency INT,
            @CreatedOffsetHour INT, @ResolvedOffsetMin INT, @ClosedOffsetMin INT, @SlaResponseOffsetMin INT, 
            @SlaResolutionOffsetMin INT, @IsReopened BIT, @TicketId INT, @ResolvedAt DATETIME, @ClosedAt DATETIME;

    SELECT @Tmax = COUNT(*) FROM @SeedTickets;
    WHILE @Ti <= @Tmax
    BEGIN
        SELECT
            @TicketNumber = TicketNumber,
            @Title = Title,
            @Status = [Status],
            @Description = Description,
            @CreatedBy = CreatedBy,
            @AssignedTo = AssignedTo,
            @PriorityId = PriorityId,
            @Impact = Impact,
            @Urgency = Urgency,
            @CreatedOffsetHour = CreatedOffsetHour,
            @ResolvedOffsetMin = ResolvedOffsetMin,
            @ClosedOffsetMin = ClosedOffsetMin,
            @SlaResponseOffsetMin = SlaResponseOffsetMin,
            @SlaResolutionOffsetMin = SlaResolutionOffsetMin,
            @IsReopened = IsReopened
        FROM @SeedTickets
        WHERE RowNo = @Ti;

        SET @ResolvedAt = CASE WHEN @ResolvedOffsetMin IS NULL THEN NULL ELSE DATEADD(MINUTE, @ResolvedOffsetMin, @Now) END;
        SET @ClosedAt = CASE WHEN @ClosedOffsetMin IS NULL THEN NULL ELSE DATEADD(MINUTE, @ClosedOffsetMin, @Now) END;

        SELECT @TicketId = Id FROM dbo.Tickets WHERE TicketNumber = @TicketNumber;

        IF @TicketId IS NULL
        BEGIN
            INSERT INTO dbo.Tickets
                (TicketNumber, TicketType, Title, Description, CategoryId, LocationId, Impact, Urgency, PriorityId,
                 RequiresApproval, [Status], CreatedBy, AssignedTo, ResolvedAt, ClosedAt, CreatedAt, UpdatedAt)
            VALUES
                (@TicketNumber, N'Incident', @Title, @Description,
                 @CategoryId, @LocId, @Impact, @Urgency, @PriorityId,
                 0, @Status, @CreatedBy, @AssignedTo, @ResolvedAt, @ClosedAt, DATEADD(HOUR, @CreatedOffsetHour, @Now), @Now);

            SET @TicketId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Tickets
            SET Title = @Title,
                Description = @Description,
                CategoryId = @CategoryId,
                LocationId = @LocId,
                Impact = @Impact,
                Urgency = @Urgency,
                PriorityId = @PriorityId,
                [Status] = @Status,
                CreatedBy = @CreatedBy,
                AssignedTo = @AssignedTo,
                ResolvedAt = @ResolvedAt,
                ClosedAt = @ClosedAt,
                UpdatedAt = @Now
            WHERE Id = @TicketId;
        END;

        /* ============================================================
           7) Insert SLATracking records
           ============================================================ */
        IF OBJECT_ID('dbo.SLATracking', 'U') IS NOT NULL
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

    /* ============================================================
       8) Create Reopen records for resolved tickets
       ============================================================ */
    IF OBJECT_ID('dbo.TicketReopens', 'U') IS NOT NULL
    BEGIN
        DECLARE @ReopenTicket1 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-COMPREHENSIVE-SLA-REOPEN-001');
        DECLARE @ReopenTicket2 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-COMPREHENSIVE-SLA-REOPEN-002');
        DECLARE @ReopenTicket3 INT = (SELECT Id FROM dbo.Tickets WHERE TicketNumber = N'INC-COMPREHENSIVE-SLA-REOPEN-003');

        IF @ReopenTicket1 IS NOT NULL
        BEGIN
            DELETE FROM dbo.TicketReopens WHERE TicketId = @ReopenTicket1 AND ReopenedBy = @UserId;
            INSERT INTO dbo.TicketReopens (TicketId, ReopenedBy, ReopenReason, ReopenedAt, NewStatus)
            VALUES (@ReopenTicket1, @UserId, N'Issue not fully resolved - intermittent VPN drops still occurring', @Now, N'Reopened');
        END;

        IF @ReopenTicket2 IS NOT NULL
        BEGIN
            DELETE FROM dbo.TicketReopens WHERE TicketId = @ReopenTicket2 AND ReopenedBy = @UserId;
            INSERT INTO dbo.TicketReopens (TicketId, ReopenedBy, ReopenReason, ReopenedAt, NewStatus)
            VALUES (@ReopenTicket2, @UserId, N'Email still experiencing performance issues - temporary fix insufficient', @Now, N'Reopened');
        END;

        IF @ReopenTicket3 IS NOT NULL
        BEGIN
            DELETE FROM dbo.TicketReopens WHERE TicketId = @ReopenTicket3 AND ReopenedBy = @UserId;
            INSERT INTO dbo.TicketReopens (TicketId, ReopenedBy, ReopenReason, ReopenedAt, NewStatus)
            VALUES (@ReopenTicket3, @UserId, N'Issue recurred - needs permanent resolution', @Now, N'Reopened');
        END;
    END;

    /* ============================================================
       9) Update reopened tickets to Reopened status
       ============================================================ */
    UPDATE dbo.Tickets
    SET [Status] = N'Reopened'
    WHERE TicketNumber IN (
        N'INC-COMPREHENSIVE-SLA-REOPEN-001',
        N'INC-COMPREHENSIVE-SLA-REOPEN-002',
        N'INC-COMPREHENSIVE-SLA-REOPEN-003'
    );

    /* ============================================================
       10) Print summary
       ============================================================ */
    PRINT N'============================================================';
    PRINT N'Seed data created for SLA Breach + Reopen demo';
    PRINT N'============================================================';
    PRINT N'Demo Users Created/Updated:';
    PRINT N'  - demo.admin (Admin)';
    PRINT N'  - demo.manager (Manager)';
    PRINT N'  - demo.it (IT Support)';
    PRINT N'  - demo.user (User)';
    PRINT N'============================================================';
    PRINT N'Tickets Created:';
    PRINT N'  BREACHED (3 tickets):';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-001: Critical VPN outage';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-002: Email queue stuck';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-003: Database down';
    PRINT N'  NEAR BREACH (3 tickets):';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-NB-001: SSO login failures';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-NB-002: HR portal timeout';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-NB-003: Printer spooler issues';
    PRINT N'  WATCH LIST (3 tickets):';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-WL-001: Shared drive latency';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-WL-002: Network fluctuation';
    PRINT N'    - INC-COMPREHENSIVE-SLA-BR-WL-003: App performance issues';
    PRINT N'  REOPENED (3 tickets):';
    PRINT N'    - INC-COMPREHENSIVE-SLA-REOPEN-001: VPN issue reopened';
    PRINT N'    - INC-COMPREHENSIVE-SLA-REOPEN-002: Email issue reopened';
    PRINT N'    - INC-COMPREHENSIVE-SLA-REOPEN-003: Network issue reopened';
    PRINT N'============================================================';
    PRINT N'SLA Tracking: All open tickets have SLATracking records';
    PRINT N'Password for all demo users: 123456';
    PRINT N'============================================================';

    COMMIT TRANSACTION;
    PRINT N'TRANSACTION COMMITTED - Seed data successfully created!';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
    DECLARE @ErrSev INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    PRINT N'ERROR OCCURRED:';
    PRINT @ErrMsg;
    THROW @ErrSev, @ErrMsg, @ErrState;
END CATCH
GO

-- Display summary of created data
SELECT 'Demo Users' AS [Type], Username, Email, [Role], IsActive, CreatedAt
FROM dbo.Users
WHERE Username LIKE N'demo.%'
ORDER BY [Role], Username;

SELECT 'Tickets - Breached' AS [Type], TicketNumber, Title, [Status], PriorityId, AssignedTo, CreatedAt
FROM dbo.Tickets
WHERE TicketNumber LIKE N'INC-COMPREHENSIVE-SLA-BR[^N]%'
ORDER BY CreatedAt DESC;

SELECT 'Tickets - Near Breach' AS [Type], TicketNumber, Title, [Status], PriorityId, AssignedTo, CreatedAt
FROM dbo.Tickets
WHERE TicketNumber LIKE N'INC-COMPREHENSIVE-SLA-BR-NB%'
ORDER BY CreatedAt DESC;

SELECT 'Tickets - Watch List' AS [Type], TicketNumber, Title, [Status], PriorityId, AssignedTo, CreatedAt
FROM dbo.Tickets
WHERE TicketNumber LIKE N'INC-COMPREHENSIVE-SLA-BR-WL%'
ORDER BY CreatedAt DESC;

SELECT 'Tickets - Reopened' AS [Type], TicketNumber, Title, [Status], PriorityId, AssignedTo, CreatedAt
FROM dbo.Tickets
WHERE TicketNumber LIKE N'INC-COMPREHENSIVE-SLA-REOPEN%'
ORDER BY CreatedAt DESC;

SELECT 'SLA Tracking' AS [Type], t.TicketNumber, s.ResponseDeadline, s.ResolutionDeadline, s.IsBreached
FROM dbo.SLATracking s
JOIN dbo.Tickets t ON s.TicketId = t.Id
WHERE t.TicketNumber LIKE N'INC-COMPREHENSIVE-SLA%'
ORDER BY s.ResolutionDeadline;
