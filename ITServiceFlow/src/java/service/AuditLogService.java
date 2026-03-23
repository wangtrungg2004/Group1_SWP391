/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;
import dao.ProblemDao;
import java.sql.Date;
import java.util.List;
import model.Problems;
import model.Tickets;
import model.TimeLog;
import model.AuditLog;
import dao.AuditLogsDAO;
/**
 *
 * @author DELL
 */
public class AuditLogService {
    AuditLogsDAO dao = new AuditLogsDAO();
    
    public List<AuditLog> viewActivitiesHistory(String entity, int entityId)
    {
        return dao.getActivitiesHistory(entity, entityId);
    }
    
    public boolean createAuditLog(int userId, String action, String entity, int entityId)
    {
        return dao.createAuditLog(userId, action, entity, entityId);
    }
}
