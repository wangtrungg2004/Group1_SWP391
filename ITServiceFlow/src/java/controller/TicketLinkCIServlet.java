package controller;

import dao.TicketDAO;
import dao.TicketAssetsDAO;
import dao.AssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Tickets;
import model.Assets;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "TicketLinkCIServlet", urlPatterns = {"/TicketLinkCIServlet"})
public class TicketLinkCIServlet extends HttpServlet {

    private TicketDAO ticketDAO;
    private TicketAssetsDAO ticketAssetsDAO;
    private AssetsDAO assetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketDAO = new TicketDAO();
        ticketAssetsDAO = new TicketAssetsDAO();
        assetsDAO = new AssetsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String ticketIdStr = request.getParameter("ticketId");

        if (ticketIdStr == null || ticketIdStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Ticket ID is required.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid Ticket ID format.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        Tickets ticket = ticketDAO.getTicketById(ticketId);
        if (ticket == null) {
            request.setAttribute("errorMessage", "Ticket not found with ID: " + ticketId);
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        List<Assets> linkedCIs = ticketAssetsDAO.getLinkedCIsByTicketId(ticketId);

        request.setAttribute("ticket", ticket);
        request.setAttribute("linkedCIs", linkedCIs);

        request.getRequestDispatcher("/TicketLinkCI.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
