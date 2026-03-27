package controller;

import dao.AssetsDAO;
import dao.CIRelationshipsDAO;
import dao.LocationsDAO;
import dao.TicketAssetsDAO;
import dao.TicketDAO;
import dao.UsersDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Assets;
import model.CIRelationships;
import model.Locations;
import model.Tickets;
import model.Users;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CIDetailServlet", urlPatterns = {"/CIDetailServlet"})
public class CIDetailServlet extends HttpServlet {

    private AssetsDAO assetsDAO;
    private CIRelationshipsDAO ciRelationshipsDAO;
    private TicketAssetsDAO ticketAssetsDAO;
    private TicketDAO ticketDAO;
    private UsersDAO usersDAO;
    private LocationsDAO locationsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        assetsDAO = new AssetsDAO();
        ciRelationshipsDAO = new CIRelationshipsDAO();
        ticketAssetsDAO = new TicketAssetsDAO();
        ticketDAO = new TicketDAO();
        usersDAO = new UsersDAO();
        locationsDAO = new LocationsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String idStr = request.getParameter("id");
        String ticketIdStr = request.getParameter("ticketId");

        if (idStr == null || idStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "CI ID is required.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        int ciId;
        try {
            ciId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid CI ID: " + idStr);
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        Integer ticketId = null;
        Tickets ticket = null;
        if (ticketIdStr != null && !ticketIdStr.trim().isEmpty()) {
            try {
                ticketId = Integer.parseInt(ticketIdStr.trim());
                ticket = ticketDAO.getTicketById(ticketId);
            } catch (NumberFormatException e) {
                System.err.println("[CIDetailServlet] Invalid ticketId: " + ticketIdStr);
            }
        }

        Assets ci = assetsDAO.getAssetById(ciId);
        if (ci == null) {
            request.setAttribute("errorMessage", "Configuration Item not found with ID: " + ciId);
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        // For "Add Relationship" modal: only show Active CIs in same Location (exclude current CI)
        List<Assets> targetCIs = assetsDAO.searchAssets(
                null,
                "all",
                "Active",
                null,
                ci.getLocationId(),
                null,
                null,
                null,
                null
        );
        if (targetCIs != null && !targetCIs.isEmpty()) {
            targetCIs.removeIf(a -> a != null && a.getId() == ciId);
        }

        List<CIRelationships> relationships = ciRelationshipsDAO.getRelationshipsByCIId(ciId);
        enrichRelationships(relationships);

        int relatedTicketCount = ticketAssetsDAO.getTicketIdsByAssetId(ciId).size();
        List<Users> users = usersDAO.getAllUsers();
        List<Locations> locations = locationsDAO.getAllLocations();

        request.setAttribute("ci", ci);
        request.setAttribute("targetCIs", targetCIs);
        request.setAttribute("relationships", relationships);
        request.setAttribute("relatedTicketCount", relatedTicketCount);
        request.setAttribute("users", users);
        request.setAttribute("locations", locations);
        if (ticketId != null) {
            request.setAttribute("ticketId", ticketId);
            request.setAttribute("ticket", ticket);
        }

        request.getRequestDispatcher("/CIDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void enrichRelationships(List<CIRelationships> relationships) {
        if (relationships == null || relationships.isEmpty()) {
            return;
        }
        for (CIRelationships rel : relationships) {
            Assets targetCI = assetsDAO.getAssetById(rel.getTargetCIId());
            if (targetCI != null) {
                rel.setTargetName(targetCI.getName());
                rel.setTargetAssetTag(targetCI.getAssetTag());
            }
            Assets sourceCI = assetsDAO.getAssetById(rel.getSourceCIId());
            if (sourceCI != null) {
                rel.setSourceName(sourceCI.getName());
                rel.setSourceAssetTag(sourceCI.getAssetTag());
            }
        }
    }
}
