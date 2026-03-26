USE [ITServiceFlow]
GO

-- Update row 1 (Create Ticket)
UPDATE [dbo].[AuditLogs]
SET [Screen] = 'Ticket Create',
    [DataBefore] = 'N/A',
    [DataAfter] = '{"Title": "Network Issue", "Priority": "High", "Description": "Cannot connect to WiFi"}'
WHERE [Id] = 1;

-- Update row 2 (Update Ticket)
UPDATE [dbo].[AuditLogs]
SET [Screen] = 'Ticket Detail',
    [DataBefore] = '{"Status": "Open", "AssignedTo": "Unassigned"}',
    [DataAfter] = '{"Status": "In Progress", "AssignedTo": "John Doe"}'
WHERE [Id] = 2;

-- Update row 3 (Approve Change Request)
UPDATE [dbo].[AuditLogs]
SET [Screen] = 'Change Request Approval',
    [DataBefore] = '{"Status": "Pending Approval", "ApprovedBy": null}',
    [DataAfter] = '{"Status": "Approved", "ApprovedBy": "Manager"}'
WHERE [Id] = 3;
GO
