-- Sample SQL script for ITServiceFlow demo data
-- 1. Insert sample Categories
INSERT INTO Categories (Id, Name) VALUES
  (1, N'Phần mềm'),
  (2, N'Phần cứng'),
  (3, N'Mạng'),
  (4, N'Thiết bị ngoại vi');

-- 2. Insert sample Tickets (ensure CategoryId exists in Categories)
INSERT INTO Tickets (Title, Description, CategoryId, Status)
VALUES
  (N'Lỗi đăng nhập', N'Không đăng nhập được hệ thống', 1, N'Open'),
  (N'Máy in không in', N'Máy in phòng IT không hoạt động', 4, N'Open'),
  (N'Mạng chậm', N'Kết nối mạng rất chậm vào buổi sáng', 3, N'Open');

-- 3. Insert sample Knowledge Articles
INSERT INTO KnowledgeArticles (Id, Title, Content)
VALUES
  (1, N'Hướng dẫn reset mật khẩu', N'Bước 1: ...'),
  (2, N'Sửa lỗi máy in', N'Kiểm tra nguồn điện...');

-- 4. Insert sample Files (for Shared Upload Module)
INSERT INTO Files (Id, FileName, FilePath)
VALUES
  (1, N'huongdan.pdf', N'/uploads/huongdan.pdf'),
  (2, N'loi-mayin.jpg', N'/uploads/loi-mayin.jpg');

-- 5. Insert Ticket Attachments (link file to ticket)
INSERT INTO TicketAttachments (TicketId, FileId)
VALUES
  (1, 1),
  (2, 2);

-- 6. Insert KB Attachments (link file to KB article)
INSERT INTO KnowledgeArticleAttachments (ArticleId, FileId)
VALUES
  (1, 1),
  (2, 2);

-- Note: Adjust table/column names if your schema differs.
-- Ensure all referenced Ids exist in parent tables before running this script.
