
-- Step 1: Them Categories voi du columns
IF NOT EXISTS (SELECT 1 FROM Categories)
BEGIN
    INSERT INTO Categories (Name, ParentId, Level, FullPath, IsActive)
    VALUES (N'Network', NULL, 1, N'Network', 1);

    INSERT INTO Categories (Name, ParentId, Level, FullPath, IsActive)
    VALUES (N'Hardware', NULL, 1, N'Hardware', 1);

    INSERT INTO Categories (Name, ParentId, Level, FullPath, IsActive)
    VALUES (N'Software', NULL, 1, N'Software', 1);

    INSERT INTO Categories (Name, ParentId, Level, FullPath, IsActive)
    VALUES (N'Printer', NULL, 1, N'Printer', 1);

    PRINT 'Inserted sample Categories';
END

-- Step 2: Them Locations neu trong
IF NOT EXISTS (SELECT 1 FROM Locations)
BEGIN
    INSERT INTO Locations (Name) VALUES (N'Tang 1');
    INSERT INTO Locations (Name) VALUES (N'Tang 2');
    INSERT INTO Locations (Name) VALUES (N'Tang 3');
    PRINT 'Inserted sample Locations';
END

-- Step 3: Lay ID hop le
DECLARE @ITSupportId INT;
DECLARE @CatId  INT;
DECLARE @LocId  INT;
DECLARE @UserId INT;

SELECT TOP 1 @ITSupportId = Id FROM Users WHERE Username = 'itsupport1';
IF @ITSupportId IS NULL SELECT TOP 1 @ITSupportId = Id FROM Users WHERE Role = 'IT Support' ORDER BY Id;
IF @ITSupportId IS NULL SET @ITSupportId = 1;

SELECT TOP 1 @CatId = Id FROM Categories ORDER BY Id;
SELECT TOP 1 @LocId = Id FROM Locations ORDER BY Id;

SELECT TOP 1 @UserId = Id FROM Users WHERE Role = 'User' ORDER BY Id;
IF @UserId IS NULL SET @UserId = 1;

PRINT 'ITSupportId=' + CAST(@ITSupportId AS VARCHAR) + ', CatId=' + CAST(@CatId AS VARCHAR) + ', LocId=' + CAST(@LocId AS VARCHAR);

-- Step 4: Insert Resolved Tickets
IF NOT EXISTS (SELECT 1 FROM Tickets WHERE TicketNumber = 'INC-SAMPLE001')
    INSERT INTO Tickets (TicketNumber, TicketType, Title, Description,
                         CategoryId, LocationId,
                         Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval,
                         Status, CreatedBy, AssignedTo, ResolvedAt, CreatedAt, UpdatedAt)
    VALUES ('INC-SAMPLE001', 'Incident',
            N'May tinh khong ket noi WiFi',
            N'May tinh phong 201 khong ket noi duoc mang WiFi tu sang som. Da thu khoi dong lai nhung van khong duoc.',
            @CatId, @LocId,
            2, 2, NULL, NULL, 0,
            'Resolved', @UserId, @ITSupportId,
            GETDATE(), DATEADD(day,-2,GETDATE()), GETDATE());

IF NOT EXISTS (SELECT 1 FROM Tickets WHERE TicketNumber = 'INC-SAMPLE002')
    INSERT INTO Tickets (TicketNumber, TicketType, Title, Description,
                         CategoryId, LocationId,
                         Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval,
                         Status, CreatedBy, AssignedTo, ResolvedAt, CreatedAt, UpdatedAt)
    VALUES ('INC-SAMPLE002', 'Incident',
            N'May in tang 3 khong in duoc',
            N'May in HP LaserJet phong 301 bi treo lenh in. Hang doi print queue co 15 lenh bi ket.',
            @CatId, @LocId,
            1, 2, NULL, NULL, 0,
            'Resolved', @UserId, @ITSupportId,
            GETDATE(), DATEADD(day,-1,GETDATE()), GETDATE());

IF NOT EXISTS (SELECT 1 FROM Tickets WHERE TicketNumber = 'INC-SAMPLE003')
    INSERT INTO Tickets (TicketNumber, TicketType, Title, Description,
                         CategoryId, LocationId,
                         Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval,
                         Status, CreatedBy, AssignedTo, ResolvedAt, CreatedAt, UpdatedAt)
    VALUES ('INC-SAMPLE003', 'Incident',
            N'Microsoft Word crash khi mo file',
            N'Word 2019 bi crash ngay khi mo bat ky file .docx nao. Loi: Microsoft Word has stopped working.',
            @CatId, @LocId,
            2, 3, NULL, NULL, 0,
            'Resolved', @UserId, @ITSupportId,
            GETDATE(), DATEADD(hour,-5,GETDATE()), GETDATE());

-- Xem ket qua
SELECT Id, TicketNumber, Title, Status, Impact, Urgency, ResolvedAt
FROM Tickets WHERE Status = 'Resolved' ORDER BY Id DESC;
