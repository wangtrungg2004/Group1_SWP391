package controller;

import dao.TicketAssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@WebServlet(name = "TicketLinkCIListServlet", urlPatterns = {"/TicketLinkCIListServlet"})
public class TicketLinkCIListServlet extends HttpServlet {

    private TicketAssetsDAO ticketAssetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketAssetsDAO = new TicketAssetsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String keywordParam = request.getParameter("keyword");
        String keyword = (keywordParam == null) ? "" : keywordParam.trim();

        List<Map<String, Object>> ticketCiLinkList;
        try {
            ticketCiLinkList = ticketAssetsDAO.getTicketAssetLinks(keyword);
        } catch (Exception e) {
            e.printStackTrace();
            ticketCiLinkList = Collections.emptyList();
            request.setAttribute("errorMessage", "Cannot load Ticket - CI link list: " + e.getMessage());
        }

        request.setAttribute("keyword", keyword);
        request.setAttribute("ticketCiLinkList", ticketCiLinkList);
        request.getRequestDispatcher("/TicketLinkCIList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (!"delete".equalsIgnoreCase(action)) {
            doGet(request, response);
            return;
        }

        String ticketIdStr = request.getParameter("ticketId");
        String assetIdStr = request.getParameter("assetId");
        String keyword = request.getParameter("keyword");
        String keywordQuery = (keyword == null || keyword.trim().isEmpty())
                ? ""
                : "&keyword=" + java.net.URLEncoder.encode(keyword.trim(), java.nio.charset.StandardCharsets.UTF_8);

        int ticketId;
        int assetId;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
            assetId = Integer.parseInt(assetIdStr);
        } catch (Exception e) {
            response.sendRedirect("TicketLinkCIListServlet?errorMessage=Invalid+link+id" + keywordQuery);
            return;
        }

        boolean removed = ticketAssetsDAO.removeLink(ticketId, assetId);
        if (removed) {
            response.sendRedirect("TicketLinkCIListServlet?successMessage=Delete+successfull" + keywordQuery);
        } else {
            response.sendRedirect("TicketLinkCIListServlet?errorMessage=Delete+failed" + keywordQuery);
        }
    }

    @Override
    public String getServletInfo() {
        return "List/search Ticket - CI links";
    }
}
