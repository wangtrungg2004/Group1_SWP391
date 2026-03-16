package controller.ticket.user;

import dao.CsatSurveyDAO;
import dao.TicketDAO;
import model.CsatSurvey;
import model.Tickets;
import model.Users;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý CSAT Survey (US20)
 *
 * GET  /CsatSurvey?ticketId=X  → Hiển thị trang survey (hoặc kết quả đã submit)
 * POST /CsatSurvey             → Lưu survey
 *
 * Điều kiện hợp lệ:
 *   - Đã đăng nhập, role = 'User'  (đúng với Login.java: case "User" → UserDashboard)
 *   - Ticket tồn tại, Tickets.CreatedBy = currentUser.getId()
 *   - Tickets.Status = 'Closed'
 *   - Chưa submit survey (UNIQUE constraint TicketId + UserId)
 */
@WebServlet(name = "CsatSurvey", urlPatterns = {"/CsatSurvey"})
public class CsatSurveyController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        // Role đúng là "User" — khớp với Login.java case "User": redirect UserDashboard
        if (!"User".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String ticketIdStr = request.getParameter("ticketId");
        if (ticketIdStr == null || ticketIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        TicketDAO ticketDao = new TicketDAO();
        Tickets ticket = ticketDao.getTicketById(ticketId);

        // Kiểm tra ticket thuộc về user (Tickets.CreatedBy = Users.Id)
        if (ticket == null || ticket.getCreatedBy() != currentUser.getId()) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        // Chỉ survey được khi Tickets.Status = 'Closed'
        if (!"Closed".equals(ticket.getStatus())) {
            request.setAttribute("errorMsg", "Survey chỉ khả dụng sau khi ticket được đóng.");
            request.setAttribute("ticket", ticket);
            request.getRequestDispatcher("/ticket/csat_survey.jsp").forward(request, response);
            return;
        }

        request.setAttribute("ticket", ticket);

        CsatSurveyDAO csatDao = new CsatSurveyDAO();
        if (csatDao.hasUserSubmitted(ticketId, currentUser.getId())) {
            request.setAttribute("existingSurvey", csatDao.getSurveyByTicket(ticketId));
        }

        request.getRequestDispatcher("/ticket/csat_survey.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null || !"User".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String ticketIdStr = request.getParameter("ticketId");
        String ratingStr   = request.getParameter("rating");
        String comment     = request.getParameter("comment");

        if (ticketIdStr == null || ratingStr == null) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        int ticketId, rating;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
            rating   = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        // Validate rating 1–5 (khớp CHECK constraint DB)
        if (rating < 1 || rating > 5) {
            response.sendRedirect(request.getContextPath()
                    + "/CsatSurvey?ticketId=" + ticketId + "&error=invalid_rating");
            return;
        }

        TicketDAO ticketDao = new TicketDAO();
        Tickets ticket = ticketDao.getTicketById(ticketId);

        if (ticket == null
                || ticket.getCreatedBy() != currentUser.getId()
                || !"Closed".equals(ticket.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        CsatSurveyDAO csatDao = new CsatSurveyDAO();

        // Chặn submit lần 2
        if (csatDao.hasUserSubmitted(ticketId, currentUser.getId())) {
            response.sendRedirect(request.getContextPath()
                    + "/CsatSurvey?ticketId=" + ticketId);
            return;
        }

        CsatSurvey survey = new CsatSurvey(ticketId, currentUser.getId(), rating, comment);
        boolean saved = csatDao.submitSurvey(survey);

        if (saved) {
            response.sendRedirect(request.getContextPath()
                    + "/CsatSurvey?ticketId=" + ticketId + "&success=1");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/CsatSurvey?ticketId=" + ticketId + "&error=save_failed");
        }
    }
}