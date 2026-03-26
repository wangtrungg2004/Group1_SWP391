USE [ITServiceFlow]
GO

-- 1) Tạo bảng SharedFiles lưu meta file dùng chung
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SharedFiles]') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[SharedFiles] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [OriginalName] NVARCHAR(255) NOT NULL,
        [StoredName] NVARCHAR(255) NOT NULL,
        [MimeType] NVARCHAR(100) NULL,
        [SizeBytes] BIGINT NOT NULL,
        [StoragePath] NVARCHAR(500) NOT NULL,
        [UploadedBy] INT NOT NULL,
        [UploadedAt] DATETIME NOT NULL DEFAULT (GETDATE())
    );
END;
GO

-- 2) Thêm cột FileId vào TicketAttachments nếu chưa có
IF COL_LENGTH('TicketAttachments', 'FileId') IS NULL
BEGIN
    ALTER TABLE [dbo].[TicketAttachments]
        ADD [FileId] INT NULL;
END;
GO

-- 3) Khóa ngoại TicketAttachments.FileId -> SharedFiles.Id nếu chưa có
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_TicketAttachments_FileId'
)
BEGIN
    ALTER TABLE [dbo].[TicketAttachments]
    ADD CONSTRAINT [FK_TicketAttachments_FileId]
        FOREIGN KEY ([FileId]) REFERENCES [dbo].[SharedFiles]([Id]);
END;
GO

-- 4) Tạo bảng KnowledgeAttachments liên kết bài KB với file chung
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KnowledgeAttachments]') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[KnowledgeAttachments] (
        [ArticleId] INT NOT NULL,
        [FileId] INT NOT NULL,
        [AddedBy] INT NOT NULL,
        [AddedAt] DATETIME NOT NULL DEFAULT (GETDATE()),
        CONSTRAINT [PK_KnowledgeAttachments] PRIMARY KEY ([ArticleId], [FileId]),
        CONSTRAINT [FK_KnowledgeAttachments_File] FOREIGN KEY ([FileId]) REFERENCES [dbo].[SharedFiles]([Id])
    );
END;
GO
