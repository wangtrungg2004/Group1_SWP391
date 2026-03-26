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

@WebServlet(name = "ProcessApproval", urlPatterns = {"/ProcessApproval"})
public class ProcessApprovalController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        // Bảo mật cấp cao: Chỉ Manager (hoặc Admin) mới có quyền gọi API duyệt vé
        if (currentUser == null || (!"Manager".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter("id"));
            String action = request.getParameter("action"); // Nhận giá trị 'approve' hoặc 'reject'
            
            TicketDao dao = new TicketDao();
            
            if ("approve".equals(action)) {
                dao.processApproval(ticketId, currentUser.getId(), true);
            } else if ("reject".equals(action)) {
                dao.processApproval(ticketId, currentUser.getId(), false);
            }
            
            // Duyệt xong tải lại trang chi tiết đó
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}
