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

@WebServlet(name = "UpdateTicketStatus", urlPatterns = {"/UpdateStatus"})
public class UpdateStatusController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        String status = request.getParameter("status"); // VD: "In Progress", "Resolved"
        
        if (idParam != null && !idParam.isEmpty() && status != null && !status.isEmpty()) {
            int ticketId = Integer.parseInt(idParam);
            TicketDAO ticketDao = new TicketDAO();
            
            // Đổi trạng thái vé
            ticketDao.updateTicketStatus(ticketId, status);
            
            // CẬP NHẬT GIAO DIỆN: Tự động tải lại trang để hiển thị trạng thái mới
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
        } else {
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}