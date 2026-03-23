SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /*
      PURPOSE:
      - Seed 2 tickets for Ticket Reopen testing (1 Resolved, 1 Closed)
      - Works even when Categories/Locations are empty.

      OPTIONAL:
      - Set @RequesterId / @AssigneeId manually if needed.
    */

    DECLARE @RequesterId INT = NULL; -- e.g. 12
    DECLARE @AssigneeId INT = NULL;  -- e.g. 3

    /* ---------------------------
       1) Ensure Categories has data
       --------------------------- */
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Categories (Name, ParentId, [Level], FullPath, IsActive)
            VALUES (N'General Support', NULL, 1, N'General Support', 1);
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Categories (Name, IsActive)
                VALUES (N'General Support', 1);
            END TRY
            BEGIN CATCH
                BEGIN TRY
                    INSERT INTO dbo.Categories (Name)
                    VALUES (N'General Support');
                END TRY
                BEGIN CATCH
                    THROW 50011, 'Cannot seed dbo.Categories automatically. Please insert at least 1 category row first.', 1;
                END CATCH
            END CATCH
        END CATCH
    END;

    /* ---------------------------
       2) Ensure Locations has data
       --------------------------- */
    IF NOT EXISTS (SELECT 1 FROM dbo.Locations)
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Locations (Name, Code, IsActive)
            VALUES (N'Head Office', 'HO', 1);
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Locations (Name, IsActive)
                VALUES (N'Head Office', 1);
            END TRY
            BEGIN CATCH
                BEGIN TRY
                    INSERT INTO dbo.Locations (Name)
                    VALUES (N'Head Office');
                END TRY
                BEGIN CATCH
                    THROW 50012, 'Cannot seed dbo.Locations automatically. Please insert at least 1 location row first.', 1;
                END CATCH
            END CATCH
        END CATCH
    END;

    /* ---------------------------
       3) Pick requester/assignee
       --------------------------- */
    IF @RequesterId IS NULL
    BEGIN
        SELECT TOP 1 @RequesterId = u.Id
        FROM dbo.Users u
        WHERE u.IsActive = 1
          AND u.Role = 'User'
        ORDER BY u.Id;

        IF @RequesterId IS NULL
        BEGIN
            SELECT TOP 1 @RequesterId = u.Id
            FROM dbo.Users u
            WHERE u.IsActive = 1
            ORDER BY u.Id;
        END
    END;

    IF @AssigneeId IS NULL
    BEGIN
        SELECT TOP 1 @AssigneeId = u.Id
        FROM dbo.Users u
        WHERE u.IsActive = 1
          AND u.Role IN ('IT Support', 'Manager', 'Admin')
        ORDER BY CASE u.Role WHEN 'IT Support' THEN 1 WHEN 'Manager' THEN 2 ELSE 3 END, u.Id;
    END;

    IF @RequesterId IS NULL
        THROW 50013, 'No active user found in dbo.Users. Please run sample_users.sql first.', 1;

    DECLARE @CategoryId INT;
    DECLARE @LocationId INT;

    SELECT TOP 1 @CategoryId = c.Id FROM dbo.Categories c ORDER BY c.Id;
    SELECT TOP 1 @LocationId = l.Id FROM dbo.Locations l ORDER BY l.Id;

    IF @CategoryId IS NULL
        THROW 50014, 'Failed to resolve CategoryId.', 1;

    IF @LocationId IS NULL
        THROW 50015, 'Failed to resolve LocationId.', 1;

    DECLARE @Created TABLE (
        TicketId INT NOT NULL,
        TicketNumber NVARCHAR(50) NOT NULL,
        Status NVARCHAR(20) NOT NULL
    );

    DECLARE @Now DATETIME = GETDATE();

    /* ---------------------------
       4) Seed ticket #1 (Resolved)
       --------------------------- */
    DECLARE @Token1 VARCHAR(12) = RIGHT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 12);
    DECLARE @TicketNo1 NVARCHAR(50) = CONCAT('INC-REOPEN-', @Token1);

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
        ResolvedAt,
        ClosedAt,
        CreatedAt,
        UpdatedAt
    )
    VALUES (
        @TicketNo1,
        'Incident',
        N'Seed ticket for reopen test (Resolved)',
        N'Created by DB seed script to test Ticket Reopen flow when Create Ticket is not ready.',
        @CategoryId,
        @LocationId,
        2,
        2,
        NULL,
        NULL,
        0,
        'Resolved',
        @RequesterId,
        @AssigneeId,
        DATEADD(MINUTE, -20, @Now),
        NULL,
        DATEADD(HOUR, -2, @Now),
        DATEADD(MINUTE, -20, @Now)
    );

    DECLARE @ResolvedTicketId INT = SCOPE_IDENTITY();

    INSERT INTO @Created (TicketId, TicketNumber, Status)
    VALUES (@ResolvedTicketId, @TicketNo1, 'Resolved');

    /* ---------------------------
       5) Seed ticket #2 (Closed)
       --------------------------- */
    DECLARE @Token2 VARCHAR(12) = RIGHT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 12);
    DECLARE @TicketNo2 NVARCHAR(50) = CONCAT('INC-REOPEN-', @Token2);

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
        ResolvedAt,
        ClosedAt,
        CreatedAt,
        UpdatedAt
    )
    VALUES (
        @TicketNo2,
        'Incident',
        N'Seed ticket for reopen test (Closed)',
        N'Created by DB seed script to test Ticket Reopen flow when Create Ticket is not ready.',
        @CategoryId,
        @LocationId,
        2,
        2,
        NULL,
        NULL,
        0,
        'Closed',
        @RequesterId,
        @AssigneeId,
        DATEADD(MINUTE, -30, @Now),
        DATEADD(MINUTE, -10, @Now),
        DATEADD(HOUR, -3, @Now),
        DATEADD(MINUTE, -10, @Now)
    );

    DECLARE @ClosedTicketId INT = SCOPE_IDENTITY();

    INSERT INTO @Created (TicketId, TicketNumber, Status)
    VALUES (@ClosedTicketId, @TicketNo2, 'Closed');

    COMMIT TRANSACTION;

    SELECT
        c.TicketId,
        c.TicketNumber,
        c.Status,
        u.FullName AS RequesterName,
        u.Role AS RequesterRole,
        t.AssignedTo,
        t.CreatedAt,
        t.ResolvedAt,
        t.ClosedAt
    FROM @Created c
    INNER JOIN dbo.Tickets t ON t.Id = c.TicketId
    INNER JOIN dbo.Users u ON u.Id = t.CreatedBy
    ORDER BY c.TicketId DESC;

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