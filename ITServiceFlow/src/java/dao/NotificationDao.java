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
            "  FROM [dbo].[Notifications]";
        
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
               list.add(not);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public boolean addNotification(int UserId, String Message, Integer RelatedTicketId,boolean IsRead)
    {
        String sql = "INSERT INTO [dbo].[Notifications]\n" +
"           ([UserId]\n" +
"           ,[Message]\n" +
"           ,[RelatedTicketId]\n" +
"           ,[IsRead]\n" +
"           ,[CreatedAt])\n" +
"     VALUES\n" +
"           (?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,GETDATE())";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1,UserId);
            stm.setString(2, Message);
            if (RelatedTicketId == null) {
                stm.setNull(3, java.sql.Types.INTEGER);
            } else {
                stm.setInt(3, RelatedTicketId);
            }
            stm.setBoolean(4, IsRead);
            stm.executeUpdate();
            return true;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
    
        public List<Notifications> getNotificationsByUserId(int userId) {
        List<Notifications> list = new ArrayList<>();
        String sql = "SELECT [Id], [UserId], [Message], [RelatedTicketId], [IsRead], [CreatedAt]\n"
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
                list.add(not);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    
    public static void main(String[] args) {
        NotificationDao dao = new NotificationDao();

        int userId = 1;                 // ID user có trong DB
        String message = "Test notification from main";
        Integer relatedTicketId = null;      // Ticket ID (có thể null nếu cho phép)
        boolean isRead = false;

        boolean result = dao.addNotification(
                userId,
                message,
                relatedTicketId,
                isRead
        );

        if (result) {
            System.out.println("✅ Add notification SUCCESS");
        } else {
            System.out.println("❌ Add notification FAILED");
        }
    }
}
