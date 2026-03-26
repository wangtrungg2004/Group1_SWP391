package controller.ticket.user;

import dao.AuditLogsDAO;
import dao.CategoryDao;
import dao.CsatSurveyDAO;
import dao.ServiceCatalogDao;
import dao.TicketCommentsDAO;
import dao.TicketDao;
import model.AuditLog;
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
import java.util.List;
import model.TicketComments;

/**
 * TicketDetailUserController  CP NHT cho US20
 *
 * Thm: Nu Tickets.Status = 'Closed', load CsatSurvey (nu c)
 *  ticket_detail.jsp hin th banner CSAT ph hp.
 *
 * Khng thay i logic c, ch thm ~7 dng sau khi set attribute "ticket".
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

        int ticketId;
        try {
            ticketId = Integer.parseInt(idParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        TicketDao ticketDao = new TicketDao();

        // Ly ticket t bng Tickets (dng method c sn)
        Tickets ticket = ticketDao.getTicketById(ticketId);

        // Kim tra: ticket tn ti v Tickets.CreatedBy = Users.Id hin ti
        if (ticket == null || ticket.getCreatedBy() != currentUser.getId()) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }
        
        // Ly danh sch Comment
        TicketCommentsDAO commentDao = new TicketCommentsDAO();
        // Truyn 'true' v Agent c quyn xem Internal Note
        List<TicketComments> comments = commentDao.getCommentsByTicketId(ticketId, false);
        request.setAttribute("comments", comments);

        request.setAttribute("ticket", ticket);

        String flashType = (String) session.getAttribute("ticketDetailFlashType");
        String flashMessage = (String) session.getAttribute("ticketDetailFlashMessage");
        if (flashMessage != null && !flashMessage.isEmpty()) {
            request.setAttribute("ticketDetailFlashType", flashType);
            request.setAttribute("ticketDetailFlashMessage", flashMessage);
            session.removeAttribute("ticketDetailFlashType");
            session.removeAttribute("ticketDetailFlashMessage");
        }

        //  US20: Load CSAT survey nu Tickets.Status = 'Closed' 
        if ("Closed".equalsIgnoreCase(ticket.getStatus())) {
            CsatSurveyDAO csatDao = new CsatSurveyDAO();
            CsatSurvey survey = csatDao.getSurveyByTicket(ticketId);
            if (survey != null) {
                //  c survey  forward vo JSP  hin th kt qu
                request.setAttribute("csatSurvey", survey);
            }
            // Nu null  JSP s hin th nt "Give Feedback"
        }
        // 

        // Load Timeline (Audit Log) cho ticket này
        AuditLogsDAO auditDao = new AuditLogsDAO();
        List<AuditLog> timeline = auditDao.getByEntity("Ticket", ticketId);
        request.setAttribute("timeline", timeline);

        CategoryDao catDao = new CategoryDao();
        ServiceCatalogDao svcDao = new ServiceCatalogDao();
        request.setAttribute("categories", catDao.getAllCategories());
        request.setAttribute("services", svcDao.getAllServices());

        request.getRequestDispatcher("/ticket/ticket_detail.jsp").forward(request, response);
    }
}

