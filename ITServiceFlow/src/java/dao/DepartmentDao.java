/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import model.Department;
import Utils.DbContext;

/**
 *
 * @author DELL
 */
public class DepartmentDao extends DbContext {
    
    public List<Department> getAllDepartments() {
        List<Department> list = new ArrayList<>();
        
        if (connection == null) {
            System.err.println("Database connection is null. Cannot get departments.");
            return list;
        }
        
        String sql = "SELECT Id, Name, LocationId, CategoryId, ManagerId, IsActive FROM Departments ORDER BY Id";
        
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Department dept = new Department();
                dept.setId(rs.getInt("Id"));
                dept.setName(rs.getString("Name"));
                
                // Xử lý các cột có thể NULL
                int locId = rs.getInt("LocationId");
                dept.setLocationId(rs.wasNull() ? null : locId);
                
                int catId = rs.getInt("CategoryId");
                dept.setCategoryId(rs.wasNull() ? null : catId);
                
                int mgrId = rs.getInt("ManagerId");
                dept.setManagerId(rs.wasNull() ? null : mgrId);
                
                dept.IsActive(rs.getBoolean("IsActive"));
                list.add(dept);
            }
            rs.close();
            stm.close();
        } catch (SQLException ex) {
            System.err.println("Lỗi khi lấy danh sách departments: " + ex.getMessage());
            ex.printStackTrace();
        }
        return list;
    }
    
    public Department getDepartmentById(int id) {
        if (connection == null) {
            System.err.println("Database connection is null. Cannot get department.");
            return null;
        }
        
        String sql = "SELECT Id, Name, LocationId, CategoryId, ManagerId, IsActive FROM Departments WHERE Id = ?";
        
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Department dept = new Department();
                dept.setId(rs.getInt("Id"));
                dept.setName(rs.getString("Name"));
                
                // Xử lý các cột có thể NULL
                int locId = rs.getInt("LocationId");
                dept.setLocationId(rs.wasNull() ? null : locId);
                
                int catId = rs.getInt("CategoryId");
                dept.setCategoryId(rs.wasNull() ? null : catId);
                
                int mgrId = rs.getInt("ManagerId");
                dept.setManagerId(rs.wasNull() ? null : mgrId);
                
                dept.IsActive(rs.getBoolean("IsActive"));
                rs.close();
                stm.close();
                return dept;
            }
            rs.close();
            stm.close();
        } catch (SQLException ex) {
            System.err.println("Lỗi khi lấy department: " + ex.getMessage());
            ex.printStackTrace();
        }
        return null;
    }
    
    public boolean createDepartment(Department department) {
        if (connection == null) {
            System.err.println("Database connection is null. Cannot create department.");
            return false;
        }
        
        // Kiểm tra tên department đã tồn tại chưa
        try {
            String checkSql = "SELECT COUNT(*) FROM Departments WHERE Name = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkSql);
            checkStmt.setString(1, department.getName());
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);
            rs.close();
            checkStmt.close();
            
            if (count > 0) {
                System.err.println("Department name đã tồn tại: " + department.getName());
                return false;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi kiểm tra department name: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
        
        // Insert department mới
        // LocationId là bắt buộc (NOT NULL), cần có giá trị hợp lệ
        String sql = "INSERT INTO Departments (Name, LocationId, CategoryId, ManagerId, IsActive) VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, department.getName());
            
            // LocationId là bắt buộc - lấy LocationId đầu tiên nếu không có
            Integer locationId = department.getLocationId();
            if (locationId == null || locationId <= 0) {
                // Lấy LocationId đầu tiên từ database
                String locSql = "SELECT TOP 1 Id FROM Locations ORDER BY Id";
                PreparedStatement locStmt = connection.prepareStatement(locSql);
                ResultSet locRs = locStmt.executeQuery();
                if (locRs.next()) {
                    locationId = locRs.getInt("Id");
                }
                locRs.close();
                locStmt.close();
                
                if (locationId == null || locationId <= 0) {
                    System.err.println("Không tìm thấy LocationId hợp lệ. Vui lòng tạo Location trước.");
                    return false;
                }
            }
            ps.setInt(2, locationId);
            
            // Xử lý các cột có thể NULL
            if (department.getCategoryId() != null && department.getCategoryId() > 0) {
                ps.setInt(3, department.getCategoryId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            
            if (department.getManagerId() != null && department.getManagerId() > 0) {
                ps.setInt(4, department.getManagerId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            
            ps.setBoolean(5, department.IsActive());
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Tạo department thành công: " + department.getName());
                return true;
            } else {
                System.err.println("Không có dòng nào được insert vào database.");
                return false;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi SQL khi tạo department: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        }
    }
}
