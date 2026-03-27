package controller;

import dao.AssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Assets;

import java.io.IOException;

@WebServlet(name = "CIAddServlet", urlPatterns = {"/CIAddServlet"})
public class CIAddServlet extends HttpServlet {

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
        
        String assetTag = request.getParameter("assetTag");
        String name = request.getParameter("name");
        String assetType = request.getParameter("assetType");
        String locationIdStr = request.getParameter("locationId");
        String ownerIdStr = request.getParameter("ownerId");
        String status = "Active"; // Default status

        HttpSession session = request.getSession();

        if (assetTag == null || assetTag.trim().isEmpty() || name == null || name.trim().isEmpty()) {
            session.setAttribute("message", "Asset Tag and Name are required.");
            session.setAttribute("messageType", "danger");
            response.sendRedirect("CIListServlet");
            return;
        }

        try {
            Assets asset = new Assets();
            asset.setAssetTag(assetTag.trim());
            asset.setName(name.trim());
            asset.setAssetType(assetType);
            asset.setStatus(status);
            
            if (locationIdStr != null && !locationIdStr.isEmpty()) {
                asset.setLocationId(Integer.parseInt(locationIdStr));
            }
            
            if (ownerIdStr != null && !ownerIdStr.isEmpty()) {
                asset.setOwnerId(Integer.parseInt(ownerIdStr));
            }

            boolean success = assetsDAO.addAsset(asset);
            if (success) {
                session.setAttribute("message", "Configuration Item added successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Failed to add Configuration Item. Asset Tag might already exist.");
                session.setAttribute("messageType", "danger");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "danger");
        }

        response.sendRedirect("CIListServlet");
    }
}
