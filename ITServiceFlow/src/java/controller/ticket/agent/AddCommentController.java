/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.agent;

/**
 *
 * @author Dumb Trung
 */


import dao.TicketCommentsDAO;
import model.TicketComments;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AddComment", urlPatterns = {"/AddComment", "/AddAgentComment"})
public class AddCommentController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int ticketId = Integer.parseInt(request.getParameter("ticketId"));
        String text = request.getParameter("content"); // Tên biến khớp với Model của bạn
        boolean isInternal = Boolean.parseBoolean(request.getParameter("isInternal"));

        if (text != null && !text.trim().isEmpty()) {
            TicketComments c = new TicketComments();
            c.setTicketId(ticketId);
            c.setUserId(currentUser.getId());
            c.setContent(text.trim());
            
            // Ép buộc bảo mật: User thường không bao giờ được gửi Internal Note dù họ có hack html
            if ("User".equals(role)) {
                c.setInternal(false);
            } else {
                c.setInternal(isInternal);
            }
            
            new TicketCommentsDAO().addComment(c);
        }

        // Tự động điều hướng về lại màn hình cũ
        if ("User".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/TicketDetailUser?id=" + ticketId);
        } else {
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
        }
    }
}
