# Sample Login Users Seed

This project uses SHA-256 password hash in `Users.PasswordHash` (see `PasswordUtil.sha256()`).
The script `database/sample_users.sql` creates or updates test accounts for login.

## Default credentials

- Username: `admin` / Password: `123456` / Role: `Admin`
- Username: `manager1` / Password: `123456` / Role: `Manager`
- Username: `user1` / Password: `123456` / Role: `User`
- Username: `user2` / Password: `123456` / Role: `User`
- Username: `itsupport1` / Password: `123456` / Role: `IT Support`
- Username: `itsupport2` / Password: `123456` / Role: `IT Support`

## Run seed

Option 1 (PowerShell helper):

```powershell
powershell -ExecutionPolicy Bypass -File .\run_login_seed.ps1
```

Option 2 (sqlcmd):

```powershell
sqlcmd -S localhost -d ITServiceFlow -E -N -C -i database\sample_users.sql
```

## Notes

- Script is idempotent: run multiple times without creating duplicate usernames.
- Existing seeded usernames are updated to active status and reset to password `123456`.
