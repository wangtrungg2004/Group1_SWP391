package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicLong;
import service.SLATrackingService;

public class SLAEscalationFilter implements Filter {

    private static final long MIN_INTERVAL_MS = 60_000L;
    private static final AtomicLong LAST_RUN_AT = new AtomicLong(0L);
    private static final Object RUN_LOCK = new Object();

    private final SLATrackingService slaTrackingService = new SLATrackingService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // no-op
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String path = resolvePath(httpRequest);
        if (!isIgnoredPath(path)) {
            runSweepIfDue();
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }

    private void runSweepIfDue() {
        long now = System.currentTimeMillis();
        long last = LAST_RUN_AT.get();
        if (now - last < MIN_INTERVAL_MS) {
            return;
        }

        synchronized (RUN_LOCK) {
            long recheck = LAST_RUN_AT.get();
            long current = System.currentTimeMillis();
            if (current - recheck < MIN_INTERVAL_MS) {
                return;
            }
            try {
                slaTrackingService.runEscalationSweep();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            LAST_RUN_AT.set(System.currentTimeMillis());
        }
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
