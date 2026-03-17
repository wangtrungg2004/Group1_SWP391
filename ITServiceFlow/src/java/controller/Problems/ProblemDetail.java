/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Problems;
import model.Tickets;
import model.TimeLog;
import service.AuditLogService;
import service.ProblemService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "ProblemDetail", urlPatterns = {"/ProblemDetail"})
public class ProblemDetail extends HttpServlet {

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
            out.println("<title>Servlet ProblemDetail</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProblemDetail at " + request.getContextPath() + "</h1>");
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
    AuditLogService auditLogService = new AuditLogService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ProblemId = request.getParameter("Id");

        if (ProblemId == null || ProblemId.trim().isEmpty()) {
            String redirectUrl = "ProblemList";
            if (request.getSession(false) != null) {
                String role = (String) request.getSession().getAttribute("role");
                if ("IT Support".equals(role)) {
                    redirectUrl = "ITProblemListController";
                }
            }
            response.sendRedirect(redirectUrl);
            return;
        }
        try {
            int id = Integer.parseInt(ProblemId);

            Problems pro = problemService.getProblemById(id);
            if (pro == null) {
                request.setAttribute("error", "Problem not found with ID: " + id);
                request.getRequestDispatcher("ProblemDetail.jsp").forward(request, response);
                return;
            }

            List<Tickets> relatedTickets = problemService.getRelatedTicket(id);

            // Thêm time tracking
            List<TimeLog> timeLogs = problemService.getTimeLogs(id);
            double totalTime = problemService.getTotalTimeSpent(id);

            request.setAttribute("problem", pro);
            request.setAttribute("relatedTickets", relatedTickets);
            request.setAttribute("timeLogs", timeLogs);
            request.setAttribute("totalTime", totalTime);

            HttpSession sess = request.getSession(false);
            if (sess != null) {
                Object flash = sess.getAttribute("problemDetailFlash");
                if (flash != null && flash.toString().startsWith("success:")) {
                    request.setAttribute("success", flash.toString().substring(8));
                    sess.removeAttribute("problemDetailFlash");
                } else if (flash != null && flash.toString().startsWith("error:")) {
                    request.setAttribute("error", flash.toString().substring(6));
                    sess.removeAttribute("problemDetailFlash");
                }
            }

            request.getRequestDispatcher("ProblemDetail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid Problem ID format: " + ProblemId);
            request.getRequestDispatcher("ProblemDetail.jsp").forward(request, response);
        }
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
        HttpSession session = request.getSession(false); // false để tránh tạo session mới
        Integer userIdObj = (Integer) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (userIdObj == null || !"IT Support".equals(role)) {
            if (session != null) session.setAttribute("problemDetailFlash", "error:Vui lòng đăng nhập với quyền IT Support");
            response.sendRedirect("IT Support".equals(role) ? "ITProblemListController" : "ProblemList");
            return;
        }
        int userId = userIdObj.intValue();

        String action = request.getParameter("action");
        String problemIdStr = request.getParameter("problemId");

        if (problemIdStr == null || problemIdStr.trim().isEmpty()) {
            session.setAttribute("problemDetailFlash", "error:Thiếu problemId");
            response.sendRedirect("ITProblemListController");
            return;
        }

        int problemId;
        try {
            problemId = Integer.parseInt(problemIdStr);
        } catch (NumberFormatException e) {
            session.setAttribute("problemDetailFlash", "error:problemId không hợp lệ");
            response.sendRedirect("ITProblemListController");
            return;
        }

        if ("startInvestigation".equals(action)) {
            boolean statusUpdated = problemService.updateAssignStatus(problemId);
            int timeLogId = problemService.startTimer(problemId, userId);
            auditLogService.createAuditLog(userId, "START_INVESTIGATION", "Problem", problemId);
//            if (statusUpdated && timeLogId > 0) {
////                auditLogService.createAuditLog(userId, "START_INVESTIGATION", "Problem", problemId);
//                
//                session.setAttribute("activeTimeLogId_" + problemId, timeLogId);
//                session.setAttribute("problemDetailFlash", "success:Đã bắt đầu điều tra và timer");
//            } else {
//                session.setAttribute("problemDetailFlash", "error:Lỗi khi bắt đầu điều tra");
//            }
        } else if ("stopTimer".equals(action)) {
            String timeLogIdStr = request.getParameter("timeLogId");
            if (timeLogIdStr == null) {
                session.setAttribute("problemDetailFlash", "error:Thiếu timeLogId");
                response.sendRedirect("ProblemDetail?Id=" + problemId);
                return;
            }

            int timeLogId;
            try {
                timeLogId = Integer.parseInt(timeLogIdStr);
            } catch (NumberFormatException e) {
                session.setAttribute("problemDetailFlash", "error:timeLogId không hợp lệ");
                response.sendRedirect("ProblemDetail?Id=" + problemId);
                return;
            }

            boolean stopped = problemService.stopTimer(timeLogId);
            if (stopped) {
                session.removeAttribute("activeTimeLogId_" + problemId);
                session.setAttribute("problemDetailFlash", "success:Đã dừng timer và ghi nhận thời gian");
            } else {
                session.setAttribute("problemDetailFlash", "error:Không dừng được timer");
            }
        } else if ("markResolved".equals(action)) {
            // Lấy timeLogId từ param hoặc từ session
            String timeLogIdStr = request.getParameter("timeLogId");
            Integer timeLogId = null;

            if (timeLogIdStr != null && !timeLogIdStr.trim().isEmpty()) {
                try {
                    timeLogId = Integer.parseInt(timeLogIdStr);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "timeLogId không hợp lệ");
                    doGet(request, response);
                    return;
                }
            } else {
                Object sessionLogId = session.getAttribute("activeTimeLogId_" + problemId);
                if (sessionLogId instanceof Integer) {
                    timeLogId = (Integer) sessionLogId;
                }
            }

            if (timeLogId == null) {
                session.setAttribute("problemDetailFlash", "error:Không tìm thấy phiên timer đang chạy");
                response.sendRedirect("ProblemDetail?Id=" + problemId);
                return;
            }

            boolean stopped = problemService.stopTimer(timeLogId);
            boolean statusUpdated = problemService.updateStatusProblem(problemId, "RESOLVED");

            if (stopped && statusUpdated) {
                session.removeAttribute("activeTimeLogId_" + problemId);
                session.setAttribute("problemDetailFlash", "success:Đã dừng timer và đánh dấu RESOLVED");
            } else {
                session.setAttribute("problemDetailFlash", "error:Lỗi khi đánh dấu resolved");
            }
        } else {
            session.setAttribute("problemDetailFlash", "error:Action không hợp lệ");
        }

        response.sendRedirect("ProblemDetail?Id=" + problemId);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
