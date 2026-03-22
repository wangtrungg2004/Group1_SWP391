package controller;

import model.KnowledgeArticles;
import dao.KnowledgeArticleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "KnowledgeArticleManageServlet", urlPatterns = { "/KnowledgeArticleManage" })
public class KnowledgeArticleManageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        
        KnowledgeArticleDAO dao = new KnowledgeArticleDAO();
        List<KnowledgeArticles> articles = dao.getFilteredArticles(keyword, status);
        
        request.setAttribute("articles", articles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        
        request.getRequestDispatcher("/KnowledgeArticleManage.jsp").forward(request, response);
    }
}
