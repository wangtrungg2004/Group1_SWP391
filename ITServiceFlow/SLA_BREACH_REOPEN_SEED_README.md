# Comprehensive SLA Breach & Reopen Demo Seed Data

## 📋 Overview

Created comprehensive seed data for testing and demonstrating SLA breach functionality and ticket reopen features in the ITServiceFlow application.

## 📁 Files Created

### Main Seed Script
- **`database/20260325_seed_comprehensive_sla_breach_reopen_demo.sql`**
  - Complete SQL script with all demo data
  - Creates demo users and 12 demo tickets with various SLA states
  - Fully idempotent (safe to run multiple times)
  - Includes SLATracking records for deadline management

### Execution Helper Script
- **`run_sla_breach_seed.ps1`**
  - PowerShell script to easily execute the seed data
  - Auto-detects SQL Server tools
  - Provides clear feedback and summary

## 👥 Demo Users Created

All users have password: **123456**

| Username | Email | Role | Purpose |
|----------|-------|------|---------|
| `demo.admin` | demo.admin@itserviceflow.local | Admin | System administrator |
| `demo.manager` | demo.manager@itserviceflow.local | Manager | Management user |
| `demo.it` | demo.it@itserviceflow.local | IT Support | Support agent |
| `demo.user` | demo.user@itserviceflow.local | User | Regular user/requester |

## 🎫 Tickets Created

### 1. BREACHED Tickets (3)
Tickets past their SLA resolution deadline:

- **INC-COMPREHENSIVE-SLA-BR-001**
  - Priority: Critical
  - Title: VPN outage at main office
  - Status: Open
  - Breach: 130 minutes overdue
  - Created by: demo.user
  - Assigned to: demo.it

- **INC-COMPREHENSIVE-SLA-BR-002**
  - Priority: High
  - Title: Email service queue stuck
  - Status: In Progress
  - Breach: 70 minutes overdue
  - Created by: demo.user
  - Assigned to: demo.it

- **INC-COMPREHENSIVE-SLA-BR-003**
  - Priority: Critical
  - Title: Main database down
  - Status: Open
  - Breach: 150 minutes overdue
  - Created by: demo.user
  - Assigned to: demo.manager

### 2. NEAR-BREACH Tickets (3)
Tickets approaching their SLA deadline (< 2 hours):

- **INC-COMPREHENSIVE-SLA-BR-NB-001**
  - Priority: High
  - Title: SSO intermittent login failures
  - Status: Open
  - Deadline: 20 minutes from now
  - Created by: demo.user
  - Assigned to: demo.it

- **INC-COMPREHENSIVE-SLA-BR-NB-002**
  - Priority: Medium
  - Title: HR portal timeout during payroll
  - Status: In Progress
  - Deadline: 10 minutes away (will pass soon)
  - Created by: demo.user
  - Assigned to: demo.manager

- **INC-COMPREHENSIVE-SLA-BR-NB-003**
  - Priority: Medium
  - Title: Printer spooler unstable
  - Status: On Hold
  - Deadline: 15 minutes away
  - Created by: demo.user
  - Assigned to: demo.it

### 3. WATCH-LIST Tickets (3)
Tickets to monitor (deadline < 4 hours):

- **INC-COMPREHENSIVE-SLA-BR-WL-001**
  - Priority: Low
  - Title: Shared drive latency spike
  - Status: Open
  - Deadline: 45 minutes away
  - Created by: demo.user
  - Assigned to: demo.it

- **INC-COMPREHENSIVE-SLA-BR-WL-002**
  - Priority: Medium
  - Title: Network connectivity fluctuation
  - Status: In Progress
  - Deadline: 60 minutes away
  - Created by: demo.user
  - Assigned to: demo.manager

- **INC-COMPREHENSIVE-SLA-BR-WL-003**
  - Priority: Low
  - Title: Application performance degradation
  - Status: Open
  - Deadline: 90 minutes away
  - Created by: demo.user
  - Assigned to: demo.it

### 4. REOPENED Tickets (3)
Resolved tickets that have been reopened:

- **INC-COMPREHENSIVE-SLA-REOPEN-001**
  - Priority: High
  - Title: Resolved: VPN outage (reopened)
  - Status: Reopened
  - Reopen Reason: Intermittent VPN drops still occurring
  - Original Status: Resolved (120 min ago)
  - Reopened by: demo.user

- **INC-COMPREHENSIVE-SLA-REOPEN-002**
  - Priority: High
  - Title: Resolved: Email service (reopened)
  - Status: Reopened
  - Reopen Reason: Email still experiencing performance issues
  - Original Status: Resolved (90 min ago)
  - Reopened by: demo.user

- **INC-COMPREHENSIVE-SLA-REOPEN-003**
  - Priority: Low
  - Title: Closed: Temporary internet issue (reopened)
  - Status: Reopened
  - Reopen Reason: Issue recurred
  - Original Status: Closed (60 min ago)
  - Reopened by: demo.user

## 🚀 How to Run

### Method 1: PowerShell Script (Recommended)

```powershell
# Open PowerShell in the project root directory and run:
.\run_sla_breach_seed.ps1
```

**Options:**
```powershell
# Custom SQL Server instance
.\run_sla_breach_seed.ps1 -Server "YOUR_SERVER_NAME"

# Custom database name
.\run_sla_breach_seed.ps1 -Database "YOUR_DB_NAME"

# Both custom
.\run_sla_breach_seed.ps1 -Server "MYSERVER\SQLEXPRESS" -Database "ITServiceFlow"
```

### Method 2: SQL Server Management Studio

1. Open SQL Server Management Studio
2. Connect to your SQL Server instance
3. Open file: `database/20260325_seed_comprehensive_sla_breach_reopen_demo.sql`
4. Execute the script (F5)

### Method 3: sqlcmd Command Line

```bash
sqlcmd -S YOUR_SERVER -d ITServiceFlow -i "database/20260325_seed_comprehensive_sla_breach_reopen_demo.sql"
```

**Replace `YOUR_SERVER` with:**
- `localhost` - Local default instance
- `.` - Local default instance (dot notation)
- `COMPUTERNAME\SQLEXPRESS` - Local named instance
- `SERVER.DOMAIN` - Remote instance

## 📊 SLA Tracking Details

All open tickets are tracked with SLATracking records containing:
- **ResponseDeadline**: Time ticket must be acknowledged
- **ResolutionDeadline**: Time ticket must be resolved
- **IsBreached**: Flag indicating if deadline has passed

Breached tickets will appear in the SLA Breach List view.

## ✅ Verification

After running the script, you can verify the data:

```sql
-- View demo users
SELECT Username, Email, [Role], IsActive FROM dbo.Users WHERE Username LIKE 'demo.%';

-- View all demo tickets
SELECT TicketNumber, Title, [Status], PriorityId FROM dbo.Tickets WHERE TicketNumber LIKE 'INC-COMPREHENSIVE-SLA%';

-- View SLA tracking
SELECT t.TicketNumber, s.ResponseDeadline, s.ResolutionDeadline, s.IsBreached
FROM dbo.SLATracking s
JOIN dbo.Tickets t ON s.TicketId = t.Id
WHERE t.TicketNumber LIKE 'INC-COMPREHENSIVE-SLA%';

-- View ticket reopens
SELECT t.TicketNumber, tr.ReopenReason, tr.ReopenedAt
FROM dbo.TicketReopens tr
JOIN dbo.Tickets t ON tr.TicketId = t.Id
WHERE t.TicketNumber LIKE 'INC-COMPREHENSIVE-SLA%';
```

## 🔑 Login Credentials

Use these credentials to test the features in the application:

```
Username: demo.it (or demo.user, demo.manager, demo.admin)
Password: 123456
```

## 🧹 Clean Up

To remove all demo data:

```sql
-- Delete SLA tracking
DELETE FROM dbo.SLATracking WHERE TicketId IN 
    (SELECT Id FROM dbo.Tickets WHERE TicketNumber LIKE 'INC-COMPREHENSIVE-SLA%');

-- Delete ticket reopens
DELETE FROM dbo.TicketReopens WHERE TicketId IN 
    (SELECT Id FROM dbo.Tickets WHERE TicketNumber LIKE 'INC-COMPREHENSIVE-SLA%');

-- Delete tickets
DELETE FROM dbo.Tickets WHERE TicketNumber LIKE 'INC-COMPREHENSIVE-SLA%';

-- Delete demo users (optional)
DELETE FROM dbo.Users WHERE Username LIKE 'demo.%';
```

## 📝 Notes

- **Idempotent Script**: Safe to run multiple times - existing records are replaced
- **Isolated Data**: All demo data uses prefixes for easy identification and cleanup
- **No Destructive Operations**: Script only creates/updates demo data
- **Transaction Safe**: All changes wrapped in transaction with rollback on error
- **Realistic SLA Scenarios**: Tickets include realistic scenarios for testing SLA display and escalation

## 🔍 Features Demonstrated

✅ **SLA Breach Detection**
- Tickets with past deadlines
- Escalation flags in UI

✅ **SLA Near-Breach Alerts**
- Tickets approaching deadlines
- Warning indicators for proactive management

✅ **SLA Watch List**
- Tickets to monitor
- Upcoming deadline tracking

✅ **Ticket Reopen Workflow**
- Resolved tickets reopened by users
- Reopen reasons tracked
- Status transitions managed

✅ **Multiple User Roles**
- Admin, Manager, IT Support, User
- Role-based ticket visibility
- Assignment workflows

## 📦 Dependencies

- SQL Server with Users, Tickets, SLATracking, TicketReopens tables
- PowerShell 5.1+ (for script execution)
- sqlcmd.exe (included with SQL Server tools)

## 🐛 Troubleshooting

### Issue: "Script not found"
- Ensure you're running from the project root directory
- Check file path exists: `database/20260325_seed_comprehensive_sla_breach_reopen_demo.sql`

### Issue: "Cannot connect to server"
- Verify SQL Server is running
- Check server name is correct
- Ensure you have database create permissions

### Issue: "Cannot find sqlcmd.exe"
- Install SQL Server Command Line Tools (any version)
- Or provide explicit path: `.\run_sla_breach_seed.ps1 -SqlCmdPath "C:\path\to\sqlcmd.exe"`

### Issue: "Table does not exist"
- Run the main database schema first
- Ensure ITServiceFlow database is properly initialized

---

**Created**: 2026-03-25  
**Purpose**: Demo and testing SLA breach + reopen functionality  
**Compatibility**: SQL Server 2016+
