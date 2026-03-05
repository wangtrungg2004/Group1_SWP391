package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.SharedFile;
import model.Users;
import service.SharedFileService;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet(name = "SharedFileUploadServlet", urlPatterns = { "/files/upload" })
@MultipartConfig
public class SharedFileUploadServlet extends HttpServlet {

    private final SharedFileService sharedFileService = new SharedFileService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Users user = (Users) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        request.getRequestDispatcher("/FileUpload.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users user = (Users) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Bạn cần đăng nhập");
            return;
        }

        Part filePart = null;
        for (Part p : request.getParts()) {
            if (p.getName().equals("file")) {
                filePart = p;
                break;
            }
        }

        if (filePart == null || filePart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Không có file upload");
            return;
        }

        try {
            SharedFile saved = sharedFileService.saveUploadedPart(filePart, user.getId(), getServletContext());
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                String fileUrl = request.getContextPath() + saved.getStoragePath();
                out.print("{\"fileId\":" + saved.getId()
                        + ",\"originalName\":\"" + escape(saved.getOriginalName()) + "\""
                        + ",\"path\":\"" + escape(saved.getStoragePath()) + "\""
                        + ",\"url\":\"" + escape(fileUrl) + "\"}");
            }
        } catch (SQLException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi lưu DB: " + e.getMessage());
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        }
    }

    private String escape(String val) {
        return val.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
