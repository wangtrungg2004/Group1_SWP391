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
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String ticketIdStr = request.getParameter("ticketId");
        String assetTag = request.getParameter("assetTag");

        if (ticketIdStr == null || ticketIdStr.trim().isEmpty()) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Ticket+ID+is+required");
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr.trim());
        } catch (NumberFormatException ex) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Invalid+Ticket+ID");
            return;
        }

        if (assetTag == null || assetTag.trim().isEmpty()) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Asset-tag+is+required");
            return;
        }

        Tickets ticket = ticketDAO.getTicketById(ticketId);
        if (ticket == null) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Ticket+not+found");
            return;
        }

        Assets asset = assetsDAO.getAssetByTag(assetTag.trim());
        if (asset == null) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Asset-tag+not+found");
            return;
        }

        boolean linked = ticketAssetsDAO.addLink(ticketId, asset.getId());
        if (!linked) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Link+failed+or+already+exists");
            return;
        }

        response.sendRedirect("Long_TicketListServlet?successMessage=Linked+ticket+to+asset+successfully");
    }
}
