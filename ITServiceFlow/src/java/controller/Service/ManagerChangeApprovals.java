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
import java.util.List;
import model.ChangeRequests;
import model.Users;
import service.ApprovalService;

@WebServlet("/ManagerChangeApprovals")
public class ManagerChangeApprovals extends HttpServlet {
    private ApprovalService service = new ApprovalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null || !"Manager".equals(user.getRole())) {
            response.sendRedirect("Login");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "pending";

        List<ChangeRequests> requests;
        if ("all".equals(tab)) {
            requests = service.getAllRequests();
        } else {
            requests = service.getPendingRequests();
        }

        request.setAttribute("requests", requests);
        request.setAttribute("tab", tab);
        request.getRequestDispatcher("/ManagerChangeApprovals.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null || !"Manager".equals(user.getRole())) {
            response.sendRedirect("Login");
            return;
        }

        String action = request.getParameter("action");
        String changeIdStr = request.getParameter("changeId");
        String comment = request.getParameter("comment");

        int changeId = Integer.parseInt(changeIdStr);
        String decision = "";
        if ("approve".equals(action)) decision = "Approved";
        else if ("reject".equals(action)) decision = "Rejected";
        else if ("escalate".equals(action)) decision = "Escalated";

        boolean success = service.processDecision(changeId, user.getId(), decision, comment);

        if (success) {
            request.setAttribute("success", "Đã xử lý yêu cầu: " + decision);
        } else {
            request.setAttribute("error", "Xử lý thất bại");
        }

        doGet(request, response);
    }
}
