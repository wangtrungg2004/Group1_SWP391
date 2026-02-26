/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Notifications;
import java.time.Year;
import Utils.DbContext;

/**
 *
 * @author DELL
 */
public class NotificationDao extends DbContext{
    
    public List<Notifications> getAllNotifications()
    {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id]\n" +
            "      ,[UserId]\n" +
            "      ,[Message]\n" +
            "      ,[RelatedTicketId]\n" +
            "      ,[IsRead]\n" +
            "      ,[CreatedAt]\n" +
            "      ,[Title]\n" +
            "      ,[Type]\n" +
            "  FROM [dbo].[Notifications]\n" +
            "  ORDER BY [CreatedAt] DESC";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
               Notifications not = new Notifications();
               not.setId(rs.getInt("Id"));
               not.setUserId(rs.getInt("UserId"));
               not.setMessage(rs.getString("Message"));
               not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
               not.setIsRead(rs.getBoolean("IsRead"));
               not.setCreatedAt(rs.getTimestamp("CreatedAt"));
               not.setTitle(rs.getString("Title"));
               not.setType(rs.getString("Type"));
               list.add(not);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public boolean addNotification(int userId, String message, Integer relatedTicketId,
                               boolean isRead, String title, String type) {

        String sql = "INSERT INTO [dbo].[Notifications] " +
                     "([UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type]) " +
                     "VALUES (?, ?, ?, ?, GETDATE(), ?, ?)";

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
    
        public List<Notifications> getNotificationsByUserId(int userId) {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt], [Title], [Type]\n"
                + "  FROM [dbo].[Notifications]\n"
                + "  WHERE [UserId] = ?\n"
                + "  ORDER BY [CreatedAt] DESC";
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
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
        
    public Notifications getNotificationById(int id)
    {
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], " +
            "       [CreatedAt], [Title], [Type] " +
            "FROM [dbo].[Notifications] " +
            "WHERE [Id] = ?";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id); 
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                Notifications not = new Notifications();
                not.setId(rs.getInt("Id"));
                not.setUserId(rs.getInt("UserId"));
                not.setMessage(rs.getString("Message"));
                not.setRelatedTicketId(rs.getInt("RelatedTicketId"));
                not.setIsRead(rs.getBoolean("IsRead"));
                not.setCreatedAt(rs.getTimestamp("CreatedAt"));
                not.setTitle(rs.getString("Title"));
                not.setType(rs.getString("Type"));
                return not;
            }
        }
        catch(Exception ex)
        {
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
