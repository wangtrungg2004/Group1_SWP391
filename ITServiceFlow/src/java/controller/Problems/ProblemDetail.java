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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ProblemId = request.getParameter("Id");

        // Kiểm tra null trước khi parse
//        if (ProblemId == null || ProblemId.trim().isEmpty()) {
//            request.setAttribute("error", "Problem ID is required");
//            request.getRequestDispatcher("ProblemDetail.jsp").forward(request, response);
//            return;
//        }
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
            request.setAttribute("error", "Vui lòng đăng nhập với quyền IT Support");
            doGet(request, response);
            return;
        }
        int userId = userIdObj.intValue();

        String action = request.getParameter("action");
        String problemIdStr = request.getParameter("problemId");

        if (problemIdStr == null || problemIdStr.trim().isEmpty()) {
            request.setAttribute("error", "Thiếu problemId");
            doGet(request, response);
            return;
        }

        int problemId;
        try {
            problemId = Integer.parseInt(problemIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "problemId không hợp lệ");
            doGet(request, response);
            return;
        }

        if ("startInvestigation".equals(action)) {
            // 1. Chuyển status
            boolean statusUpdated = problemService.updateAssignStatus(problemId);

            // 2. Bắt đầu timer
            int timeLogId = problemService.startTimer(problemId, userId);

            if (statusUpdated && timeLogId > 0) {
                session.setAttribute("activeTimeLogId_" + problemId, timeLogId);
                request.setAttribute("success", "Đã bắt đầu điều tra và timer (ID: " + timeLogId + ")");
            } else {
                request.setAttribute("error", "Lỗi khi bắt đầu: status=" + statusUpdated + ", timerId=" + timeLogId);
            }
        } else if ("stopTimer".equals(action)) {
            String timeLogIdStr = request.getParameter("timeLogId");
            if (timeLogIdStr == null) {
                request.setAttribute("error", "Thiếu timeLogId");
                doGet(request, response);
                return;
            }

            int timeLogId;
            try {
                timeLogId = Integer.parseInt(timeLogIdStr);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "timeLogId không hợp lệ");
                doGet(request, response);
                return;
            }

            boolean stopped = problemService.stopTimer(timeLogId);
            if (stopped) {
                session.removeAttribute("activeTimeLogId_" + problemId);
                request.setAttribute("success", "Đã dừng timer và ghi nhận thời gian");
            } else {
                request.setAttribute("error", "Không dừng được timer (có thể đã dừng trước đó)");
            }
        } else {
            request.setAttribute("error", "Action không hợp lệ: " + action);
        }

        doGet(request, response);  // reload trang detail
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
