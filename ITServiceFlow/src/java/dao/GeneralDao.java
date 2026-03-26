package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import Utils.DbContext;

public class GeneralDao extends DbContext {

    public List<Map<String, Object>> getCategories() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT Id, Name FROM Categories ORDER BY Name";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("Id", rs.getInt("Id"));
                map.put("Name", rs.getString("Name"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getLocations() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT Id, Name FROM Locations ORDER BY Name";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("Id", rs.getInt("Id"));
                map.put("Name", rs.getString("Name"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    public List<Map<String, Object>> getPriorities() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT Id, Level FROM Priorities ORDER BY Id";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("Id", rs.getInt("Id"));
                map.put("Name", rs.getString("Level"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
}
