/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.TicketService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "Tickets", urlPatterns = { "/tickets" }) // URL pattern lowercase to match link
public class Tickets extends HttpServlet {

    private TicketService ticketService = new TicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Default action
        }

        switch (action) {
            case "view":
                viewTicket(request, response);
                break;
            default:
                // For now, redirect to Dashboard or show error, as list is not requested yet
                // Or maybe forward to a simple list page if created
                // response.sendRedirect("AdminDashboard.jsp");
                // For this task, we focus on view.
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Action not supported or list view not implemented yet.");
                break;
        }
    }

    private void viewTicket(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                model.Tickets ticket = ticketService.getTicketById(id);
                if (ticket != null) {
                    request.setAttribute("ticket", ticket);
                    request.getRequestDispatcher("ticket-detail.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Ticket not found with ID: " + id);
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Ticket ID format.");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ticket ID is required.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

}
