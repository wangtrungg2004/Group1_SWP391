/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Users;
import Utils.DbContext;
/**
 *
 * @author DELL
 */
public class UserDao extends DbContext{
    public List<Users> getAllUsers()
    {
        List<Users> list = new ArrayList<>();
        
        // Kiểm tra connection
        if (connection == null) {
            System.err.println("Database connection is null. Cannot get users.");
            return list;
        }
        
        String sql = "SELECT [Id]\n" +
            "      ,[Username]\n" +
            "      ,[Email]\n" +
            "      ,[PasswordHash]\n" +
            "      ,[FullName]\n" +
            "      ,[Role]\n" +
            "      ,[DepartmentId]\n" +
            "      ,[LocationId]\n" +
            "      ,[IsActive]\n" +
            "      ,[CreatedAt]\n" +
            "  FROM [dbo].[Users]";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                Users user = new Users();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username")); // Username là cột thứ 2
                user.setEmail(rs.getString("Email"));
                user.setPasswordHash(rs.getString("PasswordHash"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                user.setDepartmentId(rs.getInt("DepartmentId"));
                user.setLocationId(rs.getInt("LocationId"));
                user.setIsActive(rs.getBoolean("IsActive"));
                user.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(user);
                
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public Users login(String username, String passwordHash) {
    // Kiểm tra null hoặc empty
    if (username == null || passwordHash == null || username.trim().isEmpty() || passwordHash.trim().isEmpty()) {
        return null;
    }
    
    // Kiểm tra connection
    if (connection == null) {
        System.err.println("Database connection is null. Cannot perform login.");
        return null;
    }
    
    // Trim để loại bỏ khoảng trắng
    username = username.trim();
    passwordHash = passwordHash.trim();
    
    // [PASSWORD_HASH] so sánh với cột PasswordHash; khi bỏ hash: đổi tham số thành password (plain), cột thành Password
    String sql = """
        SELECT Id, Username, FullName, Role, IsActive
        FROM Users
        WHERE Username = ?
          AND PasswordHash = ?
          AND IsActive = 1
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, username);
        ps.setString(2, passwordHash); 
        
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            Users u = new Users();
            u.setId(rs.getInt("Id"));
            u.setUsername(rs.getString("Username"));
            u.setFullName(rs.getString("FullName"));
            u.setRole(rs.getString("Role"));
            return u;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

    public boolean resetPassword(String username, String email, String newPasswordHash) {
        if (username == null || email == null || newPasswordHash == null) {
            return false;
        }
        if (connection == null) {
            System.err.println("Database connection is null. Cannot reset password.");
            return false;
        }

        // [PASSWORD_HASH] ghi PasswordHash vào DB; khi bỏ hash: tham số thành newPassword (plain), cột thành Password
        String sql = """
            UPDATE Users
            SET PasswordHash = ?
            WHERE Username = ?
              AND Email = ?
              AND IsActive = 1
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash.trim());
            ps.setString(2, username.trim());
            ps.setString(3, email.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getDefaultLocationId() {
        if (connection == null) {
            return -1;
        }
        String sql = "SELECT TOP 1 Id FROM Locations ORDER BY Id";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("Id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean createUser(String username, String email, String passwordHash, String fullName, String role, Integer departmentId, int locationId) {
        if (connection == null) {
            return false;
        }
        // [PASSWORD_HASH] insert cột PasswordHash; khi bỏ hash: tham số thành password (plain), cột DB thành Password
        String sql = """
                INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1, GETDATE())
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, passwordHash);
            ps.setString(4, fullName);
            ps.setString(5, role);
            if (departmentId == null) {
                ps.setNull(6, Types.INTEGER);
            } else {
                ps.setInt(6, departmentId);
            }
            ps.setInt(7, locationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public Users getUserByEmail(String email) {
        if (connection == null || email == null || email.trim().isEmpty()) {
            return null;
        }
        String sql = """
            SELECT Id, Username, Email, FullName, Role, IsActive
            FROM Users
            WHERE Email = ?
              AND IsActive = 1
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Users u = new Users();
                u.setId(rs.getInt("Id"));
                u.setUsername(rs.getString("Username"));
                u.setEmail(rs.getString("Email"));
                u.setFullName(rs.getString("FullName"));
                u.setRole(rs.getString("Role"));
                u.setIsActive(rs.getBoolean("IsActive"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean savePasswordResetToken(int userId, String token, Timestamp expiresAt) {
        if (connection == null || token == null || expiresAt == null) {
            return false;
        }
        String sql = """
            INSERT INTO PasswordResetTokens (UserId, Token, ExpiresAt, IsUsed)
            VALUES (?, ?, ?, 0)
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, token);
            ps.setTimestamp(3, expiresAt);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Integer getValidUserIdByToken(String token) {
        if (connection == null || token == null || token.trim().isEmpty()) {
            return null;
        }
        String sql = """
            SELECT TOP 1 UserId
            FROM PasswordResetTokens
            WHERE Token = ?
              AND IsUsed = 0
              AND ExpiresAt > GETDATE()
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("UserId");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean markTokenUsed(String token) {
        if (connection == null || token == null || token.trim().isEmpty()) {
            return false;
        }
        String sql = """
            UPDATE PasswordResetTokens
            SET IsUsed = 1
            WHERE Token = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePasswordByUserId(int userId, String newPasswordHash) {
        if (connection == null || newPasswordHash == null || newPasswordHash.trim().isEmpty()) {
            return false;
        }
        // [PASSWORD_HASH] update cột PasswordHash; khi bỏ hash: tham số thành newPassword (plain), cột thành Password
        String sql = """
            UPDATE Users
            SET PasswordHash = ?
            WHERE Id = ?
              AND IsActive = 1
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash.trim());
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Users getUserById(int userId) {
        if (connection == null || userId <= 0) {
            return null;
        }
        String sql = """
            SELECT TOP 1
                u.Id, u.Username, u.Email, u.FullName, u.Role, u.DepartmentId, u.LocationId,
                u.IsActive, u.CreatedAt,
                d.Name AS DepartmentName,
                l.Name AS LocationName
            FROM Users u
            LEFT JOIN Departments d ON u.DepartmentId = d.Id
            LEFT JOIN Locations l ON u.LocationId = l.Id
            WHERE u.Id = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Users user = new Users();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username"));
                user.setEmail(rs.getString("Email"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                user.setDepartmentId(rs.getInt("DepartmentId"));
                user.setLocationId(rs.getInt("LocationId"));
                user.setDepartmentName(rs.getString("DepartmentName"));
                user.setLocationName(rs.getString("LocationName"));
                user.setIsActive(rs.getBoolean("IsActive"));
                user.setCreatedAt(rs.getTimestamp("CreatedAt"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Users getUserByUsername(String username) {
        if (connection == null || username == null || username.trim().isEmpty()) {
            return null;
        }
        String sql = """
            SELECT TOP 1 Id, Username, Email, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt
            FROM Users
            WHERE Username = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Users u = new Users();
                u.setId(rs.getInt("Id"));
                u.setUsername(rs.getString("Username"));
                u.setEmail(rs.getString("Email"));
                u.setFullName(rs.getString("FullName"));
                u.setRole(rs.getString("Role"));
                u.setDepartmentId(rs.getInt("DepartmentId"));
                u.setLocationId(rs.getInt("LocationId"));
                u.setIsActive(rs.getBoolean("IsActive"));
                u.setCreatedAt(rs.getTimestamp("CreatedAt"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isEmailUsedByOtherUser(String email, int excludedUserId) {
        if (connection == null || email == null || email.trim().isEmpty()) {
            return false;
        }
        String sql = """
            SELECT COUNT(1)
            FROM Users
            WHERE Email = ?
              AND Id <> ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setInt(2, excludedUserId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Users> searchUsersForManagement(String keyword, String roleFilter, String statusFilter) {
        return searchUsersForManagement(keyword, roleFilter, statusFilter, 0, Integer.MAX_VALUE);
    }

    public List<Users> searchUsersForManagement(String keyword, String roleFilter, String statusFilter, int offset, int limit) {
        List<Users> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }
        if (offset < 0) {
            offset = 0;
        }
        if (limit <= 0) {
            limit = 10;
        }

        StringBuilder sql = new StringBuilder("""
            SELECT
                u.Id, u.Username, u.Email, u.FullName, u.Role, u.DepartmentId, u.LocationId,
                u.IsActive, u.CreatedAt,
                d.Name AS DepartmentName,
                l.Name AS LocationName
            FROM Users u
            LEFT JOIN Departments d ON u.DepartmentId = d.Id
            LEFT JOIN Locations l ON u.LocationId = l.Id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.Username LIKE ? OR u.Email LIKE ? OR u.FullName LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (roleFilter != null && !roleFilter.trim().isEmpty()) {
            sql.append(" AND u.Role = ?");
            params.add(roleFilter.trim());
        }
        if ("active".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND u.IsActive = 1");
        } else if ("inactive".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND u.IsActive = 0");
        }
        sql.append(" ORDER BY u.CreatedAt DESC, u.Id DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int index = 1;
            for (Object param : params) {
                ps.setObject(index++, param);
            }
            ps.setInt(index++, offset);
            ps.setInt(index, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Users user = new Users();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username"));
                user.setEmail(rs.getString("Email"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                user.setDepartmentId(rs.getInt("DepartmentId"));
                user.setLocationId(rs.getInt("LocationId"));
                user.setDepartmentName(rs.getString("DepartmentName"));
                user.setLocationName(rs.getString("LocationName"));
                user.setIsActive(rs.getBoolean("IsActive"));
                user.setCreatedAt(rs.getTimestamp("CreatedAt"));
                list.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countUsersForManagement(String keyword, String roleFilter, String statusFilter) {
        if (connection == null) {
            return 0;
        }

        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(1)
            FROM Users u
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.Username LIKE ? OR u.Email LIKE ? OR u.FullName LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (roleFilter != null && !roleFilter.trim().isEmpty()) {
            sql.append(" AND u.Role = ?");
            params.add(roleFilter.trim());
        }
        if ("active".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND u.IsActive = 1");
        } else if ("inactive".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND u.IsActive = 0");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int index = 1;
            for (Object param : params) {
                ps.setObject(index++, param);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<Integer, String> getDepartmentOptions() {
        Map<Integer, String> options = new LinkedHashMap<>();
        if (connection == null) {
            return options;
        }

        String sql = "SELECT Id, Name FROM Departments ORDER BY Name ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                options.put(rs.getInt("Id"), rs.getString("Name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return options;
    }

    public Map<Integer, String> getLocationOptions() {
        Map<Integer, String> options = new LinkedHashMap<>();
        if (connection == null) {
            return options;
        }

        String sql = "SELECT Id, Name FROM Locations WHERE IsActive = 1 ORDER BY Name ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                options.put(rs.getInt("Id"), rs.getString("Name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return options;
    }

    public boolean updateUserForAdmin(int id, String fullName, String email, String role, Integer departmentId, Integer locationId) {
        if (connection == null || id <= 0 || email == null || email.trim().isEmpty()
                || role == null || role.trim().isEmpty()) {
            return false;
        }

        String sql = """
            UPDATE Users
            SET FullName = ?,
                Email = ?,
                Role = ?,
                DepartmentId = ?,
                LocationId = ?
            WHERE Id = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName == null ? null : fullName.trim());
            ps.setString(2, email.trim());
            ps.setString(3, role.trim());
            if (departmentId == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, departmentId);
            }
            if (locationId == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(5, locationId);
            }
            ps.setInt(6, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateUserInfoForAdmin(int id, String fullName, String email, Integer departmentId, Integer locationId) {
        if (connection == null || id <= 0 || email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = """
            UPDATE Users
            SET FullName = ?,
                Email = ?,
                DepartmentId = ?,
                LocationId = ?
            WHERE Id = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName == null ? null : fullName.trim());
            ps.setString(2, email.trim());
            if (departmentId == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, departmentId);
            }
            if (locationId == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, locationId);
            }
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateUserRoleForAdmin(int id, String role) {
        if (connection == null || id <= 0 || role == null || role.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE Users SET Role = ? WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, role.trim());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean setUserActiveStatus(int id, boolean active) {
        if (connection == null || id <= 0) {
            return false;
        }
        String sql = "UPDATE Users SET IsActive = ? WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getTotalUser()
    {
        String sql = "SELECT COUNT(*)"
                + " FROM [dbo].[Users]"
                + " WHERE IsActive = 1";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            if(rs.next())
            {
                return rs.getInt(1);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return 0;
    }

    public List<Users> getTopAgentsThisMonth() {
        List<Users> list = new ArrayList<>();
        String sql = "SELECT TOP 10\n" +
"                u.Id        AS AgentId,\n" +
"                u.FullName  AS AgentName,\n" +
"                COUNT(t.Id) AS TicketCount\n" +
"            FROM [dbo].[Tickets] t\n" +
"            INNER JOIN [dbo].[Users] u ON t.AssignedTo = u.Id\n" +
"            WHERE t.Status IN ('Resolved', 'Approved', 'Closed')\n" +
//"              AND t.AssignedTo IS NOT NULL\n" +
//"              AND YEAR(t.UpdatedAt) = YEAR(GETDATE())\n" +
//"              AND MONTH(t.UpdatedAt) = MONTH(GETDATE())\n" +
"            GROUP BY u.Id, u.FullName\n" +
"            ORDER BY COUNT(t.Id) DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Users u = new Users();
                u.setId(rs.getInt("AgentId"));
                u.setFullName(rs.getString("AgentName"));
                u.setTicketCount(rs.getInt("TicketCount"));

                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
    
//    public static void main(String[] args) {
//        UserDao dao = new UserDao();
//        List<Users> users = dao.getAllUsers();
//
//        if (users == null || users.isEmpty()) {
//            System.out.println("Error");
//        } else {
//            System.out.println("User List:");
//            for (Users u : users) {
//                System.out.println(
//                    u.getId() + " | "
//                    + u.getUsername()+ " | "
//                    + u.getEmail() + " | "
//                    + u.getRole()
//                );
//            }
//        }
//    }

    
    
     public static void main(String[] args) {
        UserDao dao = new UserDao();

        String username = "admin";   
        String password = "123456";  

        Users user = dao.login(username, password);

        if (user != null) {
            System.out.println("Login Success");
        } else {
            System.out.println("Login Failed");
            System.out.println("ID: " + user.getId());
            System.out.println("Username: " + user.getUsername());
            System.out.println("FullName: " + user.getFullName());
            System.out.println("Role: " + user.getRole());
        }
    }
}
