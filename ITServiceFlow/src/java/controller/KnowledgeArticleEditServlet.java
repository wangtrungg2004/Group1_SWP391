package controller;

import dao.KnowledgeArticleDAO;
import dao.KnowledgeAttachmentDAO;
import dao.SharedFileDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.KnowledgeArticles;
import model.KnowledgeAttachment;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet(name = "KnowledgeArticleEditServlet", urlPatterns = { "/KnowledgeArticleEdit" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 15,      // 15MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class KnowledgeArticleEditServlet extends HttpServlet {

    private KnowledgeArticleDAO dao;
    private KnowledgeAttachmentDAO attachmentDAO;
    private SharedFileDAO fileDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new KnowledgeArticleDAO();
        attachmentDAO = new KnowledgeAttachmentDAO();
        fileDAO = new SharedFileDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("KnowledgeArticleManage");
            return;
        }

        try {
            int id = Integer.parseInt(idStr.trim());
            KnowledgeArticles article = dao.getArticleById(id);
            if (article != null) {
                article.setAttachments(attachmentDAO.listFilesByArticle(id));
                request.setAttribute("article", article);
                request.getRequestDispatcher("/KnowledgeArticleEdit.jsp").forward(request, response);
            } else {
                response.sendRedirect("KnowledgeArticleManage");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("KnowledgeArticleManage");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String status = request.getParameter("status");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("KnowledgeArticleManage");
            return;
        }

        try {
            int id = Integer.parseInt(idStr.trim());
            boolean updated = dao.updateArticle(id, title, content, status);

            if (updated) {
                // Handle file upload
                Part filePart = request.getPart("newAttachment");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdir();

                    String storedName = UUID.randomUUID().toString() + "_" + fileName;
                    String filePath = uploadPath + File.separator + storedName;
                    filePart.write(filePath);

                    // Register in SharedFiles
                    Object userObj = request.getSession().getAttribute("user");
                    int userId = (userObj != null) ? 1 : 1; // Fallback to 1 for now if user extraction is complex

                    int fileId = fileDAO.addFile(fileName, storedName, filePart.getContentType(), filePart.getSize(), "uploads/" + storedName, userId);
                    
                    // Link to knowledge article
                    if (fileId > 0) {
                        KnowledgeAttachment att = new KnowledgeAttachment();
                        att.setArticleId(id);
                        att.setFileId(fileId);
                        att.setAddedBy(userId);
                        attachmentDAO.add(att);
                    }
                }
                request.setAttribute("successMessage", "Đã cập nhật bài viết thành công!");
            } else {
                request.setAttribute("errorMessage", "Cập nhật thất bại.");
            }
            
            // Reload article for the form
            KnowledgeArticles article = dao.getArticleById(id);
            article.setAttachments(attachmentDAO.listFilesByArticle(id));
            request.setAttribute("article", article);
            request.getRequestDispatcher("/KnowledgeArticleEdit.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            request.getRequestDispatcher("/KnowledgeArticleEdit.jsp").forward(request, response);
        }
    }
}
