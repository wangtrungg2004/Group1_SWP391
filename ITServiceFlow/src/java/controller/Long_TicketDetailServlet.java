package controller;

import dao.TicketDAO;
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

    private TicketDAO ticketDAO;

    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
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
        doGet(request, response);
    }
}