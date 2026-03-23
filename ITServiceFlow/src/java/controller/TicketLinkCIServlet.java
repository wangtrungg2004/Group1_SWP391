package controller;

import dao.AssetsDAO;
import dao.TicketAssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import model.Assets;

@WebServlet(name = "TicketLinkCIServlet", urlPatterns = {"/TicketLinkCIServlet"})
public class TicketLinkCIServlet extends HttpServlet {

    private TicketAssetsDAO ticketAssetsDAO;
    private AssetsDAO assetsDAO;

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

    private void sendErrorRedirect(HttpServletResponse response, String contextPath, String message) throws IOException {
        String msg = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(contextPath + "/Long_TicketListServlet?errorMessage=" + msg);
    }

    @Override
    public void init() throws ServletException {
        super.init();
        ticketAssetsDAO = new TicketAssetsDAO();
        assetsDAO = new AssetsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String ticketIdStr = request.getParameter("ticketId");
        String assetTag = request.getParameter("assetTag");
        String redirectAfter = safeRedirectPath(request.getParameter("redirect"));
        String ctx = request.getContextPath();

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
        } catch (Exception e) {
            sendErrorRedirect(response, ctx, "Invalid ticketId");
            return;
        }

        if (assetTag == null || assetTag.trim().isEmpty()) {
            sendErrorRedirect(response, ctx, "Asset tag is required");
            return;
        }

        Assets asset = assetsDAO.getAssetByTag(assetTag.trim());
        if (asset == null) {
            sendErrorRedirect(response, ctx, "Asset not found");
            return;
        }

        boolean success = ticketAssetsDAO.addLink(ticketId, asset.getId());
        if (success) {
            String okMsg = URLEncoder.encode("Linked asset successfully", StandardCharsets.UTF_8);
            if (redirectAfter != null) {
                response.sendRedirect(ctx + redirectAfter + "?successMessage=" + okMsg);
            } else {
                response.sendRedirect(ctx + "/Long_TicketListServlet?successMessage=" + okMsg);
            }
        } else {
            sendErrorRedirect(response, ctx, "Asset already linked or failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

