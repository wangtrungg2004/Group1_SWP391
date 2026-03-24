package controller;

import model.KnowledgeArticles;
import model.Category;
import dao.KnowledgeArticleDAO;
import dao.CategoryDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "KnowledgeArticleManageServlet", urlPatterns = { "/KnowledgeArticleManage" })
public class KnowledgeArticleManageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String category = request.getParameter("category");
        
        KnowledgeArticleDAO dao = new KnowledgeArticleDAO();
        List<KnowledgeArticles> articles = dao.getFilteredArticles(keyword, status);
        
        CategoryDao categoryDao = new CategoryDao();
        List<Category> categories = categoryDao.getAllCategories();
        Map<Integer, String> categoryMap = new HashMap<>();
        for (Category c : categories) {
            categoryMap.put(c.getId(), c.getName());
        }
        
        if (category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category.trim())) {
            String selectedCategory = category.trim();
            List<KnowledgeArticles> filteredByCategory = new java.util.ArrayList<>();
            for (KnowledgeArticles a : articles) {
                Integer categoryId = a.getCategoryId();
                if (categoryId == null) {
                    continue;
                }
                String categoryName = categoryMap.get(categoryId);
                if (selectedCategory.equals(categoryName)) {
                    filteredByCategory.add(a);
                }
            }
            articles = filteredByCategory;
        }
        
        request.setAttribute("articles", articles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("category", category);
        request.setAttribute("categoryMap", categoryMap);
        
        request.getRequestDispatcher("/KnowledgeArticleManage.jsp").forward(request, response);
    }
}
