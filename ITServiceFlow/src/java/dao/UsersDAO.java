package dao;

import Utils.DbContext;
import model.Users;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UsersDAO extends DbContext {

    // Lấy thông tin user theo ID
    public Users getUserById(int userId) {
        String sql = "SELECT Id, Username, Email, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt "
                   + "FROM Users WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching user by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Lấy danh sách tất cả users đang active
    public List<Users> getAllUsers() {
        List<Users> users = new ArrayList<>();
        String sql = "SELECT Id, Username, Email, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt "
                   + "FROM Users WHERE IsActive = 1 ORDER BY FullName ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all users: " + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }

    // Tìm kiếm user theo tên / email / username
    public List<Users> searchUsers(String keyword) {
        List<Users> users = new ArrayList<>();
        String sql = "SELECT Id, Username, Email, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt "
                   + "FROM Users "
                   + "WHERE IsActive = 1 AND (FullName LIKE ? OR Email LIKE ? OR Username LIKE ?) "
                   + "ORDER BY FullName ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error searching users: " + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }

    // Thêm user mới
    public boolean addUser(Users user) {
        String sql = "INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, DepartmentId, LocationId, IsActive, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getRole());
            ps.setInt(6, user.getDepartmentId());
            ps.setInt(7, user.getLocationId());
            ps.setBoolean(8, user.isActive());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error adding user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật toàn bộ thông tin user (dùng cho Admin)
    public boolean updateUser(Users user) {
        String sql = "UPDATE Users SET FullName = ?, Role = ?, DepartmentId = ?, LocationId = ?, IsActive = ? "
                   + "WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getRole());
            ps.setInt(3, user.getDepartmentId());
            ps.setInt(4, user.getLocationId());
            ps.setBoolean(5, user.isActive());
            ps.setInt(6, user.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật thông tin cá nhân từ trang My Profile.
     * Chỉ cho phép user tự sửa: FullName, Email, LocationId.
     * Không động đến Role, IsActive, DepartmentId.
     */
    public boolean updateProfile(int userId, String fullName, String email, int locationId) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, LocationId = ? WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setInt(3, locationId);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating profile: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Xóa mềm user (soft delete)
    public boolean deactivateUser(int userId) {
        String sql = "UPDATE Users SET IsActive = 0, UpdatedAt = GETDATE() WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error deactivating user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Helper: map ResultSet -> Users object
    private Users mapResultSetToUser(ResultSet rs) throws SQLException {
        Users user = new Users();
        user.setId(rs.getInt("Id"));
        user.setUsername(rs.getString("Username"));
        user.setEmail(rs.getString("Email"));
        user.setFullName(rs.getString("FullName"));
        user.setRole(rs.getString("Role"));
        user.setDepartmentId(rs.getInt("DepartmentId"));
        user.setLocationId(rs.getInt("LocationId"));
        user.setIsActive(rs.getBoolean("IsActive"));
        user.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return user;
    }

    public void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}