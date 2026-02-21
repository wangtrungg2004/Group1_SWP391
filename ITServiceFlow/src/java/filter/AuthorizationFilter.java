/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 *
 * @author DELL
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/AdminDashboard.jsp", "/UserDashboard.jsp", "/ITDashboard.jsp", "/admin/*", "/user/*", "/it/*"})
public class AuthorizationFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo filter
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        // Cho phép truy cập các trang công khai
        if (path.equals("/Login.jsp") || path.equals("/Login") || path.equals("/Logout")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Kiểm tra đăng nhập
        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(contextPath + "/Login.jsp");
            return;
        }
        
        // Lấy role từ session
        String role = (String) session.getAttribute("role");
        
        if (role == null) {
            httpResponse.sendRedirect(contextPath + "/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập theo role
        boolean hasAccess = false;
        
        if (path.contains("AdminDashboard") || path.startsWith("/admin/")) {
            hasAccess = "Admin".equals(role);
        } else if (path.contains("UserDashboard") || path.startsWith("/user/")) {
            // User có thể là Manager hoặc User thông thường
            hasAccess = "Manager".equals(role) || "User".equals(role);
        } else if (path.contains("ITDashboard") || path.startsWith("/it/")) {
            hasAccess = "IT Support".equals(role);
        } else {
            // Cho phép truy cập các trang khác nếu đã đăng nhập
            hasAccess = true;
        }
        
        if (!hasAccess) {
            // Không có quyền truy cập
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Cleanup
    }
}
