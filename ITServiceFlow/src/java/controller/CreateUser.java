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
import model.Users;
import service.UserService;
import service.DepartmentService;
import service.LocationService;

/**
 * Servlet để Admin tạo user mới
 * 
 * @author DELL
 */
@WebServlet(name = "CreateUser", urlPatterns = {"/CreateUser"})
public class CreateUser extends HttpServlet {

    UserService userService = new UserService();
    DepartmentService departmentService = new DepartmentService();
    LocationService locationService = new LocationService();

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
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }
        request.setAttribute("departments", departmentService.getAllDepartments());
        request.setAttribute("locations", locationService.getAllLocations());
        request.getRequestDispatcher("CreateUser.jsp").forward(request, response);
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
            // Lấy thông tin từ form
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String userRole = request.getParameter("role");
            String departmentIdStr = request.getParameter("departmentId");
            String locationIdStr = request.getParameter("locationId");
            
            // Validate dữ liệu
            if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                userRole == null || userRole.trim().isEmpty()) {
                
                request.setAttribute("error", "Vui lòng điền đầy đủ thông tin bắt buộc.");
                request.setAttribute("departments", departmentService.getAllDepartments());
                request.setAttribute("locations", locationService.getAllLocations());
                request.getRequestDispatcher("CreateUser.jsp").forward(request, response);
                return;
            }
            
            // Tạo user object
            Users newUser = new Users();
            newUser.setUsername(username.trim());
            newUser.setEmail(email.trim());
            newUser.setPasswordHash(password.trim());
            newUser.setFullName(fullName.trim());
            newUser.setRole(userRole.trim());
            
            // Xử lý DepartmentId
            if (departmentIdStr != null && !departmentIdStr.trim().isEmpty()) {
                try {
                    int deptId = Integer.parseInt(departmentIdStr.trim());
                    newUser.setDepartmentId(deptId);
                } catch (NumberFormatException e) {
                    newUser.setDepartmentId(0);
                }
            } else {
                newUser.setDepartmentId(0);
            }
            
            // Xử lý LocationId
            if (locationIdStr != null && !locationIdStr.trim().isEmpty()) {
                try {
                    int locId = Integer.parseInt(locationIdStr.trim());
                    newUser.setLocationId(locId);
                } catch (NumberFormatException e) {
                    newUser.setLocationId(0);
                }
            } else {
                newUser.setLocationId(0);
            }
            
            newUser.IsActive(true); // User mới luôn active
            
            // Kiểm tra username đã tồn tại chưa trước khi tạo
            if (userService.usernameExists(username.trim())) {
                request.setAttribute("error", "Username '" + username.trim() + "' đã tồn tại. Vui lòng chọn username khác.");
                // Giữ lại các giá trị đã nhập
                request.setAttribute("username", username.trim());
                request.setAttribute("email", email.trim());
                request.setAttribute("fullName", fullName.trim());
                request.setAttribute("role", userRole.trim());
                request.setAttribute("departmentId", departmentIdStr);
                request.setAttribute("locationId", locationIdStr);
                request.setAttribute("departments", departmentService.getAllDepartments());
                request.setAttribute("locations", locationService.getAllLocations());
                request.getRequestDispatcher("CreateUser.jsp").forward(request, response);
                return;
            }

            // Kiểm tra email đã tồn tại chưa trước khi tạo
            if (userService.emailExists(email.trim())) {
                request.setAttribute("error", "Email '" + email.trim() + "' đã được sử dụng. Vui lòng dùng email khác.");
                request.setAttribute("username", username.trim());
                request.setAttribute("email", email.trim());
                request.setAttribute("fullName", fullName.trim());
                request.setAttribute("role", userRole.trim());
                request.setAttribute("departmentId", departmentIdStr);
                request.setAttribute("locationId", locationIdStr);
                request.setAttribute("departments", departmentService.getAllDepartments());
                request.setAttribute("locations", locationService.getAllLocations());
                request.getRequestDispatcher("CreateUser.jsp").forward(request, response);
                return;
            }
            
            // Tạo user
            boolean success = userService.createUser(newUser);
            
            if (success) {
                request.setAttribute("success", "Tạo user '" + username.trim() + "' thành công!");
                // Xóa form sau khi tạo thành công
            } else {
                request.setAttribute("error", "Tạo user thất bại. Username/Email có thể đã tồn tại hoặc có lỗi kết nối database. Vui lòng thử lại.");
                // Giữ lại các giá trị đã nhập
                request.setAttribute("username", username.trim());
                request.setAttribute("email", email.trim());
                request.setAttribute("fullName", fullName.trim());
                request.setAttribute("role", userRole.trim());
                request.setAttribute("departmentId", departmentIdStr);
                request.setAttribute("locationId", locationIdStr);
            }
            request.setAttribute("departments", departmentService.getAllDepartments());
            request.setAttribute("locations", locationService.getAllLocations());
            request.getRequestDispatcher("CreateUser.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();
            String errorMsg = "Có lỗi xảy ra khi tạo user.";
            if (e.getMessage() != null) {
                errorMsg += " Chi tiết: " + e.getMessage();
            }
            request.setAttribute("error", errorMsg);
            request.setAttribute("departments", departmentService.getAllDepartments());
            request.setAttribute("locations", locationService.getAllLocations());
            request.getRequestDispatcher("CreateUser.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Create User Servlet";
    }
}
