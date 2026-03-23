package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import service.TemporaryRoleAccessService;

public class TemporaryRoleSyncFilter implements Filter {

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

        String path = resolvePath(httpRequest);
        if (isIgnoredPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            String effectiveRole = temporaryRoleAccessService.synchronizeSessionRole(session);
            if (effectiveRole == null) {
                session.invalidate();
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/Login.jsp");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }

    private String resolvePath(HttpServletRequest request) {
        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (requestUri == null) {
            return "";
        }
        if (contextPath == null || contextPath.isEmpty()) {
            return requestUri;
        }
        return requestUri.substring(contextPath.length());
    }

    private boolean isIgnoredPath(String path) {
        if (path == null || path.isEmpty()) {
            return true;
        }

        String lowerPath = path.toLowerCase();

        if (lowerPath.startsWith("/assets/")
                || lowerPath.startsWith("/web-inf/")
                || lowerPath.startsWith("/meta-inf/")
                || lowerPath.startsWith("/nbproject/")
                || lowerPath.startsWith("/database/")) {
            return true;
        }

        if (lowerPath.equals("/login")
                || lowerPath.equals("/login.jsp")
                || lowerPath.equals("/logout")
                || lowerPath.equals("/forgotpassword")
                || lowerPath.equals("/forgotpassword.jsp")
                || lowerPath.equals("/resetpassword")
                || lowerPath.equals("/resetpassword.jsp")
                || lowerPath.equals("/googlelogin")
                || lowerPath.equals("/index.html")
                || lowerPath.equals("/")) {
            return true;
        }

        if (lowerPath.startsWith("/auth/")) {
            return true;
        }

        return lowerPath.endsWith(".css")
                || lowerPath.endsWith(".js")
                || lowerPath.endsWith(".map")
                || lowerPath.endsWith(".png")
                || lowerPath.endsWith(".jpg")
                || lowerPath.endsWith(".jpeg")
                || lowerPath.endsWith(".gif")
                || lowerPath.endsWith(".svg")
                || lowerPath.endsWith(".woff")
                || lowerPath.endsWith(".woff2")
                || lowerPath.endsWith(".ttf")
                || lowerPath.endsWith(".eot")
                || lowerPath.endsWith(".ico");
    }
}
