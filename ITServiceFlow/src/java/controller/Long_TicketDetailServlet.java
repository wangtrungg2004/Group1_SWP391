package controller;

import dao.TicketDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Tickets;

@WebServlet(name = "Long_TicketDetailServlet",
        urlPatterns = {"/Long_TicketDetailServlet", "/TicketDetailServlet", "/TicketDetail"})
public class Long_TicketDetailServlet extends HttpServlet {

    private TicketDao ticketDAO;

    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String idRaw = request.getParameter("id");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Missing ticket id.");
            request.getRequestDispatcher("/Long_TicketDetail.jsp").forward(request, response);
            return;
        }

        try {
            int ticketId = Integer.parseInt(idRaw.trim());
            Tickets ticket = ticketDAO.searchTicketById(ticketId);

            if (ticket != null) {
                request.setAttribute("ticket", ticket);
            } else {
                request.setAttribute("errorMessage", "Ticket not found.");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid ticket id format.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Cannot load ticket detail.");
        }

        request.getRequestDispatcher("/Long_TicketDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        if (action == null || !"update".equalsIgnoreCase(action.trim())) {
            doGet(request, response);
            return;
        }

        String idRaw = request.getParameter("id");
        String ticketType = request.getParameter("ticketType");
        String categoryName = request.getParameter("categoryName");
        String priorityLevel = request.getParameter("priorityLevel");
        String status = request.getParameter("status");

        int ticketId;
        try {
            ticketId = Integer.parseInt(idRaw.trim());
        } catch (Exception e) {
            response.sendRedirect("Long_TicketDetailServlet?id=" + idRaw + "&errorMessage=Invalid+ticket+id");
            return;
        }

        Integer categoryId = ticketDAO.getCategoryIdByName(categoryName);
        Integer priorityId = ticketDAO.getPriorityIdByLevel(priorityLevel);

        boolean ok = ticketDAO.updateTicketBasicFields(ticketId, ticketType, categoryId, priorityId, status);
        if (ok) {
            response.sendRedirect("Long_TicketDetailServlet?id=" + ticketId + "&successMessage=Updated+successfully");
        } else {
            response.sendRedirect("Long_TicketDetailServlet?id=" + ticketId + "&errorMessage=Update+failed");
        }
    }
}