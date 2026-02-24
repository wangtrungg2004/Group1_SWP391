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

@WebServlet("/MyChangeRequests")
public class MyChangeRequests extends HttpServlet {
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

        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "all";

        List<ChangeRequests> requests = service.getMyRequests(user.getId(), tab.equals("all") ? null : tab);

        request.setAttribute("requests", requests);
        request.setAttribute("tab", tab);
        request.getRequestDispatcher("/MyChangeRequests.jsp").forward(request, response);
    }
}
