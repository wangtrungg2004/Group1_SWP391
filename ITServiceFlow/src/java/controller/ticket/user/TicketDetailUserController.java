package controller.ticket.user;

import dao.CategoryDao;
import dao.CsatSurveyDAO;
import dao.ServiceCatalogDao;
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
 * TicketDetailUserController — CẬP NHẬT cho US20
 *
 * Thêm: Nếu Tickets.Status = 'Closed', load CsatSurvey (nếu có)
 * để ticket_detail.jsp hiển thị banner CSAT phù hợp.
 *
 * Không thay đổi logic cũ, chỉ thêm ~7 dòng sau khi set attribute "ticket".
 */
@WebServlet(name = "TicketDetailUser", urlPatterns = {"/TicketDetailUser"})
public class TicketDetailUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        int ticketId = Integer.parseInt(idParam);
        TicketDAO ticketDao = new TicketDAO();

        // Lấy ticket từ bảng Tickets (dùng method có sẵn)
        Tickets ticket = ticketDao.getTicketById(ticketId);

        // Kiểm tra: ticket tồn tại và Tickets.CreatedBy = Users.Id hiện tại
        if (ticket == null || ticket.getCreatedBy() != currentUser.getId()) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        request.setAttribute("ticket", ticket);

        // ── US20: Load CSAT survey nếu Tickets.Status = 'Closed' ──────────────
        if ("Closed".equalsIgnoreCase(ticket.getStatus())) {
            CsatSurveyDAO csatDao = new CsatSurveyDAO();
            CsatSurvey survey = csatDao.getSurveyByTicket(ticketId);
            if (survey != null) {
                // Đã có survey → forward vào JSP để hiển thị kết quả
                request.setAttribute("csatSurvey", survey);
            }
            // Nếu null → JSP sẽ hiển thị nút "Give Feedback"
        }
        // ──────────────────────────────────────────────────────────────────────

        CategoryDao catDao = new CategoryDao();
        ServiceCatalogDao svcDao = new ServiceCatalogDao();
        request.setAttribute("categories", catDao.getAllCategories());
        request.setAttribute("services", svcDao.getAllServices());

        request.getRequestDispatcher("/ticket/ticket_detail.jsp").forward(request, response);
    }
}