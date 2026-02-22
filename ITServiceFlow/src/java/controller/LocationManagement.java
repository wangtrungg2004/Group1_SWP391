package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.LocationService;

import java.io.IOException;

/**
 * Quản lý Locations (địa điểm). Hiển thị danh sách.
 */
@WebServlet(name = "LocationManagement", urlPatterns = {"/LocationManagement"})
public class LocationManagement extends HttpServlet {

    private final LocationService locationService = new LocationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }
        request.setAttribute("locations", locationService.getAllLocations());
        request.getRequestDispatcher("LocationManagement.jsp").forward(request, response);
    }
}
