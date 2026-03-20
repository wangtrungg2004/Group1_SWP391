package controller;

import dao.AssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Assets;

import java.io.IOException;

@WebServlet(name = "CIUpdateServlet", urlPatterns = {"/CIUpdateServlet"})
public class CIUpdateServlet extends HttpServlet {

    private AssetsDAO assetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        assetsDAO = new AssetsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("CIListServlet");
            return;
        }

        int ciId;
        try {
            ciId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("CIListServlet");
            return;
        }

        Assets ci = assetsDAO.getAssetById(ciId);
        if (ci == null) {
            response.sendRedirect("CIListServlet");
            return;
        }

        String name = request.getParameter("name");
        String assetType = request.getParameter("assetType");
        String status = request.getParameter("status");
        String locationIdStr = request.getParameter("locationId");
        String ownerIdStr = request.getParameter("ownerId");

        if (name != null && !name.trim().isEmpty()) {
            ci.setName(name.trim());
        }
        if (assetType != null && !assetType.trim().isEmpty()) {
            ci.setAssetType(assetType.trim());
        }
        if (status != null && !status.trim().isEmpty()) {
            ci.setStatus(status.trim());
        }

        if (locationIdStr != null && !locationIdStr.trim().isEmpty()) {
            try {
                ci.setLocationId(Integer.parseInt(locationIdStr.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try {
                ci.setOwnerId(Integer.parseInt(ownerIdStr.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        assetsDAO.updateAsset(ci);
        response.sendRedirect("CIDetailServlet?id=" + ciId);
    }
}

