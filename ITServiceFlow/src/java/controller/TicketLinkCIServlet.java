package controller;

import dao.AssetsDAO;
import dao.TicketAssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Assets;

@WebServlet(name = "TicketLinkCIServlet", urlPatterns = {"/TicketLinkCIServlet"})
public class TicketLinkCIServlet extends HttpServlet {

    private TicketAssetsDAO ticketAssetsDAO;
    private AssetsDAO assetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketAssetsDAO = new TicketAssetsDAO();
        assetsDAO = new AssetsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String ticketIdStr = request.getParameter("ticketId");
        String assetTag = request.getParameter("assetTag");

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
        } catch (Exception e) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Invalid+ticketId");
            return;
        }

        if (assetTag == null || assetTag.trim().isEmpty()) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=AssetTag+is+required");
            return;
        }

        Assets asset = assetsDAO.getAssetByTag(assetTag.trim());
        if (asset == null) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Asset+not+found");
            return;
        }

        boolean success = ticketAssetsDAO.addLink(ticketId, asset.getId());
        if (success) {
            response.sendRedirect("Long_TicketListServlet?successMessage=Linked+asset+successfully");
        } else {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Asset+already+linked+or+failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

