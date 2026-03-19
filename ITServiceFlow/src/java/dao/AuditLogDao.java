/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import model.AuditLog;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author DELL
 */
public class AuditLogDao extends DbContext {

    public boolean insertLog(AuditLog log) {
        String sql = "INSERT INTO AuditLogs (UserId, Action, Screen, DataBefore, DataAfter, CreatedAt, Entity, EntityId) VALUES (?, ?, ?, ?, ?, GETDATE(), ?, ?)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, log.getUserId());
            stm.setString(2, log.getAction());
            stm.setString(3, log.getScreen());
            stm.setString(4, log.getDataBefore());
            stm.setString(5, log.getDataAfter());
            stm.setString(6, log.getEntity());
            if (log.getEntityId() != null) {
                stm.setInt(7, log.getEntityId());
            } else {
                stm.setNull(7, java.sql.Types.INTEGER);
            }
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public List<AuditLog> getLogs(String user, String action, java.sql.Date from, java.sql.Date to, int offset,
            int limit) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT l.Id, l.UserId, u.FullName as UserName, l.Action, l.Screen, l.DataBefore, l.DataAfter, l.CreatedAt, l.Entity, l.EntityId "
                        +
                        "FROM AuditLogs l " +
                        "LEFT JOIN Users u ON l.UserId = u.Id " +
                        "WHERE 1=1 ");

        if (user != null && !user.isEmpty()) {
            sql.append("AND u.FullName LIKE ? ");
        }
        if (action != null && !action.isEmpty()) {
            sql.append("AND l.Action = ? ");
        }
        if (from != null) {
            sql.append("AND l.CreatedAt >= ? ");
        }
        if (to != null) {
            // Include entire end date
            sql.append("AND l.CreatedAt < DATEADD(day, 1, ?) ");
        }

        sql.append("ORDER BY l.CreatedAt DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (user != null && !user.isEmpty()) {
                stm.setString(paramIndex++, "%" + user + "%");
            }
            if (action != null && !action.isEmpty()) {
                stm.setString(paramIndex++, action);
            }
            if (from != null) {
                stm.setDate(paramIndex++, from);
            }
            if (to != null) {
                stm.setDate(paramIndex++, to);
            }
            stm.setInt(paramIndex++, offset);
            stm.setInt(paramIndex++, limit);

            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setId(rs.getInt("Id"));
                log.setUserId(rs.getInt("UserId"));
                log.setUserName(rs.getString("UserName"));
                log.setAction(rs.getString("Action"));
                log.setScreen(rs.getString("Screen"));
                log.setDataBefore(rs.getString("DataBefore"));
                log.setDataAfter(rs.getString("DataAfter"));
                log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                log.setEntity(rs.getString("Entity"));
                log.setEntityId((Integer) rs.getObject("EntityId"));
                list.add(log);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public int getTotalLogs(String user, String action, java.sql.Date from, java.sql.Date to) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM AuditLogs l " +
                        "LEFT JOIN Users u ON l.UserId = u.Id " +
                        "WHERE 1=1 ");

        if (user != null && !user.isEmpty()) {
            sql.append("AND u.FullName LIKE ? ");
        }
        if (action != null && !action.isEmpty()) {
            sql.append("AND l.Action = ? ");
        }
        if (from != null) {
            sql.append("AND l.CreatedAt >= ? ");
        }
        if (to != null) {
            sql.append("AND l.CreatedAt < DATEADD(day, 1, ?) ");
        }

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (user != null && !user.isEmpty()) {
                stm.setString(paramIndex++, "%" + user + "%");
            }
            if (action != null && !action.isEmpty()) {
                stm.setString(paramIndex++, action);
            }
            if (from != null) {
                stm.setDate(paramIndex++, from);
            }
            if (to != null) {
                stm.setDate(paramIndex++, to);
            }
            java.sql.ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return count;
    }
}
