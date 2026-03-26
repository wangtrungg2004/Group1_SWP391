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
import dao.SLATrackingDao;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "EditTicket", urlPatterns = {"/EditTicket"})
public class TicketEditController extends HttpServlet {

    // Công thức ma trận ITIL để tính Priority mới
    private int calculatePriority(int impact, int urgency) {
        int score = impact + urgency;
        if (score <= 2) return 1; // Critical
        if (score <= 4) return 2; // High
        if (score <= 5) return 3; // Medium
        return 4; // Low
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"IT Support".equals(role) && !"Manager".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            
            TicketDao dao = new TicketDao();
            Tickets t = dao.getTicketById(ticketId);

            // BẢO MẬT VẤN ĐỀ 4: Chỉ Owner (người được gán vé) HOẶC Manager mới được sửa
            
            // ĐÃ SỬA: Bắt buộc phải là Owner mới được lưu dữ liệu Edit
            boolean isOwner = (t.getAssignedTo() != null && t.getAssignedTo() == currentUser.getId());

            if (!isOwner) {
                // Trả về nếu Manager/Hacker cố tình gửi POST Request vào vé của người khác
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
                return;
            }

            Integer impact = null;
            Integer urgency = null;
            Integer priorityId = null;

            // Nếu là Incident thì mới có trò tính lại Impact/Urgency
            if ("Incident".equals(t.getTicketType())) {
                impact = Integer.parseInt(request.getParameter("impact"));
                urgency = Integer.parseInt(request.getParameter("urgency"));
                priorityId = calculatePriority(impact, urgency);
            }

            // 1. Cập nhật DB
            boolean isUpdated = dao.updateTicketTriage(ticketId, categoryId, impact, urgency, priorityId);

            // 2. GIẢI QUYẾT VẤN ĐỀ 6: TÍNH LẠI SLA NẾU MỨC ĐỘ THAY ĐỔI
            if (isUpdated && "Incident".equals(t.getTicketType()) && priorityId != null) {
                SLATrackingDao slaDao = new SLATrackingDao();
                slaDao.applySLAForTicket(ticketId, t.getTicketType(), priorityId);
            }

            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}
