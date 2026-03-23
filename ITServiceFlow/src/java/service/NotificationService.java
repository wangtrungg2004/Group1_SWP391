/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;
import dao.ProblemDao;
import dao.NotificationDao;
import java.sql.Date;
import java.util.List;
import model.Notifications;
import model.Problems;
import model.Tickets;
/**
 *
 * @author DELL
 */
public class NotificationService {
    NotificationDao dao = new NotificationDao();
    public List<Notifications> getAllNotification()
    {
        return dao.getAllNotifications();
    }
    public List<Notifications> getAllUserNotification(int id)
    {
        return dao.getNotificationsByUserId(id);
    }
    public Notifications getNotificationsById(int id)
    {
        return dao.getNotificationById(id);
    }
    public boolean readNotification(int id)
    {
        return dao.readNotificationById(id);
    }
    public List<Notifications> getAllNotificationsByUserId(int userId)
    {
        return dao.getNotificationsByUserId(userId);
    }
    public List<Notifications> getNotificationsByUserIdUnread(int id){
        return dao.getNotificationsByUserIdUnread(id);
    }
    
    public boolean createNotification(int userId, String message, Integer relatedTicketId,
                               boolean isRead, String title, String type)
    {
        return dao.addNotification(userId, message, relatedTicketId, isRead, title, type);
    }
    
    /** Gui notification cho nhieu user (moi user 1 dong). Dung khi chon "One user" nhap 1 id. */
    public int addNotificationToUsers(List<Integer> userIds, String message,
                                  Integer relatedTicketId, String title, String type) {
        int count = 0;
        for (Integer userId : userIds) {
            if (userId != null && dao.addNotification(userId, message, relatedTicketId, false, title, type)) {
                count++;
            }
        }
        return count;
    }

    /** Gui 1 notification cho tat ca (broadcast). Chi tao 1 dong trong DB. */
    public boolean addBroadcastNotification(String message, Integer relatedTicketId, String title, String type) {
        return dao.addBroadcastNotification(message, relatedTicketId, title, type);
    }
    
        /** Giong ProblemService.searchProblem: null/blank -> full list trong pham vi user + broadcast. */
    public List<Notifications> searchNotificationsForUser(int userId, String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return dao.getNotificationsByUserId(userId);
        }
        return dao.searchNotificationsForUser(userId, keyword.trim());
    }
}
