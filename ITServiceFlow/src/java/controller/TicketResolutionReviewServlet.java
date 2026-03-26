package controller;

import dao.KnowledgeArticleDAO;
import dao.TicketDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Tickets;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "TicketResolutionReviewServlet", urlPatterns = { "/TicketResolutionReview" })
public class TicketResolutionReviewServlet extends HttpServlet {

    private TicketDao ticketDAO;
    private KnowledgeArticleDAO knowledgeDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketDAO = new TicketDao();
        knowledgeDAO = new KnowledgeArticleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Auth check - only IT Support
        Object userObj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("user")
                : null;
        String role = (userObj != null)
                ? (String) request.getSession(false).getAttribute("role")
                : null;
        if (userObj == null || !"IT Support".equals(role)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // Lấy params
        String ticketIdStr = request.getParameter("ticketId");
        String ticketNumber = request.getParameter("ticketNumber");
        String keyword = request.getParameter("keyword");
        String type = request.getParameter("type");
        String successParam = request.getParameter("success");
        String errorParam = request.getParameter("error");

        // Case 1: Có ticketId (numeric) – load chi tiết ticket
        if (ticketIdStr != null && !ticketIdStr.trim().isEmpty()) {
            try {
                int ticketId = Integer.parseInt(ticketIdStr.trim());
                Tickets ticket = ticketDAO.getTicketById(ticketId);
                if (ticket == null) {
                    request.setAttribute("errorMessage", "Không tìm thấy ticket #" + ticketId);
                } else {
                    if (!"Resolved".equals(ticket.getStatus())) {
                        request.setAttribute("warningMessage",
                                "Ticket " + ticket.getTicketNumber() + " chưa Resolved (hiện: " + ticket.getStatus()
                                        + ").");
                    }
                    if ("true".equals(successParam)) {
                        request.setAttribute("successMessage", "Đã lưu resolution thành công!");
                    }
                    if ("true".equals(errorParam)) {
                        request.setAttribute("errorMessage", "Lưu thất bại, vui lòng thử lại.");
                    }
                    request.setAttribute("ticket", ticket);
                }
                request.getRequestDispatcher("/TicketResolutionReview.jsp").forward(request, response);
                return;
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "ID ticket không hợp lệ.");
                request.getRequestDispatcher("/TicketResolutionReview.jsp").forward(request, response);
                return;
            }
        }

        // Case 2: Có ticketNumber – load chi tiết theo TicketNumber
        if (ticketNumber != null && !ticketNumber.trim().isEmpty()) {
            Tickets ticket = ticketDAO.getTicketByNumber(ticketNumber.trim());
            if (ticket == null) {
                request.setAttribute("errorMessage", "Không tìm thấy ticket số: " + ticketNumber);
                // Vẫn hiện danh sách
                List<Tickets> list = ticketDAO.getResolvedTickets(null, null);
                request.setAttribute("resolvedTickets", list);
            } else {
                if (!"Resolved".equals(ticket.getStatus())) {
                    request.setAttribute("warningMessage",
                            "Ticket " + ticket.getTicketNumber() + " chưa Resolved (hiện: " + ticket.getStatus()
                                    + ").");
                }
                request.setAttribute("ticket", ticket);
            }
            request.getRequestDispatcher("/TicketResolutionReview.jsp").forward(request, response);
            return;
        }

        // Case 3: Hiện danh sách (có thể lọc theo keyword TicketNumber và TicketType)
        List<Tickets> list = ticketDAO.getResolvedTickets(keyword, type);
        request.setAttribute("resolvedTickets", list);
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.setAttribute("type", type != null ? type : "All");
        request.getRequestDispatcher("/TicketResolutionReview.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Object userObj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("user")
                : null;
        String role = (userObj != null)
                ? (String) request.getSession(false).getAttribute("role")
                : null;
        if (userObj == null || !"IT Support".equals(role)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String ticketIdStr = request.getParameter("ticketId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String resolutionSteps = request.getParameter("resolutionSteps");

        if (ticketIdStr == null || ticketIdStr.trim().isEmpty()) {
            response.sendRedirect("TicketResolutionReview");
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("TicketResolutionReview");
            return;
        }

        boolean success = knowledgeDAO.updateTicketResolution(
                ticketId,
                title != null ? title.trim() : "",
                description != null ? description.trim() : "",
                resolutionSteps != null ? resolutionSteps.trim() : "");

        response.sendRedirect("TicketResolutionReview?ticketId=" + ticketId
                + (success ? "&success=true" : "&error=true"));
    }
}
