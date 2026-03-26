USE [ITServiceFlow];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Now DATETIME2(0) = SYSDATETIME();
    DECLARE @PwdHash NVARCHAR(255) = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', N'123456'), 2));
    DECLARE @DefaultDeptId INT = NULL;
    DECLARE @DefaultLocId INT = NULL;

    IF OBJECT_ID(N'dbo.Departments', N'U') IS NOT NULL
    BEGIN
        SELECT TOP 1 @DefaultDeptId = Id
        FROM dbo.Departments
        ORDER BY Id;

        IF @DefaultDeptId IS NULL
        BEGIN
            BEGIN TRY
                INSERT INTO dbo.Departments (Name, Code, IsActive)
                VALUES (N'General', N'GEN', 1);
                SET @DefaultDeptId = SCOPE_IDENTITY();
            END TRY
            BEGIN CATCH
                BEGIN TRY
                    INSERT INTO dbo.Departments (Name, IsActive)
                    VALUES (N'General', 1);
                    SET @DefaultDeptId = SCOPE_IDENTITY();
                END TRY
                BEGIN CATCH
                    BEGIN TRY
                        INSERT INTO dbo.Departments (Name)
                        VALUES (N'General');
                        SET @DefaultDeptId = SCOPE_IDENTITY();
                    END TRY
                    BEGIN CATCH
                        SET @DefaultDeptId = NULL;
                    END CATCH
                END CATCH
            END CATCH
        END;
    END;

    IF OBJECT_ID(N'dbo.Locations', N'U') IS NULL
    BEGIN
        THROW 51001, 'Table dbo.Locations is required before seeding users.', 1;
    END;

    SELECT TOP 1 @DefaultLocId = Id
    FROM dbo.Locations
    ORDER BY Id;

    IF @DefaultLocId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.Locations (Name, Code, IsActive)
            VALUES (N'Head Office', N'HO', 1);
        END TRY
        BEGIN CATCH
            BEGIN TRY
                INSERT INTO dbo.Locations (Name, IsActive)
                VALUES (N'Head Office', 1);
            END TRY
            BEGIN CATCH
                INSERT INTO dbo.Locations (Name)
                VALUES (N'Head Office');
            END CATCH
        END CATCH;

        SET @DefaultLocId = SCOPE_IDENTITY();
    END;

    DECLARE @SeedUsers TABLE (
        RowNo INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL,
        Email NVARCHAR(150) NOT NULL,
        FullName NVARCHAR(150) NOT NULL,
        [Role] NVARCHAR(50) NOT NULL
    );

    INSERT INTO @SeedUsers (Username, Email, FullName, [Role])
    VALUES
        (N'admin', N'admin@itserviceflow.local', N'Admin Account', N'Admin'),
        (N'manager1', N'manager1@itserviceflow.local', N'Manager One', N'Manager'),
        (N'user1', N'user1@itserviceflow.local', N'End User One', N'User'),
        (N'user2', N'user2@itserviceflow.local', N'End User Two', N'User'),
        (N'itsupport1', N'itsupport1@itserviceflow.local', N'IT Support One', N'IT Support'),
        (N'itsupport2', N'itsupport2@itserviceflow.local', N'IT Support Two', N'IT Support');

    DECLARE
        @Idx INT = 1,
        @MaxIdx INT,
        @Username NVARCHAR(50),
        @Email NVARCHAR(150),
        @FullName NVARCHAR(150),
        @Role NVARCHAR(50);

    SELECT @MaxIdx = COUNT(*) FROM @SeedUsers;

    WHILE @Idx <= @MaxIdx
    BEGIN
        SELECT
            @Username = Username,
            @Email = Email,
            @FullName = FullName,
            @Role = [Role]
        FROM @SeedUsers
        WHERE RowNo = @Idx;

        IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
        BEGIN
            UPDATE dbo.Users
            SET
                Email = @Email,
                PasswordHash = @PwdHash,
                FullName = @FullName,
                [Role] = @Role,
                DepartmentId = @DefaultDeptId,
                LocationId = @DefaultLocId,
                IsActive = 1
            WHERE Username = @Username;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Users (
                Username,
                Email,
                PasswordHash,
                FullName,
                [Role],
                DepartmentId,
                LocationId,
                IsActive,
                CreatedAt
            )
            VALUES (
                @Username,
                @Email,
                @PwdHash,
                @FullName,
                @Role,
                @DefaultDeptId,
                @DefaultLocId,
                1,
                @Now
            );
        END;

        SET @Idx = @Idx + 1;
    END;

    COMMIT TRANSACTION;

    PRINT 'Seeded login users successfully (default password: 123456).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

SELECT Id, Username, Email, FullName, [Role], IsActive, CreatedAt
FROM dbo.Users
WHERE Username IN (N'admin', N'manager1', N'user1', N'user2', N'itsupport1', N'itsupport2')
ORDER BY [Role], Username;
GO
