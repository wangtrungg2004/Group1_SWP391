package controller;

import dao.TicketAssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "TicketUnlinkCIServlet", urlPatterns = {"/TicketUnlinkCIServlet"})
public class TicketUnlinkCIServlet extends HttpServlet {

    private TicketAssetsDAO ticketAssetsDAO;

    /** Đường dẫn trong context (bắt đầu bằng /), không chứa .. — dùng cho redirect sau khi link thành công. */
    private static String safeRedirectPath(String raw) {
        if (raw == null) {
            return null;
        }
        String r = raw.trim();
        if (r.isEmpty() || !r.startsWith("/") || r.contains("..")) {
            return null;
        }
        return r;
    }

    private void sendErrorRedirect(HttpServletResponse response, String contextPath, String message, String redirectAfter) throws IOException {
        String msg = URLEncoder.encode(message, StandardCharsets.UTF_8);
        if (redirectAfter != null) {
            response.sendRedirect(contextPath + redirectAfter + (redirectAfter.contains("?") ? "&" : "?") + "errorMessage=" + msg);
        } else {
            response.sendRedirect(contextPath + "/Long_TicketListServlet?errorMessage=" + msg);
        }
    }

    @Override
    public void init() throws ServletException {
        super.init();
        ticketAssetsDAO = new TicketAssetsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String ticketIdStr = request.getParameter("ticketId");
        String assetIdStr = request.getParameter("assetId");
        String redirectAfter = safeRedirectPath(request.getParameter("redirect"));
        String ctx = request.getContextPath();

        int ticketId = 0;
        int assetId = 0;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
            assetId = Integer.parseInt(assetIdStr);
        } catch (NumberFormatException e) {
            sendErrorRedirect(response, ctx, "Invalid ticketId or assetId", redirectAfter);
            return;
        }

        boolean success = ticketAssetsDAO.removeLink(ticketId, assetId);

        if (success) {
            String okMsg = URLEncoder.encode("Unlinked asset successfully", StandardCharsets.UTF_8);
            if (redirectAfter != null) {
                response.sendRedirect(ctx + redirectAfter + (redirectAfter.contains("?") ? "&" : "?") + "successMessage=" + okMsg);
            } else {
                response.sendRedirect(ctx + "/Long_TicketListServlet?successMessage=" + okMsg);
            }
        } else {
            sendErrorRedirect(response, ctx, "Failed to unlink asset", redirectAfter);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

