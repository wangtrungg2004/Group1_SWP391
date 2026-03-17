/*
 * Update Known Error - only Title and WorkAround.
 */
package controller.KnowErrors;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.KnowErrors;
import service.AuditLogService;
import service.KnowErrorService;

@WebServlet(name = "KnowErrorUpdate", urlPatterns = {"/KnowErrorUpdate"})
public class KnowErrorUpdate extends HttpServlet {

    KnowErrorService knowErrorService = new KnowErrorService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("Id");
        
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("KnowErrorList?error=missing_id");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            
            KnowErrors knowError = knowErrorService.getKnowErrorById(id);
            if (knowError == null) {
                response.sendRedirect("KnowErrorList?error=not_found");
                return;
            }
            request.setAttribute("knowError", knowError);
            request.getRequestDispatcher("KnowErrorUpdate.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("KnowErrorList?error=invalid_id");
        }
    }
    AuditLogService auditLogService = new AuditLogService();
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        request.setCharacterEncoding("UTF-8");
        String idParam = request.getParameter("Id");
        String title = request.getParameter("Title");
        String workAround = request.getParameter("WorkAround");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("KnowErrorList?error=missing_id");
            return;
        }
        if (title == null) title = "";
        if (workAround == null) workAround = "";

        try {
            int id = Integer.parseInt(idParam);
            KnowErrors knowError = knowErrorService.getKnowErrorById(id);
            if (knowError == null) {
                response.sendRedirect("KnowErrorList?error=not_found");
                return;
            }
            boolean success = knowErrorService.updateKnowError(id, title.trim(), workAround.trim());
            if (success) {
               
                if (userId != null) {
                    auditLogService.createAuditLog(userId, "UPDATE", "KnowError", id);
                }
                response.sendRedirect("KnowErrorDetail?Id=" + id);
            } else {
                request.setAttribute("error", "Update failed.");
                request.setAttribute("knowError", knowError);
                request.getRequestDispatcher("KnowErrorUpdate.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("KnowErrorList?error=invalid_id");
        }
    }
}
