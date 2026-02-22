/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Department;
import service.DepartmentService;
import service.LocationService;

/**
 * Servlet để Admin quản lý Departments
 * 
 * @author DELL
 */
@WebServlet(name = "ManageDepartments", urlPatterns = {"/ManageDepartments"})
public class ManageDepartments extends HttpServlet {

    DepartmentService departmentService = new DepartmentService();
    LocationService locationService = new LocationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Kiểm tra quyền Admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }
        
        request.setAttribute("departments", departmentService.getAllDepartments());
        request.setAttribute("locations", locationService.getAllLocations());
        request.getRequestDispatcher("ManageDepartments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Kiểm tra quyền Admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if ("create".equals(action)) {
                // Tạo department mới
                String name = request.getParameter("name");
                String locationIdStr = request.getParameter("locationId");
                String categoryIdStr = request.getParameter("categoryId");
                String managerIdStr = request.getParameter("managerId");
                String isActiveStr = request.getParameter("isActive");
                
                if (name == null || name.trim().isEmpty()) {
                    request.setAttribute("error", "Tên department không được để trống.");
                    request.setAttribute("departments", departmentService.getAllDepartments());
                    request.setAttribute("locations", locationService.getAllLocations());
                    request.getRequestDispatcher("ManageDepartments.jsp").forward(request, response);
                    return;
                }
                
                Department newDept = new Department();
                newDept.setName(name.trim());
                
                // Xử lý LocationId - bắt buộc phải có
                if (locationIdStr != null && !locationIdStr.trim().isEmpty()) {
                    try {
                        int locId = Integer.parseInt(locationIdStr.trim());
                        if (locId > 0) {
                            newDept.setLocationId(locId);
                        } else {
                            request.setAttribute("error", "Vui lòng chọn địa điểm.");
                            request.setAttribute("departments", departmentService.getAllDepartments());
                            request.setAttribute("locations", locationService.getAllLocations());
                            request.getRequestDispatcher("ManageDepartments.jsp").forward(request, response);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("error", "Địa điểm không hợp lệ.");
                        request.setAttribute("departments", departmentService.getAllDepartments());
                        request.setAttribute("locations", locationService.getAllLocations());
                        request.getRequestDispatcher("ManageDepartments.jsp").forward(request, response);
                        return;
                    }
                } else {
                    // LocationId là bắt buộc - sẽ được xử lý trong DAO (lấy LocationId đầu tiên)
                    newDept.setLocationId(null);
                }
                
                // Xử lý CategoryId
                if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                    try {
                        newDept.setCategoryId(Integer.parseInt(categoryIdStr.trim()));
                    } catch (NumberFormatException e) {
                        newDept.setCategoryId(null);
                    }
                } else {
                    newDept.setCategoryId(null);
                }
                
                // Xử lý ManagerId
                if (managerIdStr != null && !managerIdStr.trim().isEmpty()) {
                    try {
                        newDept.setManagerId(Integer.parseInt(managerIdStr.trim()));
                    } catch (NumberFormatException e) {
                        newDept.setManagerId(null);
                    }
                } else {
                    newDept.setManagerId(null);
                }
                
                newDept.IsActive(isActiveStr == null || "true".equals(isActiveStr));
                
                boolean success = departmentService.createDepartment(newDept);
                
                if (success) {
                    request.setAttribute("success", "Tạo department '" + name.trim() + "' thành công!");
                } else {
                    request.setAttribute("error", "Tạo department thất bại. Tên department có thể đã tồn tại.");
                }
            }
            
            // Lấy lại danh sách departments và locations
            request.setAttribute("departments", departmentService.getAllDepartments());
            request.setAttribute("locations", locationService.getAllLocations());
            request.getRequestDispatcher("ManageDepartments.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error managing departments: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.setAttribute("departments", departmentService.getAllDepartments());
            request.setAttribute("locations", locationService.getAllLocations());
            request.getRequestDispatcher("ManageDepartments.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Manage Departments Servlet";
    }
}
