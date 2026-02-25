package controller;

import dao.AssetsDAO;
import dao.CIRelationshipsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Assets;
import model.CIRelationships;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "CIRelationshipMapServlet", urlPatterns = {"/CIRelationshipMapServlet"})
public class CIRelationshipMapServlet extends HttpServlet {

    private AssetsDAO assetsDAO;
    private CIRelationshipsDAO ciRelationshipsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        assetsDAO = new AssetsDAO();
        ciRelationshipsDAO = new CIRelationshipsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String format = request.getParameter("format");

        if ("json".equals(format)) {
            handleJsonResponse(response, idStr);
        } else {
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int ciId = Integer.parseInt(idStr.trim());
                    Assets rootCI = assetsDAO.getAssetById(ciId);
                    request.setAttribute("rootCI", rootCI);
                } catch (NumberFormatException e) {
                    // Invalid ID, ignore
                }
            }
            request.getRequestDispatcher("/CIRelationshipsMap.jsp").forward(request, response);
        }
    }

    private void handleJsonResponse(HttpServletResponse response, String idStr) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        StringBuilder json = new StringBuilder();
        json.append("[");

        Set<Integer> processedNodes = new HashSet<>();
        Set<String> processedEdges = new HashSet<>();
        boolean firstElement = true;

        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                int rootId = Integer.parseInt(idStr.trim());
                buildDependencyGraph(rootId, json, processedNodes, processedEdges, 2, firstElement);
            } catch (NumberFormatException e) {
                // Invalid ID, return empty array
            }
        } else {
            // Show all CIs and their relationships
            List<Assets> allAssets = assetsDAO.getAllAssets();
            for (Assets asset : allAssets) {
                if (!firstElement) json.append(",");
                addNode(json, asset);
                firstElement = false;
            }
        }

        json.append("]");
        out.print(json.toString());
        out.flush();
    }

    private void buildDependencyGraph(int ciId, StringBuilder json, Set<Integer> processedNodes,
                                       Set<String> processedEdges, int depth, boolean firstElement) {
        if (depth < 0) return;

        Assets asset = assetsDAO.getAssetById(ciId);
        if (asset == null) return;

        // Add the root node
        if (!processedNodes.contains(ciId)) {
            if (!firstElement) json.append(",");
            addNode(json, asset);
            processedNodes.add(ciId);
            firstElement = false;
        }

        if (depth > 0) {
            // Get relationships where this CI is the source (dependencies)
            List<CIRelationships> relationships = ciRelationshipsDAO.getRelationshipsByCIId(ciId);

            for (CIRelationships rel : relationships) {
                int targetId = rel.getTargetCIId();
                int sourceId = rel.getSourceCIId();

                // Add target node if not exists
                Assets targetAsset = assetsDAO.getAssetById(targetId);
                if (targetAsset != null && !processedNodes.contains(targetId)) {
                    json.append(",");
                    addNode(json, targetAsset);
                    processedNodes.add(targetId);
                }

                // Add edge
                String edgeId = "e" + sourceId + "-" + targetId;
                if (!processedEdges.contains(edgeId)) {
                    json.append(",");
                    addEdge(json, rel);
                    processedEdges.add(edgeId);
                }

                // Recursively build for target
                if (targetId != ciId) {
                    buildDependencyGraph(targetId, json, processedNodes, processedEdges, depth - 1, false);
                }
            }
        }
    }

    private void addNode(StringBuilder json, Assets asset) {
        json.append("{\"data\":{");
        json.append("\"id\":\"").append(escapeJson(String.valueOf(asset.getId()))).append("\",");
        json.append("\"label\":\"").append(escapeJson(asset.getName())).append("\",");
        json.append("\"assetTag\":\"").append(escapeJson(asset.getAssetTag())).append("\",");
        json.append("\"type\":\"").append(escapeJson(asset.getAssetType())).append("\",");
        json.append("\"status\":\"").append(escapeJson(asset.getStatus())).append("\"");
        json.append("}}");
    }

    private void addEdge(StringBuilder json, CIRelationships rel) {
        json.append("{\"data\":{");
        json.append("\"id\":\"").append("e").append(rel.getSourceCIId()).append("-").append(rel.getTargetCIId()).append("\",");
        json.append("\"source\":\"").append(rel.getSourceCIId()).append("\",");
        json.append("\"target\":\"").append(rel.getTargetCIId()).append("\",");
        json.append("\"label\":\"").append(escapeJson(rel.getRelationshipType())).append("\"");
        json.append("}}");
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}