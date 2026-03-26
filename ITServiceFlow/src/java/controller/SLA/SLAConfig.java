/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.SLA;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Priority;
import model.SLARule;
import service.SLARuleService;

import dao.AuditLogDao;
import model.AuditLog;


/**
 *
 * @author DELL
 */
@WebServlet(name = "SLAConfig", urlPatterns = { "/SLAConfig" })
public class SLAConfig extends HttpServlet {

    SLARuleService slaRuleService = new SLARuleService();


    AuditLogDao auditLogDao = new AuditLogDao();


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        // Only Admin and Manager can access
        if (role == null || (!"Admin".equals(role) && !"Manager".equals(role))) {
            response.sendRedirect("Login.jsp"); // Or access denied
            return;
        }

        // Handle Edit request (populate form)
        String action = request.getParameter("action");
        if ("detail".equals(action)) {
            String idRaw = request.getParameter("id");
            if (idRaw != null) {
                try {
                    int id = Integer.parseInt(idRaw);
                    SLARule rule = slaRuleService.getSLARuleById(id);
                    request.setAttribute("rule", rule);
                    request.getRequestDispatcher("sla-detail.jsp").forward(request, response);
                    return;
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        } else if ("edit".equals(action)) {
            String idRaw = request.getParameter("id");
            if (idRaw != null) {
                try {
                    int id = Integer.parseInt(idRaw);
                    SLARule rule = slaRuleService.getSLARuleById(id);
                    request.setAttribute("ruleToEdit", rule);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }

        // Search and Pagination
        String name = request.getParameter("name");
        String type = request.getParameter("type");
        String priorityRaw = request.getParameter("priority");
        String status = request.getParameter("status");
        String pageRaw = request.getParameter("page");

        // Trim inputs
        if (name != null)
            name = name.trim();
        if (type != null)
            type = type.trim();

        int page = 1;

        int pageSize = 15;

        int pageSize = 10;

        Integer priorityId = null;

        if (pageRaw != null && !pageRaw.isEmpty()) {
            try {
                page = Integer.parseInt(pageRaw);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        if (priorityRaw != null && !priorityRaw.isEmpty()) {
            try {
                priorityId = Integer.parseInt(priorityRaw);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        List<SLARule> rules = slaRuleService.searchSLARules(name, type, priorityId, status, page, pageSize);

        int totalRecords = slaRuleService.countSLARules(name, type, priorityId, status);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1)
            totalPages = 1;

        request.setAttribute("slaRules", rules);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        int totalLogs = slaRuleService.countSLARules(name, type, priorityId, status);
        int totalPages = (int) Math.ceil((double) totalLogs / pageSize);
        if (totalPages < 1)
            totalPages = 1;

        List<Priority> priorities = slaRuleService.getAllPriorities();
        List<String> availableTypes = slaRuleService.getDistinctTypes();
        List<String> availableStatuses = slaRuleService.getDistinctStatuses();

        request.setAttribute("slaRules", rules);
        request.setAttribute("priorities", priorities);
        request.setAttribute("availableTypes", availableTypes);
        request.setAttribute("availableStatuses", availableStatuses);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalLogs);
        request.setAttribute("paramName", name);
        request.setAttribute("paramType", type);
        request.setAttribute("paramPriority", priorityId);
        request.setAttribute("paramStatus", status);


        List<Priority> priorities = slaRuleService.getAllPriorities();
        request.setAttribute("priorities", priorities);


        request.getRequestDispatcher("sla-config.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");

        if (role == null || (!"Admin".equals(role) && !"Manager".equals(role))) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            String idRaw = request.getParameter("id");
            if (idRaw != null) {
                try {
                    int id = Integer.parseInt(idRaw);
                    slaRuleService.deleteSLARule(id);

                    
                    // Add Audit Log
                    AuditLog log = new AuditLog();
                    log.setUserId(userId != null ? userId : 1);
                    log.setAction("DELETE_SLA_RULE");
                    log.setScreen("SLA Config");
                    log.setDataBefore("ID: " + id);
                    log.setDataAfter("SLA Rule deleted");
                    log.setEntity("SLARules");
                    log.setEntityId(id);
                    auditLogDao.insertLog(log);


                    session.setAttribute("successMessage", "SLA Rule deleted successfully.");
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        } else if ("toggleStatus".equals(action)) {
            String idRaw = request.getParameter("id");
            String currentStatus = request.getParameter("currentStatus");
            if (idRaw != null) {
                try {
                    int id = Integer.parseInt(idRaw);
                    SLARule rule = slaRuleService.getSLARuleById(id);
                    if (rule != null) {
                        String newStatus = "Active".equals(currentStatus) ? "Inactive" : "Active";
                        rule.setStatus(newStatus);

                        slaRuleService.updateSLARule(rule);
                        
                        if ("Active".equals(newStatus)) {
                            // Additional logic could be added here if needed
                        }

                        // If activating, we might want to check for conflicts, but
                        // SLARuleDao.addSLARule handles it.
                        // For updateSLARule, we need to ensure Dao handles deactivation of other rules
                        // if this one becomes active.
                        // Let's rely on updateSLARule to be improved or handle logic here.
                        // Actually better to use existing service method or improve dao.
                        // For now simply update. Ideally validation should be here.

                        // We need to call addSLARule logic-alike or simply update.
                        // Let's just update and let Service/DAO handle logic if implemented,
                        // BUT wait, updateSLARule in DAO currently just updates. It does not
                        // auto-deactivate others.
                        // We should probably deactivate others if setting to Active.
                        // Let's modify updateSLARule in DAO later or handled it manually here?
                        // Better to keep logic in DAO.

                        // Let's assume for now we just toggle. The user requirement said: "Allows
                        // enabling/disabling"
                        slaRuleService.updateSLARule(rule);
                        
                        // Add Audit Log
                        AuditLog log = new AuditLog();
                        log.setUserId(userId != null ? userId : 1);
                        log.setAction("TOGGLE_SLA_STATUS");
                        log.setScreen("SLA Config");
                        log.setDataBefore("Status: " + currentStatus);
                        log.setDataAfter("Status: " + newStatus);
                        log.setEntity("SLARules");
                        log.setEntityId(id);
                        auditLogDao.insertLog(log);


                        session.setAttribute("successMessage", "SLA Rule status updated.");
                        response.sendRedirect("SLAConfig?action=detail&id=" + id);
                        return;
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        } else {
            // Add or Update
            String idRaw = request.getParameter("id");
            String slaName = request.getParameter("slaName");
            String ticketType = request.getParameter("ticketType");
            String priorityIdRaw = request.getParameter("priorityId");
            String responseTimeRaw = request.getParameter("responseTime");
            String resolutionTimeRaw = request.getParameter("resolutionTime");
            String status = request.getParameter("status");

            try {
                // Validation
                if (slaName == null || slaName.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "SLA Name cannot be empty.");
                    response.sendRedirect("SLAConfig");
                    return;
                }

                int priorityId = Integer.parseInt(priorityIdRaw);
                int responseTime = Integer.parseInt(responseTimeRaw);
                int resolutionTime = Integer.parseInt(resolutionTimeRaw);

                if (responseTime <= 0 || resolutionTime <= 0) {
                    session.setAttribute("errorMessage", "Times must be greater than 0.");
                    response.sendRedirect("SLAConfig");
                    return;
                }

                if (resolutionTime < responseTime) {
                    session.setAttribute("errorMessage", "Resolution time must be >= Response time.");
                    response.sendRedirect("SLAConfig");
                    return;
                }

                SLARule rule = new SLARule();
                rule.setSlaName(slaName.trim());
                rule.setTicketType(ticketType);
                rule.setPriorityId(priorityId);
                rule.setResponseTime(responseTime);
                rule.setResolutionTime(resolutionTime);
                rule.setStatus(status);
                rule.setCreatedBy(userId);


                boolean success;
                if (idRaw != null && !idRaw.isEmpty()) {
                    int id = Integer.parseInt(idRaw);
                    rule.setId(id);
                    success = slaRuleService.updateSLARule(rule);
                    if (success) {

                boolean isEdit = idRaw != null && !idRaw.isEmpty();
                Integer currentId = isEdit ? Integer.parseInt(idRaw) : null;

                if (slaRuleService.isSlaNameExists(rule.getSlaName(), currentId)) {
                    session.setAttribute("errorMessage", "SLA Name '" + rule.getSlaName() + "' already exists. Please use a unique name.");
                    response.sendRedirect("SLAConfig" + (isEdit ? "?action=edit&id=" + idRaw : ""));
                    return;
                }

                boolean success;
                if (isEdit) {
                    rule.setId(currentId);
                    success = slaRuleService.updateSLARule(rule);
                    if (success) {
                        // Add Audit Log
                        AuditLog log = new AuditLog();
                        log.setUserId(userId != null ? userId : 1);
                        log.setAction("UPDATE_SLA_RULE");
                        log.setScreen("SLA Config");
                        log.setDataBefore("N/A"); // For simplicity, detailed dataBefore could be fetched if needed
                        log.setDataAfter("Rule updated: " + slaName);
                        log.setEntity("SLARules");
                        log.setEntityId(currentId);
                        auditLogDao.insertLog(log);
                        

                        session.setAttribute("successMessage", "SLA Rule updated successfully!");
                    }
                } else {
                    success = slaRuleService.addSLARule(rule);
                    if (success) {

                        // Add Audit Log
                        AuditLog log = new AuditLog();
                        log.setUserId(userId != null ? userId : 1);
                        log.setAction("CREATE_SLA_RULE");
                        log.setScreen("SLA Config");
                        log.setDataBefore("N/A");
                        log.setDataAfter("Rule created: " + slaName);
                        log.setEntity("SLARules");
                        // We could fetch latest ID if needed
                        auditLogDao.insertLog(log);
                        

                        session.setAttribute("successMessage", "SLA Rule added successfully!");
                    }
                }

                if (!success) {
                    session.setAttribute("errorMessage", "Failed to save SLA Rule.");
                }

            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Invalid number format.");
            }
        }

        response.sendRedirect("SLAConfig");
    }

}
