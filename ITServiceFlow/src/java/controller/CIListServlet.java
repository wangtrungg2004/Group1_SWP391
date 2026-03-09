package controller;

import dao.AssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Assets;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "CIListServlet", urlPatterns = {"/CIListServlet"})
public class CIListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private AssetsDAO assetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        assetsDAO = new AssetsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String keywordParam  = request.getParameter("keyword");
        String statusParam   = request.getParameter("status");
        String pageStr       = request.getParameter("page");

        String keyword = (keywordParam == null) ? "" : keywordParam.trim();

        String statusForDAO = (statusParam == null
                || statusParam.trim().isEmpty()
                || "all".equalsIgnoreCase(statusParam.trim()))
                ? null
                : statusParam.trim();

        String statusForJSP = (statusForDAO == null) ? "all" : statusForDAO;


        // Page number
        int currentPage = 1;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageStr.trim());
            } catch (NumberFormatException ex) {
                currentPage = 1;
            }
        }
        if (currentPage < 1) currentPage = 1;

        List<Assets> fullList;
        try {
            boolean hasKeyword     = !keyword.isBlank();
            boolean hasStatusFilter = (statusForDAO != null);

            if (!hasKeyword && !hasStatusFilter) {
                fullList = assetsDAO.getAllAssets();
            } else {
                fullList = assetsDAO.searchAssets(keyword, "all", statusForDAO);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error querying CI list: " + e.getMessage());
            fullList = Collections.emptyList();
        }

        // ── 3. In-memory pagination ────────────────────────────────────────────
        int totalItems = fullList.size();
        int totalPages = (totalItems == 0) ? 1 : (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (currentPage > totalPages) currentPage = totalPages;

        int fromIndex = (currentPage - 1) * PAGE_SIZE;
        int toIndex   = Math.min(fromIndex + PAGE_SIZE, totalItems);
        List<Assets> pageList = (totalItems == 0)
                ? Collections.emptyList()
                : fullList.subList(fromIndex, toIndex);

        
        request.setAttribute("ciList",      pageList);
        request.setAttribute("keyword",     keyword);
        request.setAttribute("status",      statusForJSP);
        request.setAttribute("totalItems",  totalItems);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages",  totalPages);
        request.getRequestDispatcher("/CIList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}