
IF NOT EXISTS (SELECT 1 FROM KnowledgeArticles WHERE ArticleNumber = 'KB-0001')
INSERT INTO KnowledgeArticles (ArticleNumber, Title, Content, CategoryId, Status, ViewCount, CreatedBy, CreatedAt)
SELECT
    'KB-0001',
    N'Cach khac phuc loi khong ket noi duoc WiFi',
    N'MO TA VAN DE:
May tinh khong ket noi duoc mang WiFi, hien thi dau cham than mau vang hoac thong bao "No Internet Access".

NGUYEN NHAN THUONG GAP:
- Driver card mang bi loi hoac loi thoi
- Xung dot IP address
- DNS server khong phan hoi
- Router/AP bi loi

CAC BUOC XU LY:

Buoc 1: Khoi dong lai Network Adapter
   - Nhan Windows + R, gõ ncpa.cpl, nhan Enter
   - Click phai vao WiFi adapter, chon Disable, sau 5 giay Enable lai

Buoc 2: Reset TCP/IP va DNS (mo Command Prompt voi quyen Administrator)
   netsh int ip reset
   netsh winsock reset
   ipconfig /flushdns
   ipconfig /release
   ipconfig /renew
   - Khoi dong lai may

Buoc 3: Kiem tra/cap nhat Driver
   - Nhan Windows + X, chon Device Manager
   - Expand Network Adapters
   - Click phai vao WiFi card, chon Update driver

Buoc 4: Neu van khong duoc
   - Khoi dong lai router/modem
   - Thu ket noi thiet bi khac vao cung WiFi de xac dinh loi o may hay router
   - Lien he IT Support de ho tro them

KET QUA MONG DOI: May ket noi duoc WiFi va truy cap Internet binh thuong.',
    (SELECT TOP 1 Id FROM Categories ORDER BY Id),
    'Published',
    0,
    (SELECT TOP 1 Id FROM Users WHERE Role = 'Admin' ORDER BY Id),
    GETDATE();

-- ============================================================
-- Bai 2: May tinh bi cham
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM KnowledgeArticles WHERE ArticleNumber = 'KB-0002')
INSERT INTO KnowledgeArticles (ArticleNumber, Title, Content, CategoryId, Status, ViewCount, CreatedBy, CreatedAt)
SELECT
    'KB-0002',
    N'Xu ly may tinh chay cham, dung may',
    N'MO TA VAN DE:
May tinh hoat dong cham bat thuong, mo ung dung lau, co the bi do/treo.

NGUYEN NHAN THUONG GAP:
- RAM day do nhieu ung dung chay cung luc
- O cung gan day (duoi 10% dung luong trong)
- Virus/malware
- Nhieu chuong trinh khoi dong cung Windows
- Qua nhiet CPU/GPU

CAC BUOC XU LY:

Buoc 1: Kiem tra tai nguyen he thong
   - Nhan Ctrl + Shift + Esc mo Task Manager
   - Tab Performance: kiem tra CPU, RAM, Disk usage
   - Tab Processes: ket thuc process ngon tai nguyen khong can thiet

Buoc 2: Don dep o cung
   - Nhan Windows + R, gõ cleanmgr, chon o C, nhan OK
   - Tick chon tat ca muc, nhan OK, chon Delete Files
   - Xoa thu muc temp: Windows + R, gõ %temp%, xoa tat ca

Buoc 3: Tat chuong trinh khoi dong khong can thiet
   - Task Manager, tab Startup
   - Click phai vao chuong trinh khong can, chon Disable

Buoc 4: Quet virus
   - Chay Windows Defender hoac phan mem diet virus dang cai
   - Full scan toan bo o cung

Buoc 5: Kiem tra nhiet do
   - Tai HWMonitor hoac Core Temp de xem nhiet do CPU
   - Neu CPU > 90 do C: ve sinh quat tan nhiet hoac lien he IT Support

KET QUA MONG DOI: May tinh hoat dong nhanh hon, khong con dung may.',
    (SELECT TOP 1 Id FROM Categories ORDER BY Id),
    'Published',
    0,
    (SELECT TOP 1 Id FROM Users WHERE Role = 'Admin' ORDER BY Id),
    GETDATE();

-- ============================================================
-- Bai 3: Man hinh xanh BSOD
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM KnowledgeArticles WHERE ArticleNumber = 'KB-0003')
INSERT INTO KnowledgeArticles (ArticleNumber, Title, Content, CategoryId, Status, ViewCount, CreatedBy, CreatedAt)
SELECT
    'KB-0003',
    N'Xu ly loi man hinh xanh BSOD Blue Screen of Death',
    N'MO TA VAN DE:
May tinh dot ngot xuat hien man hinh xanh voi ma loi nhu IRQL_NOT_LESS_OR_EQUAL, MEMORY_MANAGEMENT, PAGE_FAULT_IN_NONPAGED_AREA.

NGUYEN NHAN THUONG GAP:
- Driver phan cung loi (thuong gap o card do hoa, card mang)
- RAM bi loi hoac khong tuong thich
- Windows Update loi
- O cung co bad sector

CAC BUOC XU LY:

Buoc 1: Ghi lai ma loi
   - Chup anh man hinh xanh, dac biet dong chu STOP hoac ma loi
   - Ma loi se giup xac dinh nguyen nhan chinh xac hon

Buoc 2: Khoi dong lai va vao Safe Mode neu can
   - Giu Shift + nhan Restart
   - Chon Troubleshoot, Advanced options, Startup Settings, Restart
   - Nhan 4 hoac F4 de vao Safe Mode

Buoc 3: Kiem tra RAM
   - Nhan Windows + R, gõ mdsched.exe, chon Restart now
   - Windows se kiem tra RAM khi khoi dong lai

Buoc 4: Cap nhat hoac rollback Driver
   - Device Manager, click phai driver moi cai, chon Roll Back Driver
   - Hoac vao Windows Update, View update history, Uninstall updates

Buoc 5: Kiem tra o cung (mo Command Prompt Admin)
   chkdsk C: /f /r
   - Khoi dong lai de chkdsk chay

Buoc 6: Neu loi lien tuc
   - Lien he IT Support, cung cap ma loi va thoi diem xay ra

KET QUA MONG DOI: Xac dinh va khac phuc nguyen nhan gay BSOD.',
    (SELECT TOP 1 Id FROM Categories ORDER BY Id),
    'Published',
    0,
    (SELECT TOP 1 Id FROM Users WHERE Role = 'Admin' ORDER BY Id),
    GETDATE();

-- ============================================================
-- Bai 4: Khong in duoc
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM KnowledgeArticles WHERE ArticleNumber = 'KB-0004')
INSERT INTO KnowledgeArticles (ArticleNumber, Title, Content, CategoryId, Status, ViewCount, CreatedBy, CreatedAt)
SELECT
    'KB-0004',
    N'Khong in duoc tai lieu - huong dan xu ly may in',
    N'MO TA VAN DE:
May tinh khong in duoc, lenh in bi treo trong hang doi print queue hoac may in khong phan hoi.

NGUYEN NHAN THUONG GAP:
- Print Spooler service bi dung
- Hang doi in bi ket
- Driver may in loi
- May in ngoai tuyen (Offline)

CAC BUOC XU LY:

Buoc 1: Kiem tra trang thai may in
   - Control Panel, Devices and Printers
   - Neu may in hien Offline: Click phai, chon See what''s printing
   - Vao menu Printer, bo check muc Use Printer Offline

Buoc 2: Xoa hang doi in bi ket
   - Mo Services (Windows + R, gõ services.msc)
   - Tim Print Spooler, Click phai, chon Stop
   - Mo File Explorer, vao duong dan: C:\Windows\System32\spool\PRINTERS
   - Xoa tat ca file trong thu muc PRINTERS (khong xoa thu muc)
   - Quay lai Services, Start Print Spooler lai

Buoc 3: Cai lai driver may in
   - Devices and Printers, Click phai vao may in, chon Remove device
   - Tai driver moi nhat tu website cua hang may in
   - Cai dat lai

Buoc 4: Kiem tra ket noi vat ly
   - Neu dung USB: rut ra cam lai vao cong USB khac
   - Neu dung mang: dam bao may in va may tinh cung mang

KET QUA MONG DOI: In tai lieu thanh cong.',
    (SELECT TOP 1 Id FROM Categories ORDER BY Id),
    'Published',
    0,
    (SELECT TOP 1 Id FROM Users WHERE Role = 'Admin' ORDER BY Id),
    GETDATE();

-- ============================================================
-- Bai 5: Quen mat khau Windows
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM KnowledgeArticles WHERE ArticleNumber = 'KB-0005')
INSERT INTO KnowledgeArticles (ArticleNumber, Title, Content, CategoryId, Status, ViewCount, CreatedBy, CreatedAt)
SELECT
    'KB-0005',
    N'Quen mat khau dang nhap Windows - cac buoc can lam',
    N'MO TA VAN DE:
Nguoi dung quen mat khau dang nhap Windows, khong the truy cap vao may tinh.

LUU Y QUAN TRONG:
Vi ly do bao mat, IT Support se can xac minh danh tinh nguoi dung truoc khi ho tro reset mat khau.

CAC BUOC NGUOI DUNG CAN LAM:

Buoc 1: Thu cac tuy chon dang nhap khac
   - Neu may dung tai khoan Microsoft: nhan I forgot my PIN, xac minh qua email/so dien thoai da dang ky
   - Neu co PIN: thu dang nhap bang PIN thay vi password

Buoc 2: Dang nhap bang tai khoan domain (may cong ty)
   - Lien he IT Support de admin reset mat khau domain
   - Cung cap: ho ten, ma nhan vien/sinh vien, phong ban

Buoc 3: Tao ticket ho tro
   - Tao ticket voi thong tin:
     + Loai may, serial number
     + Thoi diem xay ra van de
     + Tai khoan dang nhap (username)

IT SUPPORT SE:
- Xac minh danh tinh nguoi dung
- Reset mat khau domain qua Active Directory
- Huong dan dat mat khau moi an toan

KET QUA MONG DOI: Nguoi dung dang nhap duoc vao may tinh voi mat khau moi.',
    (SELECT TOP 1 Id FROM Categories ORDER BY Id),
    'Published',
    0,
    (SELECT TOP 1 Id FROM Users WHERE Role = 'Admin' ORDER BY Id),
    GETDATE();

-- ============================================================
-- Bai 6: Loi phan mem Microsoft Office
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM KnowledgeArticles WHERE ArticleNumber = 'KB-0006')
INSERT INTO KnowledgeArticles (ArticleNumber, Title, Content, CategoryId, Status, ViewCount, CreatedBy, CreatedAt)
SELECT
    'KB-0006',
    N'Microsoft Office bi loi, khong mo duoc Word Excel PowerPoint',
    N'MO TA VAN DE:
Word, Excel hoac PowerPoint khong mo duoc, bi crash khi mo, hoac hien thong bao loi khi khoi dong.

NGUYEN NHAN THUONG GAP:
- File cai dat Office bi hong
- Add-in ben thu 3 xung dot
- File Normal.dotm (Word template) bi hong
- License het han

CAC BUOC XU LY:

Buoc 1: Mo Office o Safe Mode de kiem tra
   - Nhan Windows + R
   - Gõ: winword /safe (cho Word) hoac excel /safe (cho Excel)
   - Neu mo duoc o Safe Mode: loi do Add-in

Buoc 2: Tat Add-in
   - File, Options, Add-Ins
   - Manage COM Add-ins, nhan Go
   - Bo tick tat ca Add-in, nhan OK, Restart Office

Buoc 3: Repair Office
   - Control Panel, Programs, Programs and Features
   - Click phai Microsoft Office, chon Change, Quick Repair, nhan Repair
   - Neu Quick Repair khong duoc: chon Online Repair

Buoc 4: Xoa file template bi hong (chi cho Word)
   - Mo File Explorer, vao %appdata%\Microsoft\Templates
   - Doi ten hoac xoa file Normal.dotm
   - Mo Word lai (se tu tao Normal.dotm moi)

Buoc 5: Kiem tra License
   - Mo bat ky ung dung Office, vao File, Account
   - Kiem tra trang thai ban quyen
   - Lien he IT Support neu can gia han

KET QUA MONG DOI: Mo va su dung duoc cac ung dung Office binh thuong.',
    (SELECT TOP 1 Id FROM Categories ORDER BY Id),
    'Published',
    0,
    (SELECT TOP 1 Id FROM Users WHERE Role = 'Admin' ORDER BY Id),
    GETDATE();

-- Xem ket qua
SELECT Id, ArticleNumber, Title, Status, ViewCount, CreatedAt
FROM KnowledgeArticles
ORDER BY Id DESC;
