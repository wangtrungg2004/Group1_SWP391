package controller;

import Utils.GoogleAuthUtil;
import Utils.GoogleAuthUtil.GoogleUserInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Users;
import service.TemporaryRoleAccessService;
import service.UserService;

@WebServlet(name = "GoogleLogin", urlPatterns = {"/GoogleLogin"})
public class GoogleLogin extends HttpServlet {

    private final UserService userService = new UserService();
    private final TemporaryRoleAccessService temporaryRoleAccessService = new TemporaryRoleAccessService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idToken = request.getParameter("credential");
            String clientId = GoogleAuthUtil.getGoogleClientId();

            if (clientId == null || clientId.isBlank()) {
                request.setAttribute("error", "Google login is not configured. Missing GOOGLE_CLIENT_ID.");
                request.setAttribute("googleClientId", "");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }

            GoogleUserInfo info = GoogleAuthUtil.verifyIdToken(idToken, clientId);
            if (info == null) {
                request.setAttribute("error", "Google authentication failed. Please try again.");
                request.setAttribute("googleClientId", clientId);
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }

            Users user = userService.loginWithGoogleEmail(info.getEmail());
            if (user == null) {
                request.setAttribute("error", "No active account linked to this Google email.");
                request.setAttribute("googleClientId", clientId);
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("baseRole", user.getRole());
            session.setAttribute("effectiveRole", user.getRole());
            session.setAttribute("role", user.getRole());
            session.setAttribute("userId", user.getId());
            session.setAttribute(TemporaryRoleAccessService.SESSION_TEMP_ROLE_ACTIVATED, false);
            temporaryRoleAccessService.synchronizeSessionRole(session);
            redirectByRole(user.getRole(), request, response);
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Google login error. Please contact administrator.");
            request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
            request.getRequestDispatcher("Login.jsp").forward(request, response);
        }
    }

    private void redirectByRole(String role, HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        if (role == null) {
            request.setAttribute("error", "Cannot determine role. Please login again.");
            request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
            request.getRequestDispatcher("Login.jsp").forward(request, response);
            return;
        }

        switch (role) {
            case "Admin":
                response.sendRedirect(request.getContextPath() + "/AdminDashboard");
                break;
            case "Manager":
                response.sendRedirect(request.getContextPath() + "/ManagerDashboard");
                break;
            case "User":
                response.sendRedirect(request.getContextPath() + "/UserDashboard");
                break;
            case "IT Support":
                response.sendRedirect(request.getContextPath() + "/ITDashboard");
                break;
            default:
                request.setAttribute("error", "Invalid role. Please contact administrator.");
                request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                break;
        }
    }
}
