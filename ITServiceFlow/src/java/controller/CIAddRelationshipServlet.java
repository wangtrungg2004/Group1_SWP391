package controller;

import dao.CIRelationshipsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.CIRelationships;

@WebServlet(name = "CIAddRelationshipServlet", urlPatterns = {"/CIAddRelationshipServlet"})
public class CIAddRelationshipServlet extends HttpServlet {

    private CIRelationshipsDAO ciRelationshipsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ciRelationshipsDAO = new CIRelationshipsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String sourceIdStr = request.getParameter("sourceCIId");
        String targetIdStr = request.getParameter("targetCIId");
        String relationshipType = request.getParameter("relationshipType");
        String description = request.getParameter("description");

        int sourceId;
        int targetId;
        try {
            sourceId = Integer.parseInt(sourceIdStr);
            targetId = Integer.parseInt(targetIdStr);
        } catch (Exception e) {
            response.sendRedirect("CIListServlet");
            return;
        }

        if (sourceId == targetId) {
            response.sendRedirect("CIDetailServlet?id=" + sourceId + "&errorMessage=Cannot+relate+CI+to+itself");
            return;
        }

        if (relationshipType == null || relationshipType.trim().isEmpty()) {
            response.sendRedirect("CIDetailServlet?id=" + sourceId + "&errorMessage=Relationship+type+is+required");
            return;
        }

        if (ciRelationshipsDAO.existsRelationship(sourceId, targetId, relationshipType.trim())) {
            response.sendRedirect("CIDetailServlet?id=" + sourceId + "&errorMessage=Relationship+already+exists");
            return;
        }

        CIRelationships rel = new CIRelationships();
        rel.setSourceCIId(sourceId);
        rel.setTargetCIId(targetId);
        rel.setRelationshipType(relationshipType.trim());
        rel.setDescription(description != null ? description.trim() : null);

        boolean ok = ciRelationshipsDAO.addRelationship(rel);
        if (ok) {
            response.sendRedirect("CIDetailServlet?id=" + sourceId + "&successMessage=Relationship+added");
        } else {
            response.sendRedirect("CIDetailServlet?id=" + sourceId + "&errorMessage=Add+relationship+failed");
        }
    }
}

