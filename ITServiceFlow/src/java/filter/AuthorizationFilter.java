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
import java.util.Set;

/**
 *
 * @author DELL
 */
@WebFilter(
    filterName = "AuthorizationFilter",
    urlPatterns = {
        "/AdminDashboard.jsp", "/ManagerDashboard.jsp", "/UserDashboard.jsp", "/ITDashboard.jsp",
        "/ProblemList", "/ProblemAdd", "/ProblemUpdate", "/ProblemDetail", "/ITProblemListController",
        "/UserCreate",
        "/ProblemList.jsp", "/ProblemAdd.jsp", "/ProblemUpdate.jsp", "/ProblemDetail.jsp", "/ITSupportProblemList.jsp",
        "/UserCreate.jsp",
        "/admin/*", "/user/*", "/it/*"
    }
)
public class AuthorizationFilter implements Filter {

    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/Login", "/Login.jsp", "/Logout",
            "/ForgotPassword", "/ForgotPassword.jsp",
            "/ResetPassword", "/ResetPassword.jsp",
            "/GoogleLogin"
    );
    
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
        if (PUBLIC_PATHS.contains(path)) {
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
        
        // Admin toàn quyền
        if ("Admin".equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        // Phân quyền theo role cho các path còn lại
        boolean hasAccess = hasAccessByRole(role, path);
        
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

    private boolean hasAccessByRole(String role, String path) {
        switch (role) {
            case "Manager":
                return path.equals("/ManagerDashboard.jsp")
                        || path.equals("/UserDashboard.jsp")
                        || path.equals("/ProblemList")
                        || path.equals("/ProblemAdd")
                        || path.equals("/ProblemUpdate")
                        || path.equals("/ProblemDetail")
                        || path.equals("/ProblemList.jsp")
                        || path.equals("/ProblemAdd.jsp")
                        || path.equals("/ProblemUpdate.jsp")
                        || path.equals("/ProblemDetail.jsp")
                        || path.startsWith("/user/");
            case "User":
                return path.equals("/UserDashboard.jsp")
                        || path.equals("/ProblemList")
                        || path.equals("/ProblemDetail")
                        || path.equals("/ProblemList.jsp")
                        || path.equals("/ProblemDetail.jsp")
                        || path.startsWith("/user/");
            case "IT Support":
                return path.equals("/ITDashboard.jsp")
                        || path.equals("/ITProblemListController")
                        || path.equals("/ProblemDetail")
                        || path.equals("/ProblemUpdate")
                        || path.equals("/ITSupportProblemList.jsp")
                        || path.equals("/ProblemDetail.jsp")
                        || path.equals("/ProblemUpdate.jsp")
                        || path.startsWith("/it/");
            default:
                return false;
        }
    }
}
