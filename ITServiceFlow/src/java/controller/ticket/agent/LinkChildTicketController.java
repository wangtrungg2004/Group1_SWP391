/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.agent;

/**
 *
 * @author Dumb Trung
 */

import dao.TicketDao;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LinkChildTicket", urlPatterns = {"/LinkChildTicket"})
public class LinkChildTicketController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int parentId = Integer.parseInt(request.getParameter("ticketId"));
        // Lấy danh sách các Checkbox được tick từ Modal
        String[] childIds = request.getParameterValues("childTicketIds"); 

        if (childIds != null && childIds.length > 0) {
            TicketDao ticketDao = new TicketDao();
            ticketDao.linkChildTickets(parentId, childIds);
        }

        // F5 lại trang Detail
        response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + parentId);
    }
}
