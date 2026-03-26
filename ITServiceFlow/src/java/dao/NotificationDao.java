/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Notifications;
import Utils.DbContext;

/**
 * DAO cho Notifications. Ho tro ca notification gui 1 user va broadcast (gui tat ca).
 */
public class NotificationDao extends DbContext{

    /**
     * Map 1 dong ResultSet thanh object Notifications.
     * UserId co the null (broadcast), co them cot IsBroadcast.
     */
//    private Notifications mapRow(ResultSet rs) throws SQLException {
//        Notifications not = new Notifications();
//        not.setId(rs.getInt("Id"));
//        Object userIdObj = rs.getObject("UserId");
//        not.setUserId(userIdObj == null ? null : ((Number) userIdObj).intValue());
//        not.setMessage(rs.getString("Message"));
//        not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
//        not.setIsRead(rs.getBoolean("IsRead"));
//        not.setCreatedAt(rs.getTimestamp("CreatedAt"));
//        not.setTitle(rs.getString("Title"));
//        not.setType(rs.getString("Type"));
//        not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
//        return not;
//    }

    public List<Notifications> getAllNotifications() {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast] "
                + "FROM [dbo].[Notifications] ORDER BY [CreatedAt] DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                not.setUserId(rs.getInt("UserId"));
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    /** Them notification gui cho 1 user. IsBroadcast = 0. */
    public boolean addNotification(int userId, String message, Integer relatedTicketId,
                               boolean isRead, String title, String type) {
        String sql = "INSERT INTO [dbo].[Notifications] "
                + "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast]) "
                + "VALUES (?, ?, ?, ?, GETDATE(), ?, ?, 0)";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, userId);
            stm.setString(2, message);
            if (relatedTicketId == null) {
                stm.setNull(3, java.sql.Types.INTEGER);
            } else {
                stm.setInt(3, relatedTicketId);
            }
            stm.setBoolean(4, isRead);
            stm.setString(5, title);
            stm.setString(6, type);
            stm.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    /** Them 1 notification gui cho tat ca (broadcast). Chi insert 1 dong, UserId = NULL, IsBroadcast = 1. */
    public boolean addBroadcastNotification(String message, Integer relatedTicketId, String title, String type) {
        String sql = "INSERT INTO [dbo].[Notifications] "
                + "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast]) "
                + "VALUES (NULL, ?, ?, 0, GETDATE(), ?, ?, 1)";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, message);
            if (relatedTicketId == null) {
                stm.setNull(2, java.sql.Types.INTEGER);
            } else {
                stm.setInt(2, relatedTicketId);
            }
            stm.setString(3, title);
            stm.setString(4, type);
            stm.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }
    
    /** Lay danh sach notification cua 1 user: ca notification rieng (UserId = ?) va broadcast (IsBroadcast = 1). */
    public List<Notifications> getNotificationsByUserId(int userId) {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast] "
                + "FROM [dbo].[Notifications] "
                + "WHERE [UserId] = ? OR [IsBroadcast] = 1 "
                + "ORDER BY [CreatedAt] DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                not.setUserId(rs.getInt("UserId"));
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
        
    public Notifications getNotificationById(int id) {
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast] "
                + "FROM [dbo].[Notifications] WHERE [Id] = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                not.setUserId(rs.getInt("UserId"));
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
                return not;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }
        
    public boolean readNotificationById(int id) {
        String sql =
            "UPDATE [dbo].[Notifications] " +
            "SET [IsRead] = 1 " +
            "WHERE [Id] = ? AND [IsRead] = 0";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, id);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }
    /** Lay notification chua doc cua user: rieng (UserId = ?) va broadcast, IsRead = 0. */
    public List<Notifications> getNotificationsByUserIdUnread(int userId) {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast] "
                + "FROM [dbo].[Notifications] "
                + "WHERE ([UserId] = ? OR [IsBroadcast] = 1) AND [IsRead] = 0 "
                + "ORDER BY [CreatedAt] DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                not.setUserId(rs.getInt("UserId"));
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
                    
        /** Giong ProblemDao.searchProblem — tim trong Title / Message / Type. */
    public List<Notifications> searchNotificationsForUser(int userId, String keyword) {
        List<Notifications> list = new ArrayList<>();
        try {
            String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast] "
                    + "FROM [dbo].[Notifications] "
                    + "WHERE ([UserId] = ? OR [IsBroadcast] = 1) "
                    + "AND ([Title] LIKE ? OR [Message] LIKE ? OR [Type] LIKE ?) "
                    + "ORDER BY [CreatedAt] DESC";
            PreparedStatement stm = connection.prepareStatement(sql);
            String searchValue = "%" + keyword + "%";
            stm.setInt(1, userId);
            stm.setString(2, searchValue);
            stm.setString(3, searchValue);
            stm.setString(4, searchValue);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                Object userIdObj = rs.getObject("UserId");
                not.setUserId(userIdObj == null ? null : ((Number) userIdObj).intValue());
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    public List<Notifications> searchAllNotifications(String keyword) {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type], [IsBroadcast] "
                   + "FROM [dbo].[Notifications] "
                   + "WHERE [Title] LIKE ? OR [Message] LIKE ? OR [Type] LIKE ? "
                   + "ORDER BY [CreatedAt] DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            String searchValue = "%" + keyword + "%";
            stm.setString(1, searchValue);
            stm.setString(2, searchValue);
            stm.setString(3, searchValue);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                Object userIdObj = rs.getObject("UserId");
                not.setUserId(userIdObj == null ? null : ((Number) userIdObj).intValue());
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                not.setIsBroadcast(rs.getBoolean("IsBroadcast"));
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
//    public static void main(String[] args) {
//        NotificationDao dao = new NotificationDao(); // nhớ init connection trong constructor
//
//        int testId = 10; // đổi sang Id có thật trong DB
//        Notifications not = dao.getNotificationById(testId);
//
//        if (not != null) {
//            System.out.println("=== Notification Detail ===");
//            System.out.println("Id: " + not.getId());
//            System.out.println("UserId: " + not.getUserId());
//            System.out.println("Title: " + not.getTitle());
//            System.out.println("Message: " + not.getMessage());
//            System.out.println("IsRead: " + not.isIsRead());
//            System.out.println("CreatedAt: " + not.getCreatedAt());
//        } else {
//            System.out.println("❌ Notification not found");
//        }
//    }
    
    public static void main(String[] args) {
        NotificationDao dao = new NotificationDao();

        int testId = 10; // Id chưa đọc
        boolean success = dao.readNotificationById(testId);

        if (success) {
            System.out.println("✅ Notification marked as read");
        } else {
            System.out.println("⚠️ Notification already read or not found");
        }

        // check lại
        Notifications not = dao.getNotificationById(testId);
        System.out.println("IsRead after update: " + not.isIsRead());
    }
//    public static void main(String[] args) {
//        NotificationDao dao = new NotificationDao();
//
//        int userId = 1;                 // ID user có trong DB
//        String message = "Test notification from main";
//        Integer relatedTicketId = null;      // Ticket ID (có thể null nếu cho phép)
//        boolean isRead = false;
//        String title = "add New Problem";
//        String Type = "Problem";
//        boolean result = dao.addNotification(
//                userId,
//                message,
//                relatedTicketId,
//                isRead,
//                title,
//                Type
//        );
//
//        if (result) {
//            System.out.println("✅ Add notification SUCCESS");
//        } else {
//            System.out.println("❌ Add notification FAILED");
//        }
//    }
}
