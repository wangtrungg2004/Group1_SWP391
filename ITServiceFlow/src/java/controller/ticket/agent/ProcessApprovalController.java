package controller.ticket.agent;

import dao.TicketDAO;
import dao.TicketCommentsDAO;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ProcessApproval", urlPatterns = {"/ProcessApproval"})
public class ProcessApprovalController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter("id"));
            String action = request.getParameter("action");
            TicketDAO dao = new TicketDAO();
            TicketCommentsDAO commentDao = new TicketCommentsDAO();
            
            if ("approve".equals(action)) {
                dao.processApproval(ticketId, currentUser.getId(), true);
                commentDao.addComment(ticketId, currentUser.getId(), "Service request approved. The system has automatically allocated the Priority and SLA based on the Service Catalog.", false);
                
            } else if ("reject".equals(action)) {
                String rejectReason = request.getParameter("rejectReason");
                dao.processApproval(ticketId, currentUser.getId(), false);
                commentDao.addComment(ticketId, currentUser.getId(), "REQUEST REJECTED.\nManager's Reason: " + rejectReason, false);
            }

            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}