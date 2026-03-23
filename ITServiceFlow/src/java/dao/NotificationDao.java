package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.Notifications;

public class NotificationDao extends DbContext {

    private volatile Boolean broadcastColumnAvailable;

    private boolean isBroadcastColumnAvailable() {
        Boolean cached = broadcastColumnAvailable;
        if (cached != null) {
            return cached;
        }
        boolean available = hasColumn("Notifications", "IsBroadcast");
        broadcastColumnAvailable = available;
        return available;
    }

    private String selectColumns() {
        if (isBroadcastColumnAvailable()) {
            return "[Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], "
                    + "ISNULL([IsBroadcast], 0) AS [IsBroadcast]";
        }
        return "[Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], "
                + "CAST(0 AS bit) AS [IsBroadcast]";
    }

    private Notifications mapRow(ResultSet rs) throws SQLException {
        Notifications notification = new Notifications();
        notification.setId(rs.getInt("Id"));
        Object userIdObj = rs.getObject("UserId");
        notification.setUserId(userIdObj == null ? null : ((Number) userIdObj).intValue());
        notification.setMessage(rs.getString("Message"));

        Object relatedTicketObj = rs.getObject("RelatedTicketId");
        notification.setRelatedTicketId(relatedTicketObj == null ? 0 : ((Number) relatedTicketObj).intValue());

        notification.setIsRead(rs.getBoolean("IsRead"));
        notification.setCreatedAt(rs.getTimestamp("CreatedAt"));
        notification.setTitle(rs.getString("Title"));
        notification.setType(rs.getString("Type"));
        notification.setIsBroadcast(rs.getBoolean("IsBroadcast"));
        return notification;
    }

    private void bindNullableTicketId(PreparedStatement statement, int index, Integer relatedTicketId) throws SQLException {
        if (relatedTicketId == null) {
            statement.setNull(index, Types.INTEGER);
        } else {
            statement.setInt(index, relatedTicketId);
        }
    }

    public List<Notifications> getAllNotifications() {
        List<Notifications> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String sql = "SELECT " + selectColumns() + " FROM [dbo].[Notifications] ORDER BY [CreatedAt] DESC";
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public boolean addNotification(int userId, String message, Integer relatedTicketId,
            boolean isRead, String title, String type) {
        if (!hasConnection()) {
            return false;
        }

        String sql;
        if (isBroadcastColumnAvailable()) {
            sql = "INSERT INTO [dbo].[Notifications] "
                    + "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast]) "
                    + "VALUES (?, ?, ?, ?, GETDATE(), ?, ?, 0)";
        } else {
            sql = "INSERT INTO [dbo].[Notifications] "
                    + "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type]) "
                    + "VALUES (?, ?, ?, ?, GETDATE(), ?, ?)";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setString(2, message);
            bindNullableTicketId(statement, 3, relatedTicketId);
            statement.setBoolean(4, isRead);
            statement.setString(5, title);
            statement.setString(6, type);
            statement.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public boolean addBroadcastNotification(String message, Integer relatedTicketId, String title, String type) {
        if (!hasConnection()) {
            return false;
        }

        String sql;
        if (isBroadcastColumnAvailable()) {
            sql = "INSERT INTO [dbo].[Notifications] "
                    + "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast]) "
                    + "VALUES (NULL, ?, ?, 0, GETDATE(), ?, ?, 1)";
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, message);
                bindNullableTicketId(statement, 2, relatedTicketId);
                statement.setString(3, title);
                statement.setString(4, type);
                statement.executeUpdate();
                return true;
            } catch (Exception ex) {
                ex.printStackTrace();
                return false;
            }
        }

        sql = "INSERT INTO [dbo].[Notifications] "
                + "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type]) "
                + "VALUES (?, ?, ?, 0, GETDATE(), ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setNull(1, Types.INTEGER);
            statement.setString(2, message);
            bindNullableTicketId(statement, 3, relatedTicketId);
            statement.setString(4, title);
            statement.setString(5, type);
            statement.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public List<Notifications> getNotificationsByUserId(int userId) {
        List<Notifications> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String sql;
        if (isBroadcastColumnAvailable()) {
            sql = "SELECT " + selectColumns() + " FROM [dbo].[Notifications] "
                    + "WHERE [UserId] = ? OR [IsBroadcast] = 1 "
                    + "ORDER BY [CreatedAt] DESC";
        } else {
            sql = "SELECT " + selectColumns() + " FROM [dbo].[Notifications] "
                    + "WHERE [UserId] = ? "
                    + "ORDER BY [CreatedAt] DESC";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public Notifications getNotificationById(int id) {
        if (!hasConnection()) {
            return null;
        }

        String sql = "SELECT " + selectColumns() + " FROM [dbo].[Notifications] WHERE [Id] = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public boolean readNotificationById(int id) {
        if (!hasConnection()) {
            return false;
        }

        String sql = "UPDATE [dbo].[Notifications] SET [IsRead] = 1 WHERE [Id] = ? AND [IsRead] = 0";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public List<Notifications> getNotificationsByUserIdUnread(int userId) {
        List<Notifications> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String sql;
        if (isBroadcastColumnAvailable()) {
            sql = "SELECT " + selectColumns() + " FROM [dbo].[Notifications] "
                    + "WHERE ([UserId] = ? OR [IsBroadcast] = 1) AND [IsRead] = 0 "
                    + "ORDER BY [CreatedAt] DESC";
        } else {
            sql = "SELECT " + selectColumns() + " FROM [dbo].[Notifications] "
                    + "WHERE [UserId] = ? AND [IsRead] = 0 "
                    + "ORDER BY [CreatedAt] DESC";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
}
