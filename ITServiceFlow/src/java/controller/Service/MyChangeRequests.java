package controller.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.ChangeRequests;
import model.Users;
import service.ApprovalService;

/**
 * GET  /MyChangeRequests            → Danh sách RFC của IT Support
 * POST /MyChangeRequests?action=submitDraft&id=X → Submit Draft → Pending Approval
 */
@WebServlet("/MyChangeRequests")
public class MyChangeRequests extends HttpServlet {

    private final ApprovalService service = new ApprovalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null || !"IT Support".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        // Flash message từ redirect
        String flash = (String) session.getAttribute("flashSuccess");
        if (flash != null) {
            request.setAttribute("success", flash);
            session.removeAttribute("flashSuccess");
        }

        String tab     = request.getParameter("tab");
        String keyword = request.getParameter("keyword");
        if (tab == null || tab.isEmpty()) tab = "all";
        if (keyword == null) keyword = "";

        List<ChangeRequests> requests;
        if (!keyword.trim().isEmpty()) {
            String statusFilter = "all".equals(tab) ? null : tab;
            requests = service.searchMyRequests(user.getId(), keyword.trim(), statusFilter);
        } else {
            String statusFilter = "all".equals(tab) ? null : tab;
            requests = service.getMyRequests(user.getId(), statusFilter);
        }

        request.setAttribute("requests", requests);
        request.setAttribute("tab",      tab);
        request.setAttribute("keyword",  keyword);
        request.getRequestDispatcher("/MyChangeRequests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null || !"IT Support".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        if ("submitDraft".equals(action) && idStr != null) {
            try {
                int changeId = Integer.parseInt(idStr);
                boolean ok = service.submitDraft(changeId, user.getId());
                if (ok) {
                    session.setAttribute("flashSuccess", "RFC đã được gửi đến Manager để duyệt!");
                } else {
                    session.setAttribute("flashError", "Không thể gửi RFC. Chỉ có thể gửi RFC ở trạng thái Draft.");
                }
            } catch (NumberFormatException ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/MyChangeRequests");
    }
}