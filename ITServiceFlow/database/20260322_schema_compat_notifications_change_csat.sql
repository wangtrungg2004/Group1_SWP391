SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* ==========================================================
       1) Notifications: add IsBroadcast if missing
       ========================================================== */
    IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH('dbo.Notifications', 'IsBroadcast') IS NULL
        BEGIN
            ALTER TABLE dbo.Notifications
            ADD IsBroadcast BIT NOT NULL
                CONSTRAINT DF_Notifications_IsBroadcast DEFAULT (0);
        END;

        IF EXISTS (
            SELECT 1
            FROM sys.columns
            WHERE object_id = OBJECT_ID('dbo.Notifications')
              AND name = 'UserId'
              AND is_nullable = 0
        )
        BEGIN
            ALTER TABLE dbo.Notifications
            ALTER COLUMN UserId INT NULL;
        END;
    END;

    /* ==========================================================
       2) ChangeRequests: add LinkedTicketId if missing
       ========================================================== */
    IF OBJECT_ID('dbo.ChangeRequests', 'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH('dbo.ChangeRequests', 'LinkedTicketId') IS NULL
        BEGIN
            ALTER TABLE dbo.ChangeRequests
            ADD LinkedTicketId INT NULL;
        END;

        IF OBJECT_ID('dbo.Tickets', 'U') IS NOT NULL
           AND COL_LENGTH('dbo.ChangeRequests', 'LinkedTicketId') IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM sys.foreign_key_columns fkc
               JOIN sys.columns c
                 ON c.object_id = fkc.parent_object_id
                AND c.column_id = fkc.parent_column_id
               WHERE fkc.parent_object_id = OBJECT_ID('dbo.ChangeRequests')
                 AND c.name = 'LinkedTicketId'
           )
        BEGIN
            ALTER TABLE dbo.ChangeRequests
            ADD CONSTRAINT FK_ChangeRequests_LinkedTicketId
                FOREIGN KEY (LinkedTicketId) REFERENCES dbo.Tickets(Id);
        END;

        IF COL_LENGTH('dbo.ChangeRequests', 'LinkedTicketId') IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM sys.indexes
               WHERE object_id = OBJECT_ID('dbo.ChangeRequests')
                 AND name = 'IX_ChangeRequests_LinkedTicketId'
           )
        BEGIN
            CREATE INDEX IX_ChangeRequests_LinkedTicketId
                ON dbo.ChangeRequests (LinkedTicketId);
        END;
    END;

    /* ==========================================================
       3) CsatSurveys: create table if missing
       ========================================================== */
    IF OBJECT_ID('dbo.CsatSurveys', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CsatSurveys (
            Id INT IDENTITY(1,1) NOT NULL
                CONSTRAINT PK_CsatSurveys PRIMARY KEY,
            TicketId INT NOT NULL,
            UserId INT NOT NULL,
            Rating INT NOT NULL,
            Comment NVARCHAR(1000) NULL,
            SubmittedAt DATETIME NOT NULL
                CONSTRAINT DF_CsatSurveys_SubmittedAt DEFAULT (GETDATE())
        );
    END;

    IF OBJECT_ID('dbo.CsatSurveys', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM sys.check_constraints
            WHERE parent_object_id = OBJECT_ID('dbo.CsatSurveys')
              AND name = 'CK_CsatSurveys_Rating'
        )
        BEGIN
            ALTER TABLE dbo.CsatSurveys WITH CHECK
            ADD CONSTRAINT CK_CsatSurveys_Rating
                CHECK (Rating BETWEEN 1 AND 5);
        END;

        IF OBJECT_ID('dbo.Tickets', 'U') IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM sys.foreign_keys
               WHERE parent_object_id = OBJECT_ID('dbo.CsatSurveys')
                 AND name = 'FK_CsatSurveys_Tickets'
           )
        BEGIN
            ALTER TABLE dbo.CsatSurveys WITH CHECK
            ADD CONSTRAINT FK_CsatSurveys_Tickets
                FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id);
        END;

        IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM sys.foreign_keys
               WHERE parent_object_id = OBJECT_ID('dbo.CsatSurveys')
                 AND name = 'FK_CsatSurveys_Users'
           )
        BEGIN
            ALTER TABLE dbo.CsatSurveys WITH CHECK
            ADD CONSTRAINT FK_CsatSurveys_Users
                FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
        END;

        IF NOT EXISTS (
            SELECT 1
            FROM sys.indexes
            WHERE object_id = OBJECT_ID('dbo.CsatSurveys')
              AND name = 'UQ_CsatSurveys_Ticket_User'
        )
        BEGIN
            CREATE UNIQUE INDEX UQ_CsatSurveys_Ticket_User
                ON dbo.CsatSurveys (TicketId, UserId);
        END;

        IF NOT EXISTS (
            SELECT 1
            FROM sys.indexes
            WHERE object_id = OBJECT_ID('dbo.CsatSurveys')
              AND name = 'IX_CsatSurveys_SubmittedAt'
        )
        BEGIN
            CREATE INDEX IX_CsatSurveys_SubmittedAt
                ON dbo.CsatSurveys (SubmittedAt DESC);
        END;
    END;

    COMMIT TRANSACTION;
    PRINT 'Schema compatibility migration completed successfully.';
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
