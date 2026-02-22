package dao;

import model.Location;
import Utils.DbContext;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng Locations.
 */
public class LocationDao extends DbContext {

    public List<Location> getAllLocations() {
        List<Location> list = new ArrayList<>();
        if (connection == null) {
            System.err.println("Database connection is null. Cannot get locations.");
            return list;
        }
        String sql = "SELECT Id, Name, IsActive FROM Locations ORDER BY Name";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                Location loc = new Location();
                loc.setId(rs.getInt("Id"));
                loc.setName(rs.getString("Name"));
                loc.setActive(rs.getBoolean("IsActive"));
                list.add(loc);
            }
        } catch (SQLException ex) {
            System.err.println("Lỗi khi lấy danh sách locations: " + ex.getMessage());
            ex.printStackTrace();
        }
        return list;
    }

    public Location getById(int id) {
        if (connection == null) return null;
        String sql = "SELECT Id, Name, IsActive FROM Locations WHERE Id = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Location loc = new Location();
                loc.setId(rs.getInt("Id"));
                loc.setName(rs.getString("Name"));
                loc.setActive(rs.getBoolean("IsActive"));
                return loc;
            }
        } catch (SQLException ex) {
            System.err.println("Lỗi khi lấy location: " + ex.getMessage());
        }
        return null;
    }
}
