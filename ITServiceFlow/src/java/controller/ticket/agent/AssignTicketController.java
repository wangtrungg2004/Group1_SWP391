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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        // Bảo mật: Chỉ Manager và Agent mới được nhận vé
        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            int ticketId = Integer.parseInt(idParam);
            TicketDAO ticketDao = new TicketDAO();
            
            // Lấy ID người dùng hiện tại và gán vào vé
            boolean isAssigned = ticketDao.assignTicket(ticketId, currentUser.getId());
            
            if(isAssigned) {
                // Thành công: Trở về trang chi tiết vé đó để xem kết quả
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
                return;
            }
        }
        
        // Nếu lỗi, trả về trang danh sách
        response.sendRedirect(request.getContextPath() + "/Agent/Queues");
    }
}
