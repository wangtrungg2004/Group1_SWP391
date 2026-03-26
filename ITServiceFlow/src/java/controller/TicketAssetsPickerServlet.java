package controller;

import dao.AssetsDAO;
import dao.TicketDao;
import dao.UsersDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;
import model.Assets;
import model.Tickets;
import model.Users;

@WebServlet(name = "TicketAssetsPickerServlet", urlPatterns = {"/TicketAssetsPickerServlet"})
public class TicketAssetsPickerServlet extends HttpServlet {

    private TicketDao ticketDAO;
    private UsersDAO usersDAO;
    private AssetsDAO assetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketDAO = new TicketDao();
        usersDAO = new UsersDAO();
        assetsDAO = new AssetsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String ticketIdStr = request.getParameter("ticketId");
        String keyword = request.getParameter("keyword");
        String assetType = request.getParameter("assetType");

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"invalid_ticketId\"}");
            }
            return;
        }

        Tickets ticket = ticketDAO.getTicketById(ticketId);
        if (ticket == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"ticket_not_found\"}");
            }
            return;
        }

        int createdByUserId = ticket.getCreatedBy(); // CreatedBy = Users.Id
        if (createdByUserId <= 0) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"ticket_createdBy_missing\"}");
            }
            return;
        }

        Users creator = usersDAO.getUserById(createdByUserId);
        if (creator == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"ticket_owner_not_found\"}");
            }
            return;
        }

        int locationId = creator.getLocationId();

        List<Assets> assets;
        try {
            assets = assetsDAO.searchAssetsForTicketLink(locationId, keyword, assetType);
        } catch (Exception e) {
            e.printStackTrace();
            assets = Collections.emptyList();
        }

        try (PrintWriter out = response.getWriter()) {
            out.print("{\"locationId\":");
            out.print(locationId);
            out.print(",\"assets\":[");
            for (int i = 0; i < assets.size(); i++) {
                Assets a = assets.get(i);
                if (i > 0) out.print(",");
                out.print("{");
                out.print("\"id\":" + a.getId() + ",");
                out.print("\"assetTag\":\"" + escapeJson(a.getAssetTag()) + "\",");
                out.print("\"name\":\"" + escapeJson(a.getName()) + "\",");
                out.print("\"assetType\":\"" + escapeJson(a.getAssetType()) + "\",");
                out.print("\"ownerName\":\"" + escapeJson(a.getOwnerName()) + "\"");
                out.print("}");
            }
            out.print("]}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    sb.append(c);
            }
        }
        return sb.toString();
    }
}

