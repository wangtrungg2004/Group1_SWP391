package controller;

import dao.KnowledgeArticleDAO;
import dao.KnowledgeAttachmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.KnowledgeArticles;
import model.SharedFile;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "KnowledgeArticleViewServlet", urlPatterns = { "/KnowledgeArticleView" })
public class KnowledgeArticleViewServlet extends HttpServlet {

    private KnowledgeArticleDAO dao;
    private KnowledgeAttachmentDAO attachmentDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new KnowledgeArticleDAO();
        attachmentDAO = new KnowledgeAttachmentDAO();
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

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("KnowledgeSearch");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("KnowledgeSearch");
            return;
        }

        KnowledgeArticles article = dao.getArticleById(id);
        if (article == null) {
            request.setAttribute("errorMessage", "Không tìm thấy bài viết.");
            request.getRequestDispatcher("/KnowledgeSearch.jsp").forward(request, response);
            return;
        }

        try {
            List<SharedFile> attachments = attachmentDAO.listFilesByArticle(id);
            request.setAttribute("attachments", attachments);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Không tải được danh sách đính kèm: " + e.getMessage());
        }

        request.setAttribute("article", article);
        request.getRequestDispatcher("/KnowledgeArticleView.jsp").forward(request, response);
    }
}
