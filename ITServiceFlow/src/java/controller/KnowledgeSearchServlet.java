package controller;

import dao.KnowledgeArticleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.KnowledgeArticles;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "KnowledgeSearchServlet", urlPatterns = { "/KnowledgeSearch" })
public class KnowledgeSearchServlet extends HttpServlet {

    private KnowledgeArticleDAO dao;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new KnowledgeArticleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Auth check
        Object userObj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("user")
                : null;
        if (userObj == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String keyword = request.getParameter("keyword");
        if (keyword == null)
            keyword = "";

        List<KnowledgeArticles> articleList;
        try {
            articleList = dao.searchArticles(keyword.trim());
        } catch (Exception e) {
            e.printStackTrace();
            articleList = Collections.emptyList();
            request.setAttribute("errorMessage", "Lỗi khi tìm kiếm bài viết: " + e.getMessage());
        }

        request.setAttribute("articleList", articleList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("totalResults", articleList.size());

        request.getRequestDispatcher("/KnowledgeSearch.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
