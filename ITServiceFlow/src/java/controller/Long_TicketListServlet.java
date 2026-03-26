package controller;

import dao.TicketDao;
import dao.TicketAssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;
import model.Tickets;
import model.Assets;

@WebServlet(name = "Long_TicketListServlet", urlPatterns = {"/Long_TicketListServlet", "/TicketList"})
public class Long_TicketListServlet extends HttpServlet {

    private TicketDao ticketDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketDAO = new TicketDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String keywordParam = request.getParameter("keyword");
        String typeParam = request.getParameter("type");
        String statusParam = request.getParameter("status");
        String priorityParam = request.getParameter("priority");

        String keyword = (keywordParam == null) ? "" : keywordParam.trim();
        String type = (typeParam == null || typeParam.trim().isEmpty()) ? "all" : typeParam.trim();
        String status = (statusParam == null || statusParam.trim().isEmpty()) ? "all" : statusParam.trim();
        String priority = (priorityParam == null || priorityParam.trim().isEmpty()) ? "all" : priorityParam.trim();

        List<Tickets> allTickets;
        try {
            allTickets = ticketDAO.getAllTickets();
        } catch (Exception e) {
            e.printStackTrace();
            allTickets = Collections.emptyList();
            request.setAttribute("errorMessage", "Cannot load ticket list: " + e.getMessage());
        }

        List<Tickets> ticketList = applyFilters(allTickets, keyword, type, status, priority);

        // Gắn thông tin Asset (nếu có) cho từng ticket để JSP hiển thị
        TicketAssetsDAO ticketAssetsDAO = new TicketAssetsDAO();
        for (Tickets t : ticketList) {
            List<Assets> linkedAssets = ticketAssetsDAO.getLinkedCIsByTicketId(t.getId());
            t.setLinkedAssets(linkedAssets);
        }

        request.setAttribute("ticketList", ticketList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("type", type);
        request.setAttribute("status", status);
        request.setAttribute("priority", priority);
        request.getRequestDispatcher("/Long_TicketList.jsp").forward(request, response);
    }

    private List<Tickets> applyFilters(List<Tickets> source, String keyword, String type, String status, String priority) {
        if (source == null || source.isEmpty()) {
            return Collections.emptyList();
        }

        final String loweredKeyword = (keyword == null) ? "" : keyword.trim().toLowerCase(Locale.ROOT);
        final boolean hasKeyword = !loweredKeyword.isEmpty();
        final boolean filterAllTypes = (type == null || type.trim().isEmpty() || "all".equalsIgnoreCase(type.trim()));
        final boolean filterAllStatus = (status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status.trim()));
        final boolean filterAllPriority = (priority == null || priority.trim().isEmpty() || "all".equalsIgnoreCase(priority.trim()));

        return source.stream()
                .filter(t -> filterAllTypes || equalsIgnoreCaseSafe(t.getTicketType(), type))
                .filter(t -> filterAllStatus || equalsIgnoreCaseSafe(t.getStatus(), status))
                .filter(t -> filterAllPriority || equalsIgnoreCaseSafe(t.getPriorityLevel(), priority))
                .filter(t -> !hasKeyword || matchesKeyword(t, loweredKeyword))
                .collect(Collectors.toList());
    }

    private boolean matchesKeyword(Tickets ticket, String loweredKeyword) {
        String createdAtText = "";
        if (ticket.getCreatedAt() != null) {
            createdAtText = new SimpleDateFormat("dd/MM/yyyy", Locale.ROOT).format(ticket.getCreatedAt());
        }

        return containsIgnoreCase(ticket.getTicketNumber(), loweredKeyword)
                || containsIgnoreCase(ticket.getTitle(), loweredKeyword)
                || containsIgnoreCase(ticket.getStatus(), loweredKeyword)
                || containsIgnoreCase(ticket.getPriorityLevel(), loweredKeyword)
                || containsIgnoreCase(createdAtText, loweredKeyword);
    }

    private boolean containsIgnoreCase(String source, String loweredKeyword) {
        return source != null && source.toLowerCase(Locale.ROOT).contains(loweredKeyword);
    }

    private boolean equalsIgnoreCaseSafe(String a, String b) {
        return a != null && b != null && a.equalsIgnoreCase(b.trim());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
