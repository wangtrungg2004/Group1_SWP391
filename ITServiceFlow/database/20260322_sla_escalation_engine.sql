SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

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

    IF OBJECT_ID('dbo.SLATracking', 'U') IS NOT NULL
    BEGIN
        UPDATE st
        SET st.IsBreached = 1
        FROM dbo.SLATracking st
        INNER JOIN dbo.Tickets t ON t.Id = st.TicketId
        WHERE t.Status NOT IN ('Resolved', 'Closed', 'Cancelled')
          AND st.ResolutionDeadline < GETDATE()
          AND ISNULL(st.IsBreached, 0) = 0;
    END;

    COMMIT TRANSACTION;
    PRINT 'SLA escalation engine migration completed successfully.';
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

