package filter;

import dao.UserDao;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Users;
import service.TemporaryRoleAccessService;

@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/AdminDashboard.jsp", "/UserDashboard.jsp", "/ITDashboard.jsp", "/ManagerDashboard", "/ManagerDashboard.jsp", "/admin/*", "/user/*", "/it/*"})
public class AuthorizationFilter implements Filter {

    private final TemporaryRoleAccessService temporaryRoleAccessService = new TemporaryRoleAccessService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // no-op
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

        if (path.equals("/Login.jsp") || path.equals("/Login") || path.equals("/Logout")) {
            chain.doFilter(request, response);
            return;
        }

        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        Object userIdObj = session.getAttribute("userId");
        Integer userId = null;
        if (userIdObj instanceof Integer) {
            userId = (Integer) userIdObj;
        } else if (userIdObj instanceof Number) {
            userId = ((Number) userIdObj).intValue();
        }

        if (userId != null) {
            UserDao userDao = new UserDao();
            Users currentUser = userDao.getUserById(userId);
            if (currentUser == null || !currentUser.isActive()) {
                session.invalidate();
                httpResponse.sendRedirect(contextPath + "/Login.jsp");
                return;
            }
        }

        String role = temporaryRoleAccessService.synchronizeSessionRole(session);
        if (role == null) {
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        boolean hasAccess;
        if (path.contains("AdminDashboard") || path.startsWith("/admin/")) {
            hasAccess = "Admin".equals(role);
        } else if (path.contains("UserDashboard") || path.startsWith("/user/")) {
            hasAccess = "Manager".equals(role) || "User".equals(role);
        } else if (path.contains("ITDashboard") || path.startsWith("/it/")) {
            hasAccess = "IT Support".equals(role);
        } else {
            hasAccess = true;
        }

        if (!hasAccess) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Ban khong co quyen truy cap trang nay.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }
}
