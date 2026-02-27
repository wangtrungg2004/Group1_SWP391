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
}
