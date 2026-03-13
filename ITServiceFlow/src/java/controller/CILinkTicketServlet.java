package controller;

import dao.AssetsDAO;
import dao.TicketAssetsDAO;
import dao.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Assets;
import model.Tickets;

@WebServlet(name = "CILinkTicketServlet", urlPatterns = {"/CILinkTicketServlet"})
public class CILinkTicketServlet extends HttpServlet {

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
        response.sendRedirect("CIListServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String assetIdStr = request.getParameter("assetId");
        String ticketNumber = request.getParameter("ticketNumber");

        if (assetIdStr == null || assetIdStr.trim().isEmpty()) {
            response.sendRedirect("CIListServlet?errorMessage=Asset+ID+is+required");
            return;
        }

        int assetId;
        try {
            assetId = Integer.parseInt(assetIdStr.trim());
        } catch (NumberFormatException ex) {
            response.sendRedirect("CIListServlet?errorMessage=Invalid+Asset+ID");
            return;
        }

        if (ticketNumber == null || ticketNumber.trim().isEmpty()) {
            response.sendRedirect("CIListServlet?errorMessage=Ticket+Number+is+required");
            return;
        }

        Assets asset = assetsDAO.getAssetById(assetId);
        if (asset == null) {
            response.sendRedirect("CIListServlet?errorMessage=Asset+not+found");
            return;
        }

        Tickets ticket = ticketDAO.getTicketByNumber(ticketNumber.trim());
        if (ticket == null) {
            response.sendRedirect("CIListServlet?errorMessage=Ticket+Number+not+found");
            return;
        }

        boolean linked = ticketAssetsDAO.addLink(ticket.getId(), assetId);
        if (!linked) {
            response.sendRedirect("CIListServlet?errorMessage=Link+failed+or+already+exists");
            return;
        }

        response.sendRedirect("CIListServlet?successMessage=Link+successfull");
    }

    @Override
    public String getServletInfo() {
        return "Link CI to ticket by ticket number";
    }
}
