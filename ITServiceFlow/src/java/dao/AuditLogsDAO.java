package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.AuditLog;

public class AuditLogsDAO extends DbContext {

    private static final String INSERT_AUDIT =
        "INSERT INTO AuditLogs (UserId, Action, Entity, EntityId, CreatedAt) " +
        "VALUES (?, ?, ?, ?, GETDATE())";

    private static final String SELECT_BY_ENTITY =
        "SELECT Id, UserId, Action, Entity, EntityId, CreatedAt " +
        "FROM AuditLogs " +
        "WHERE Entity = ? AND EntityId = ? " +
        "ORDER BY CreatedAt DESC";

    private static final String SELECT_RECENT_BY_USER =
        "SELECT TOP 50 Id, UserId, Action, Entity, EntityId, CreatedAt " +
        "FROM AuditLogs " +
        "WHERE UserId = ? " +
        "ORDER BY CreatedAt DESC";

    private static final String SELECT_ALL_RECENT =
        "SELECT TOP 100 Id, UserId, Action, Entity, EntityId, CreatedAt " +
        "FROM AuditLogs " +
        "ORDER BY CreatedAt DESC";

    public boolean logAction(int userId, String action, String entity, int entityId) {
        if (!isConnected()) {
            return false;
        }

        try (PreparedStatement ps = connection.prepareStatement(INSERT_AUDIT)) {
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, entity);
            ps.setInt(4, entityId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("AuditLogsDAO - logAction failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<AuditLog> getByEntity(String entity, int entityId) {
        List<AuditLog> logs = new ArrayList<>();
        if (!isConnected()) {
            return logs;
        }

        try (PreparedStatement ps = connection.prepareStatement(SELECT_BY_ENTITY)) {
            ps.setString(1, entity);
            ps.setInt(2, entityId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapRowToAuditLog(rs);
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            System.err.println("AuditLogsDAO - getByEntity failed: " + e.getMessage());
            e.printStackTrace();
        }
        return logs;
    }

    public List<AuditLog> getRecentByUser(int userId) {
        List<AuditLog> logs = new ArrayList<>();
        if (!isConnected()) {
            return logs;
        }

        try (PreparedStatement ps = connection.prepareStatement(SELECT_RECENT_BY_USER)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapRowToAuditLog(rs);
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            System.err.println("AuditLogsDAO - getRecentByUser failed: " + e.getMessage());
            e.printStackTrace();
        }
        return logs;
    }

    public List<AuditLog> getRecentSystemLogs() {
        List<AuditLog> logs = new ArrayList<>();
        if (!isConnected()) {
            return logs;
        }

        try (PreparedStatement ps = connection.prepareStatement(SELECT_ALL_RECENT);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                AuditLog log = mapRowToAuditLog(rs);
                logs.add(log);
            }
        } catch (SQLException e) {
            System.err.println("AuditLogsDAO - getRecentSystemLogs failed: " + e.getMessage());
            e.printStackTrace();
        }
        return logs;
    }

    private AuditLog mapRowToAuditLog(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("Id"));
        log.setUserId(rs.getInt("UserId"));
        log.setAction(rs.getString("Action"));
        log.setEntity(rs.getString("Entity"));
        log.setEntityId(rs.getInt("EntityId"));
        log.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return log;
    }

    public void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("Failed to close AuditLogsDAO connection: " + e.getMessage());
            }
        }
    }
    
    
    
    public List<AuditLog> getActivitiesHistory(String entity, int entityId)
    {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT a.Id, a.UserId, a.Action, a.Entity, a.EntityId, a.CreatedAt, u.FullName AS UserName " +
                    "FROM AuditLogs a " +
                    "LEFT JOIN Users u ON a.UserId = u.Id " +
                    "WHERE a.Entity = ? AND a.EntityId = ? " +
                    "ORDER BY a.CreatedAt DESC";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, entity);
            stm.setInt(2, entityId);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                AuditLog log = new AuditLog();
                log.setId(rs.getInt("Id"));
                log.setUserId(rs.getInt("UserId"));
                log.setAction(rs.getString("Action"));
                log.setEntity(rs.getString("Entity"));
                log.setEntityId(rs.getInt("EntityId"));
                log.setCreatedAt(rs.getTimestamp("CreatedAt")); 
                log.setUserName(rs.getString("UserName"));
                list.add(log);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public boolean createAuditLog(int userId, String action, String entity, int entityId)
    {
        String sql = "INSERT INTO AuditLogs (UserId, Action, Entity, EntityId, CreatedAt) " +
        "VALUES (?, ?, ?, ?, GETDATE())";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            stm.setString(2, action);
            stm.setString(3, entity);
            stm.setInt(4, entityId);
            stm.executeUpdate();
            return true;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
}