/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import dao.NotificationDao;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import model.Notifications;
import model.Problems;
import service.AuditLogService;
import service.ProblemService;
import service.NotificationService;
/**
 *
 * @author DELL
 */
@WebServlet(name = "ProblemList", urlPatterns = {"/ProblemList"})
public class ProblemList extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProblemList</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProblemList at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    ProblemService problemService = new ProblemService();
    NotificationService notificationService = new NotificationService();
    NotificationDao notificationDao = new NotificationDao();
    AuditLogService auditLogService = new AuditLogService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");

//            if (role == null || userId == null) {
//                response.sendRedirect("Login.jsp");
//                return;
//            }
//            if (!"Manager".equals(role) && !"Admin".equals(role) && !"IT Support".equals(role)) {
//                response.sendRedirect("UserDashboard.jsp"); // hoặc Login.jsp / trang 403
//                return;
//            }

        List<Notifications> notifications = new ArrayList<>();
        if (role != null && userId != null) {
            if ("Admin".equals(role) || "Manager".equals(role)) {
                notifications = notificationService.getAllNotification();
            } else {
                notifications = notificationService.getAllUserNotification(userId);
            }
        }

        int page = 1;
        int pageSize = 10;
        String pageParam = request.getParameter("page");

        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }

        String status = request.getParameter("filterStatus");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        boolean hasStatus = status != null && !status.trim().isEmpty();
        boolean hasFrom = fromDate != null && !fromDate.trim().isEmpty();
        boolean hasTo = toDate != null && !toDate.trim().isEmpty();
        boolean usedFilter = false;

        List<Problems> problems = new ArrayList<>();
        int totalRecords;
        int totalPages;

        if (!keyword.isEmpty()) {
            problems = problemService.searchProblem(keyword);
            usedFilter = true;
        } else if (hasStatus && hasFrom && hasTo) {
            try {
                java.sql.Date fromStr = java.sql.Date.valueOf(fromDate);
                java.sql.Date toStr   = java.sql.Date.valueOf(toDate);

                List<Problems> byStatus = problemService.filterByStatus(status.trim());
                List<Problems> filtered = new ArrayList<>();

                for (Problems p : byStatus) {
                    if (p.getCreatedAt() == null) continue;

                    long createdTime = p.getCreatedAt().getTime();
                    long fromTime = fromStr.getTime();
                    long toTime = toStr.getTime();

                    if (createdTime >= fromTime && createdTime <= toTime) {
                        filtered.add(p);
                    }
                }

                problems = filtered;
                usedFilter = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if (hasStatus) {
            problems = problemService.filterByStatus(status.trim());
            usedFilter = true;
        } else if (hasFrom && hasTo) {
            try {
                java.sql.Date fromStr = java.sql.Date.valueOf(fromDate);
                java.sql.Date toStr   = java.sql.Date.valueOf(toDate);
                problems = problemService.filterByDateRange(fromStr, toStr);
                usedFilter = true;
            } catch (Exception e) {
            }
        }

        if (usedFilter) {
            totalRecords = problems.size();
            totalPages = 1;
            page = 1;
        } else {
            String excludeStatus = "PENDING";
            totalRecords = problemService.getTotalProblemExcludingStatus(excludeStatus);
            totalPages = (totalRecords + pageSize - 1) / pageSize;
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;
            problems = problemService.getProblemsWithPagesExcludingStatus(page, pageSize, excludeStatus);
        }

        request.setAttribute("problem", problems);
        request.setAttribute("notifications", notifications);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("filterKeyword", keyword);
        
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterFromDate", fromDate);
        request.setAttribute("filterToDate", toDate);
        
        request.getRequestDispatcher("ProblemList.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
       String ProblemId = request.getParameter("Id");
        
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        try {
            int id = Integer.parseInt(ProblemId);
            
            // Kiểm tra user có tồn tại không
            Problems pro = problemService.getProblemById(id);
            if (pro == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Problem not found");
                return;
            }
            
//            // --- Điều kiện 1: Chỉ Manager (hoặc IT Support) mới được xóa ---
//            String role = (String) request.getSession().getAttribute("role");
//            if (role == null || !("Manager".equals(role) || "IT Support".equals(role))) {
//                response.sendRedirect("ProblemList?error=no_permission");
//                return;
//            }
//            // --- Điều kiện 2: Chỉ xóa khi status = NEW (hoặc thêm ASSIGNED nếu cho phép) ---
//            String status = pro.getStatus();
//            if (status == null || !("NEW".equals(status) || "ASSIGNED".equals(status))) {
//                response.sendRedirect("ProblemList?error=cannot_delete_status&id=" + id);
//                return;
//            }
            String problemTitle = pro.getTitle();
            int assignedTo = pro.getAssignedTo();
            int createdBy = pro.getCreatedBy();

            
            // Thực hiện delete
            boolean deleted = problemService.deleteProblem(id);
            if (!deleted) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to delete user");
                return;
            }
            
//            String msg = "Problem has been deleted: " + problemTitle;
//            String notifTitle = "Problem deleted: " + problemTitle;
//            if (assignedTo > 0) {
//                notificationDao.addNotification(assignedTo, msg, null, false, notifTitle, "Problem");
//            }
//            if (createdBy > 0 && createdBy != assignedTo) {
//                notificationDao.addNotification(createdBy, msg, null, false, notifTitle, "Problem");
//            }
            
            // Redirect về danh sách users sau khi delete thành công
            auditLogService.createAuditLog(userId, "DELETE", "Problem", id);
            response.sendRedirect("ProblemList");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ProblemId format");
        } catch (NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ProblemId parameter is missing");
        }
    }
}