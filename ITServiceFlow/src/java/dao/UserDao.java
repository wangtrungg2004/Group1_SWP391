/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
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
                user.IsActive(rs.getBoolean("IsActive"));
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
    
    public Users login(String username, String password) {
    // Kiểm tra null hoặc empty
    if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
        return null;
    }
    
    // Kiểm tra connection
    if (connection == null) {
        System.err.println("Database connection is null. Cannot perform login.");
        return null;
    }
    
    // Trim để loại bỏ khoảng trắng
    username = username.trim();
    password = password.trim();
    
    String sql = """
        SELECT Id, Username, FullName, Role, IsActive
        FROM Users
        WHERE Username = ?
          AND PasswordHash = ?
          AND IsActive = 1
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, username);
        ps.setString(2, password); 
        
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
    
    public boolean createUser(Users user) {
        // Kiểm tra connection
        if (connection == null) {
            System.err.println("Database connection is null. Cannot create user.");
            return false;
        }
        
        // Kiểm tra username đã tồn tại chưa
        try {
            String checkSql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkSql);
            checkStmt.setString(1, user.getUsername());
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);
            rs.close();
            checkStmt.close();
            
            if (count > 0) {
                System.err.println("Username đã tồn tại: " + user.getUsername());
                return false;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi kiểm tra username: " + e.getMessage());
            e.printStackTrace();
            return false;
        }

        // Kiểm tra email đã tồn tại chưa (Users.Email có UNIQUE KEY)
        try {
            String checkSql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkSql);
            checkStmt.setString(1, user.getEmail());
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);
            rs.close();
            checkStmt.close();

            if (count > 0) {
                System.err.println("Email đã tồn tại: " + user.getEmail());
                return false;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi kiểm tra email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
        
        // Kiểm tra DepartmentId có tồn tại trong database không
        Integer validDeptId = null;
        if (user.getDepartmentId() > 0) {
            try {
                String deptCheckSql = "SELECT COUNT(*) FROM Departments WHERE Id = ?";
                PreparedStatement deptCheckStmt = connection.prepareStatement(deptCheckSql);
                deptCheckStmt.setInt(1, user.getDepartmentId());
                ResultSet deptRs = deptCheckStmt.executeQuery();
                deptRs.next();
                int deptCount = deptRs.getInt(1);
                deptRs.close();
                deptCheckStmt.close();
                
                if (deptCount > 0) {
                    validDeptId = user.getDepartmentId();
                } else {
                    System.err.println("DepartmentId " + user.getDepartmentId() + " không tồn tại trong database. Sẽ set NULL.");
                }
            } catch (SQLException e) {
                System.err.println("Lỗi khi kiểm tra DepartmentId: " + e.getMessage());
                // Nếu không kiểm tra được, set null để tránh lỗi FOREIGN KEY
            }
        }
        
        // Kiểm tra LocationId có tồn tại trong database không
        Integer validLocId = null;
        if (user.getLocationId() > 0) {
            try {
                String locCheckSql = "SELECT COUNT(*) FROM Locations WHERE Id = ?";
                PreparedStatement locCheckStmt = connection.prepareStatement(locCheckSql);
                locCheckStmt.setInt(1, user.getLocationId());
                ResultSet locRs = locCheckStmt.executeQuery();
                locRs.next();
                int locCount = locRs.getInt(1);
                locRs.close();
                locCheckStmt.close();
                
                if (locCount > 0) {
                    validLocId = user.getLocationId();
                } else {
                    System.err.println("LocationId " + user.getLocationId() + " không tồn tại trong database.");
                }
            } catch (SQLException e) {
                System.err.println("Lỗi khi kiểm tra LocationId: " + e.getMessage());
            }
        }
        
        // Nếu không có ID hợp lệ và bảng Users có cột NOT NULL, dùng ID đầu tiên có trong DB làm fallback
        if (validDeptId == null || validDeptId <= 0) {
            try {
                PreparedStatement fallback = connection.prepareStatement("SELECT TOP 1 Id FROM Departments ORDER BY Id");
                ResultSet rs = fallback.executeQuery();
                if (rs.next()) validDeptId = rs.getInt("Id");
                rs.close();
                fallback.close();
            } catch (SQLException e) { /* bỏ qua */ }
        }
        if (validLocId == null || validLocId <= 0) {
            try {
                PreparedStatement fallback = connection.prepareStatement("SELECT TOP 1 Id FROM Locations ORDER BY Id");
                ResultSet rs = fallback.executeQuery();
                if (rs.next()) validLocId = rs.getInt("Id");
                rs.close();
                fallback.close();
            } catch (SQLException e) { /* bỏ qua */ }
        }
        
        // Insert user mới (nếu vẫn null thì set NULL; nếu có giá trị thì set - một số DB cho phép NULL)
        String sql = """
            INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getRole());
            
            if (validDeptId != null && validDeptId > 0) {
                ps.setInt(6, validDeptId);
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            if (validLocId != null && validLocId > 0) {
                ps.setInt(7, validLocId);
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            
            ps.setBoolean(8, user.IsActive());
            ps.setDate(9, new java.sql.Date(new java.util.Date().getTime()));
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Tạo user thành công: " + user.getUsername());
                return true;
            } else {
                System.err.println("Không có dòng nào được insert vào database.");
                return false;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi SQL khi tạo user: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        }
    }
    
    // Method để kiểm tra username đã tồn tại chưa (public để có thể dùng ở service)
    public boolean usernameExists(String username) {
        if (connection == null || username == null || username.trim().isEmpty()) {
            return false;
        }
        
        try {
            String checkSql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkSql);
            checkStmt.setString(1, username.trim());
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);
            rs.close();
            checkStmt.close();
            
            return count > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi kiểm tra username: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Method để kiểm tra email đã tồn tại chưa
    public boolean emailExists(String email) {
        if (connection == null || email == null || email.trim().isEmpty()) {
            return false;
        }

        try {
            String checkSql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkSql);
            checkStmt.setString(1, email.trim());
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);
            rs.close();
            checkStmt.close();

            return count > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi kiểm tra email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Find user by email
     */
    public Users findByEmail(String email) {
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
                Users user = new Users();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username"));
                user.setEmail(rs.getString("Email"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Set reset token and expiry for forgot password (run add_reset_token_columns.sql first)
     */
    public boolean setResetToken(int userId, String token, java.util.Date expiry) {
        if (connection == null || token == null || expiry == null) return false;
        try {
            ensureResetColumns();
        } catch (SQLException e) {
            System.err.println("Không thể kiểm tra/tạo cột reset token: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
        String sql = "UPDATE Users SET ResetToken = ?, ResetTokenExpiry = ? WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, new java.sql.Timestamp(expiry.getTime()));
            ps.setInt(3, userId);
            int updated = ps.executeUpdate();
            if (updated <= 0) {
                System.err.println("setResetToken: Không update được userId=" + userId);
                return false;
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Đảm bảo bảng Users có cột ResetToken/ResetTokenExpiry.
     * Tự thêm cột nếu thiếu (cần quyền ALTER TABLE).
     */
    private void ensureResetColumns() throws SQLException {
        if (connection == null) throw new SQLException("Database connection is null");

        boolean hasResetToken = false;
        boolean hasResetTokenExpiry = false;

        String checkSql = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Users' AND COLUMN_NAME IN ('ResetToken', 'ResetTokenExpiry')";
        try (PreparedStatement ps = connection.prepareStatement(checkSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String col = rs.getString("COLUMN_NAME");
                if ("ResetToken".equalsIgnoreCase(col)) hasResetToken = true;
                if ("ResetTokenExpiry".equalsIgnoreCase(col)) hasResetTokenExpiry = true;
            }
        }

        if (!hasResetToken) {
            try (PreparedStatement ps = connection.prepareStatement("ALTER TABLE Users ADD ResetToken NVARCHAR(255) NULL")) {
                ps.executeUpdate();
                System.out.println("Đã tự thêm cột Users.ResetToken");
            }
        }
        if (!hasResetTokenExpiry) {
            try (PreparedStatement ps = connection.prepareStatement("ALTER TABLE Users ADD ResetTokenExpiry DATETIME NULL")) {
                ps.executeUpdate();
                System.out.println("Đã tự thêm cột Users.ResetTokenExpiry");
            }
        }
    }

    /**
     * Find user by valid reset token (not expired)
     */
    public Users findByResetToken(String token) {
        if (connection == null || token == null || token.isEmpty()) return null;
        String sql = "SELECT Id, Username, Email, FullName, Role FROM Users WHERE ResetToken = ? AND ResetTokenExpiry > ? AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, new java.sql.Timestamp(System.currentTimeMillis()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Users u = new Users();
                u.setId(rs.getInt("Id"));
                u.setUsername(rs.getString("Username"));
                u.setEmail(rs.getString("Email"));
                u.setFullName(rs.getString("FullName"));
                u.setRole(rs.getString("Role"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Clear reset token after successful password reset
     */
    public boolean clearResetToken(int userId) {
        if (connection == null) return false;
        String sql = "UPDATE Users SET ResetToken = NULL, ResetTokenExpiry = NULL WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update user password by userId
     */
    public boolean updatePassword(int userId, String newPasswordHash) {
        if (connection == null || newPasswordHash == null) return false;
        String sql = "UPDATE Users SET PasswordHash = ? WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Create user from Google OAuth data
     */
    public Users createGoogleUser(String email, String fullName, String googleId) {
        if (connection == null || email == null || email.trim().isEmpty()) {
            return null;
        }

        try {
            // Generate username from email (remove @domain)
            String username = email.split("@")[0] + "_" + System.currentTimeMillis();
            
            // Default role for Google login users
            String role = "User";
            
            // Insert new user
            String sql = """
                INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt)
                VALUES (?, ?, ?, ?, ?, NULL, NULL, 1, ?)
            """;
            
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, googleId); // Use Google ID as password hash (this is a placeholder)
                ps.setString(4, fullName);
                ps.setString(5, role);
                ps.setDate(6, new java.sql.Date(new java.util.Date().getTime()));
                
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    System.out.println("Google user created successfully: " + email);
                    // Return the created user
                    return findByEmail(email);
                }
            }
        } catch (Exception e) {
            System.err.println("Error creating Google user: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
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
