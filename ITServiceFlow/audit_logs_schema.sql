USE [ITServiceFlow]
GO

-- Add Screen column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AuditLogs]') AND name = 'Screen')
BEGIN
    ALTER TABLE [dbo].[AuditLogs] ADD [Screen] [nvarchar](50) NULL;
END
GO

-- Add DataBefore column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AuditLogs]') AND name = 'DataBefore')
BEGIN
    ALTER TABLE [dbo].[AuditLogs] ADD [DataBefore] [nvarchar](max) NULL;
END
GO

-- Add DataAfter column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AuditLogs]') AND name = 'DataAfter')
BEGIN
    ALTER TABLE [dbo].[AuditLogs] ADD [DataAfter] [nvarchar](max) NULL;
END
GO
