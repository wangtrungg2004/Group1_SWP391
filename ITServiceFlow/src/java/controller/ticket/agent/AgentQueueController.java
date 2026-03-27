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
import dao.TicketAssetsDAO;
import model.Tickets;
import model.Users;
import model.Assets;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AgentQueue", urlPatterns = {"/Queues"})
public class AgentQueueController extends HttpServlet {

    // Trong AgentQueueController.java

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || role == null || (!role.equals("Manager") && !role.equals("IT Support"))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        // 1. THAM SỐ 1: Hàng đợi (Đổi thành 'queue')
        String queueType = request.getParameter("queue");
        if (queueType == null || queueType.isEmpty()) queueType = "unassigned";

        // 2. THAM SỐ 2: Các bộ lọc
        String search = request.getParameter("search");
        if (search == null) search = "";
        String status = request.getParameter("status");
        if (status == null) status = "all";
        
        // ĐỔI TÊN BIẾN: 'type' thành 'ticketType' để không bị trùng
        String ticketType = request.getParameter("ticketType");
        if (ticketType == null) ticketType = "all";

        String priority = request.getParameter("priority");
        if (priority == null) priority = "all";

        int page = 1;
        int pageSize = 10; 
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) { try { page = Integer.parseInt(pageStr); } catch (Exception e) { page = 1; } }
        
     int offset = (page - 1) * pageSize;
        TicketDAO ticketDao = new TicketDAO();

        // XÁC ĐỊNH LEVEL CỦA AGENT ĐANG ĐĂNG NHẬP
        int currentLevel = ("Manager".equals(role) || "Admin".equals(role)) ? 2 : 1;

        // Truyền thêm currentLevel vào DAO
        int totalTickets = ticketDao.getTotalAgentQueuesCount(currentUser.getId(), currentLevel, queueType, search, status, ticketType, priority);
        int totalPages = (int) Math.ceil((double) totalTickets / pageSize);
        List<Tickets> queueList = ticketDao.getAgentQueues(currentUser.getId(), currentLevel, queueType, offset, pageSize, search, status, ticketType, priority);
        
        // Gắn thông tin Asset cho từng ticket trong hàng đợi
        TicketAssetsDAO ticketAssetsDAO = new TicketAssetsDAO();
        for (Tickets t : queueList) {
            List<Assets> linkedAssets = ticketAssetsDAO.getLinkedCIsByTicketId(t.getId());
            t.setLinkedAssets(linkedAssets);
        }

// Nếu là Manager, lấy danh sách IT Support để phục vụ Modal gán vé trên Queue
        // Sửa trong cả 2 file Controller (AgentTicketDetail và AgentQueue)
        if ("Manager".equals(session.getAttribute("role")) || "Admin".equals(session.getAttribute("role"))) {
            request.setAttribute("itSupportList", ticketDao.getActiveAgents());
        }       
// 4. Đẩy ra View
        request.setAttribute("queueList", queueList);
        request.setAttribute("currentQueue", queueType); // Tab đang mở
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("search", search);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedTicketType", ticketType); // Đổi tên attribute
        request.setAttribute("selectedPriority", priority);
        
        request.getRequestDispatcher("/ticket/agent_queue.jsp").forward(request, response);
    }
}
