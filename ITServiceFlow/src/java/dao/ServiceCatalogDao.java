/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import model.ServiceCatalog;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author admin
 */
public class ServiceCatalogDao extends DbContext {

    // Lấy tất cả dịch vụ
    public List<ServiceCatalog> getAllServices() {
        List<ServiceCatalog> list = new ArrayList<>();
        if (connection == null) {
            System.err.println("Database connection is null.");
            return list;
        }
        String sql = "SELECT Id, Name, Description, CategoryId, RequiresApproval, EstimatedDeliveryDays, IsActive FROM [dbo].[ServiceCatalog]";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                ServiceCatalog sc = new ServiceCatalog();
                sc.setId(rs.getInt("Id"));
                sc.setName(rs.getString("Name"));
                sc.setDescription(rs.getString("Description"));
                sc.setCategoryId(rs.getInt("CategoryId"));
                sc.setRequiresApproval(rs.getBoolean("RequiresApproval"));
                sc.setEstimatedDeliveryDays(rs.getInt("EstimatedDeliveryDays"));
                sc.setIsActive(rs.getBoolean("IsActive"));
                list.add(sc);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Lấy dịch vụ theo ID
    public ServiceCatalog getServiceById(int id) {
        if (connection == null) return null;
        String sql = "SELECT Id, Name, Description, CategoryId, RequiresApproval, EstimatedDeliveryDays, IsActive FROM [dbo].[ServiceCatalog] WHERE Id = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                ServiceCatalog sc = new ServiceCatalog();
                sc.setId(rs.getInt("Id"));
                sc.setName(rs.getString("Name"));
                sc.setDescription(rs.getString("Description"));
                sc.setCategoryId(rs.getInt("CategoryId"));
                sc.setRequiresApproval(rs.getBoolean("RequiresApproval"));
                sc.setEstimatedDeliveryDays(rs.getInt("EstimatedDeliveryDays"));
                sc.setIsActive(rs.getBoolean("IsActive"));
                return sc;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    // Thêm dịch vụ mới
    public boolean addService(ServiceCatalog sc) {
        if (connection == null) return false;
        String sql = "INSERT INTO [dbo].[ServiceCatalog] (Name, Description, CategoryId, RequiresApproval, EstimatedDeliveryDays, IsActive) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, sc.getName());
            stm.setString(2, sc.getDescription());
            stm.setInt(3, sc.getCategoryId());
            stm.setBoolean(4, sc.isRequiresApproval());
            stm.setInt(5, sc.getEstimatedDeliveryDays());
            stm.setBoolean(6, sc.isIsActive());
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Cập nhật dịch vụ
    public boolean updateService(ServiceCatalog sc) {
        if (connection == null) return false;
        String sql = "UPDATE [dbo].[ServiceCatalog] SET Name=?, Description=?, CategoryId=?, RequiresApproval=?, EstimatedDeliveryDays=?, IsActive=? WHERE Id=?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, sc.getName());
            stm.setString(2, sc.getDescription());
            stm.setInt(3, sc.getCategoryId());
            stm.setBoolean(4, sc.isRequiresApproval());
            stm.setInt(5, sc.getEstimatedDeliveryDays());
            stm.setBoolean(6, sc.isIsActive());
            stm.setInt(7, sc.getId());
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Xóa dịch vụ
    public boolean deleteService(int id) {
        if (connection == null) return false;
        String sql = "DELETE FROM [dbo].[ServiceCatalog] WHERE Id=?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Ẩn/Hiện dịch vụ (toggle IsActive)
    public boolean toggleActive(int id, boolean isActive) {
        if (connection == null) return false;
        String sql = "UPDATE [dbo].[ServiceCatalog] SET IsActive=? WHERE Id=?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setBoolean(1, isActive);
            stm.setInt(2, id);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }
}







