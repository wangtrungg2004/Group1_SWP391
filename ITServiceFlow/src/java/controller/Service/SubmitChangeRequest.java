package controller.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import model.Tickets;
import model.Users;
import service.ApprovalService;

/**
 * GET  /SubmitChangeRequest          → Hiển thị form tạo RFC (pre-fill từ ticket nếu có)
 * GET  /SubmitChangeRequest?from=ticketId → Pre-fill từ ticket gốc
 * POST /SubmitChangeRequest          → Tạo RFC (Draft hoặc Pending Approval)
 */
@WebServlet("/SubmitChangeRequest")
public class SubmitChangeRequest extends HttpServlet {

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

        // Lấy danh sách ticket assigned cho IT Support để pre-select (giảm nhập tay)
        List<Tickets> assignedTickets = service.getAssignedTicketsForRFC(user.getId());
        request.setAttribute("assignedTickets", assignedTickets);

        // Nếu mở form từ một ticket cụ thể → pre-fill linkedTicketId
        String fromTicketId = request.getParameter("from");
        if (fromTicketId != null && !fromTicketId.isEmpty()) {
            request.setAttribute("preSelectedTicketId", fromTicketId);
        }

        request.getRequestDispatcher("/SubmitChangeRequest.jsp").forward(request, response);
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

        String title          = request.getParameter("title");
        String description    = request.getParameter("description");
        String changeType     = request.getParameter("changeType");
        String riskLevel      = request.getParameter("riskLevel");
        String rollbackPlan   = request.getParameter("rollbackPlan");
        String plannedStartStr = request.getParameter("plannedStart");
        String plannedEndStr   = request.getParameter("plannedEnd");
        String linkedTicketStr = request.getParameter("linkedTicketId");
        String action          = request.getParameter("action"); // "draft" hoặc "submit"

        // Validate bắt buộc
        if (title == null || title.trim().isEmpty()
                || changeType == null || changeType.trim().isEmpty()
                || riskLevel == null || riskLevel.trim().isEmpty()
                || rollbackPlan == null || rollbackPlan.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ: Tiêu đề, Loại thay đổi, Mức rủi ro, Kế hoạch rollback.");
            doGet(request, response);
            return;
        }

        // Parse ngày
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        sdf.setLenient(false);
        java.util.Date plannedStart = null, plannedEnd = null;
        try {
            if (plannedStartStr != null && !plannedStartStr.isEmpty())
                plannedStart = sdf.parse(plannedStartStr);
            if (plannedEndStr != null && !plannedEndStr.isEmpty())
                plannedEnd = sdf.parse(plannedEndStr);
        } catch (ParseException e) {
            request.setAttribute("error", "Định dạng ngày không hợp lệ (yyyy-MM-dd).");
            doGet(request, response);
            return;
        }

        // Validate ngày kết thúc >= ngày bắt đầu
        if (plannedStart != null && plannedEnd != null && plannedEnd.before(plannedStart)) {
            request.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu.");
            doGet(request, response);
            return;
        }

        // Parse linkedTicketId (optional)
        Integer linkedTicketId = null;
        if (linkedTicketStr != null && !linkedTicketStr.isEmpty()) {
            try { linkedTicketId = Integer.parseInt(linkedTicketStr); }
            catch (NumberFormatException ignored) {}
        }

        boolean savedAsDraft = "draft".equals(action);

        int result = service.submitChangeRequest(
                user.getId(), title, description, changeType, riskLevel, rollbackPlan,
                plannedStart, plannedEnd, linkedTicketId, savedAsDraft
        );

        if (result > 0) {
            if (savedAsDraft) {
                session.setAttribute("flashSuccess",
                    "RFC đã lưu nháp. Bạn có thể hoàn thiện và gửi sau.");
            } else {
                session.setAttribute("flashSuccess",
                    "RFC đã gửi thành công và đang chờ Manager duyệt!");
            }
            response.sendRedirect(request.getContextPath() + "/MyChangeRequests");
        } else {
            request.setAttribute("error", "Tạo RFC thất bại. Vui lòng kiểm tra lại thông tin.");
            doGet(request, response);
        }
    }
}
