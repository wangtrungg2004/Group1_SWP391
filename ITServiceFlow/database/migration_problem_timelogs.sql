-- Migration: Add ProblemTimeLogs table for Problem investigation time tracking
-- Run this script on your ITServiceFlow database

USE ITServiceFlow
GO

-- Create ProblemTimeLogs table (separate from TimeLogs which tracks Tickets)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProblemTimeLogs')
BEGIN
    CREATE TABLE [dbo].[ProblemTimeLogs](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [ProblemId] [int] NOT NULL,
        [UserId] [int] NOT NULL,
        [StartTime] [datetime] NULL,
        [EndTime] [datetime] NULL,
        [Hours] [decimal](5, 2) NULL,
        [LogDate] [date] NULL,
        PRIMARY KEY CLUSTERED ([Id] ASC)
    )

    ALTER TABLE [dbo].[ProblemTimeLogs] ADD DEFAULT (CONVERT([date], GETDATE())) FOR [LogDate]
    ALTER TABLE [dbo].[ProblemTimeLogs] WITH CHECK ADD CONSTRAINT [FK_ProblemTimeLogs_Problems] 
        FOREIGN KEY([ProblemId]) REFERENCES [dbo].[Problems] ([Id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[ProblemTimeLogs] WITH CHECK ADD CONSTRAINT [FK_ProblemTimeLogs_Users] 
        FOREIGN KEY([UserId]) REFERENCES [dbo].[Users] ([Id])

    PRINT 'ProblemTimeLogs table created successfully.'
END
ELSE
    PRINT 'ProblemTimeLogs table already exists.'
GO
