package controller.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.ChangeApproval;
import model.ChangeRequests;
import model.Users;
import service.ApprovalService;

@WebServlet("/ManagerChangeApprovals")
public class ManagerChangeApprovals extends HttpServlet {

    private final ApprovalService service = new ApprovalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        if (!hasManagerApprovalPermission(session, user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to access this page.");
            return;
        }

        // Flash messages
        String flash    = (String) session.getAttribute("flashSuccess");
        String flashErr = (String) session.getAttribute("flashError");
        if (flash    != null) { request.setAttribute("success", flash);    session.removeAttribute("flashSuccess"); }
        if (flashErr != null) { request.setAttribute("error",   flashErr); session.removeAttribute("flashError");   }

        String action = request.getParameter("action");

        // ── action=view → trang chi tiết RFC ──────────────────────────────
        if ("view".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
                return;
            }
            try {
                int id = Integer.parseInt(idStr);
                ChangeRequests rfc = service.getById(id);
                if (rfc == null) {
                    session.setAttribute("flashError", "Không tìm thấy RFC #" + id);
                    response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
                    return;
                }
                List<ChangeApproval> history = service.getHistory(id);
                request.setAttribute("rfc",     rfc);
                request.setAttribute("history", history);
                request.getRequestDispatcher("/RFCDetail.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
            }
            return;
        }

        // ── Mặc định: danh sách (có filter/search) ───────────────────────
        String tab     = request.getParameter("tab");
        String keyword = request.getParameter("keyword");
        if (tab == null || tab.isEmpty()) tab = "pending";
        if (keyword == null) keyword = "";

        List<ChangeRequests> requests;
        if (!keyword.trim().isEmpty()) {
            // Có keyword → search
            requests = service.searchRequests(keyword.trim(), tab);
        } else if ("all".equals(tab)) {
            requests = service.getAllRequests();
        } else {
            requests = service.getPendingRequests();
        }

        request.setAttribute("requests", requests);
        request.setAttribute("tab",      tab);
        request.setAttribute("keyword",  keyword);
        request.getRequestDispatcher("/ManagerChangeApprovals.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        if (!hasManagerApprovalPermission(session, user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to perform this action.");
            return;
        }

        String action      = request.getParameter("action");
        String changeIdStr = request.getParameter("changeId");
        String comment     = request.getParameter("comment");

        // Validate
        if (changeIdStr == null || changeIdStr.isEmpty()) {
            session.setAttribute("flashError", "Yêu cầu không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
            return;
        }

        int changeId;
        try { changeId = Integer.parseInt(changeIdStr); }
        catch (NumberFormatException e) {
            session.setAttribute("flashError", "ID RFC không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
            return;
        }

        // Reject bắt buộc comment
        if ("reject".equals(action) && (comment == null || comment.trim().isEmpty())) {
            session.setAttribute("flashError", "Vui lòng nhập lý do khi từ chối RFC.");
            response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
            return;
        }

        String decision = "";
        if ("approve".equals(action))  decision = "Approved";
        else if ("reject".equals(action)) decision = "Rejected";

        boolean ok = service.processDecision(changeId, user.getId(), decision, comment);

        if (ok) {
            session.setAttribute("flashSuccess",
                "Approved".equals(decision)
                    ? "✅ RFC đã được phê duyệt. IT Support đã nhận thông báo."
                    : "RFC đã bị từ chối. IT Support đã nhận thông báo.");
        } else {
            session.setAttribute("flashError", "Xử lý thất bại. Vui lòng thử lại.");
        }

        response.sendRedirect(request.getContextPath() + "/ManagerChangeApprovals");
    }

    private boolean hasManagerApprovalPermission(HttpSession session, Users user) {
        if (session == null || user == null) {
            return false;
        }

        String effectiveRole = toRole(session.getAttribute("role"));
        String baseRole = toRole(session.getAttribute("baseRole"));
        return isManagerRole(effectiveRole) && isManagerRole(baseRole);
    }

    private boolean isManagerRole(String role) {
        return "Manager".equalsIgnoreCase(role);
    }

    private String toRole(Object roleObj) {
        if (roleObj == null) {
            return null;
        }
        return roleObj.toString().trim();
    }
}
