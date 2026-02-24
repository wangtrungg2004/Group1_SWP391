/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

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
import model.Users;
import service.ApprovalService;

@WebServlet("/SubmitChangeRequest")
public class SubmitChangeRequest extends HttpServlet {
    private ApprovalService service = new ApprovalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null || !"IT Support".equals(user.getRole())) {
            response.sendRedirect("Login");
            return;
        }

        request.getRequestDispatcher("/SubmitChangeRequest.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null || !"IT Support".equals(user.getRole())) {
            response.sendRedirect("Login");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String changeType = request.getParameter("changeType");
        String riskLevel = request.getParameter("riskLevel");
        String rollbackPlan = request.getParameter("rollbackPlan");
        String plannedStartStr = request.getParameter("plannedStart");
        String plannedEndStr = request.getParameter("plannedEnd");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        java.util.Date plannedStart = null, plannedEnd = null;
        try {
            if (plannedStartStr != null && !plannedStartStr.isEmpty()) {
                plannedStart = sdf.parse(plannedStartStr);
            }
            if (plannedEndStr != null && !plannedEndStr.isEmpty()) {
                plannedEnd = sdf.parse(plannedEndStr);
            }
        } catch (ParseException e) {
            request.setAttribute("error", "Định dạng ngày không hợp lệ (yyyy-MM-dd)");
            doGet(request, response);
            return;
        }

        int result = service.submitChangeRequest(user.getId(), title, description, changeType, riskLevel, rollbackPlan, plannedStart, plannedEnd);

        if (result > 0) {
            request.setAttribute("success", "Đã gửi yêu cầu thay đổi thành công (ID: " + result + ")");
        } else {
            request.setAttribute("error", "Gửi thất bại. Vui lòng kiểm tra Risk Level và Rollback Plan bắt buộc.");
        }

        doGet(request, response);
    }
}