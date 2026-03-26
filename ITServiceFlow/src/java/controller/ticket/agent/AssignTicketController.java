/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.agent;

/**
 *
 * @author Dumb Trung
 */



import dao.TicketDAO;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AssignTicket", urlPatterns = {"/AssignTicket"})
public class AssignTicketController extends HttpServlet {

    // Xử lý luồng: IT Support (LV1) bấm "Assign to me" (Gọi qua thẻ <a>)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processAssign(request, response, true);
    }

    // Xử lý luồng: Manager (LV2) gán cho người khác (Gọi qua Form Submit Modal)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processAssign(request, response, false);
    }

    private void processAssign(HttpServletRequest request, HttpServletResponse response, boolean isAssignToMe) 
            throws IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter(isAssignToMe ? "id" : "ticketId"));
            int agentId;

            if (isAssignToMe) {
                // LV1 tự nhận việc
                agentId = currentUser.getId();
            } else {
                // LV2 gán cho người khác từ Dropdown
                agentId = Integer.parseInt(request.getParameter("agentId"));
            }

            TicketDAO dao = new TicketDAO();
            dao.assignTicket(ticketId, agentId);

            // Nguồn request từ đâu thì trả về trang đó (Queue hoặc Detail)
            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains("Queues")) {
                response.sendRedirect(request.getContextPath() + "/Queues");
            } else {
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}
