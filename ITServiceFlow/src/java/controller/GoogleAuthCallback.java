/*
 * Google OAuth 2.0 Callback Handler
 */
package controller;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Users;
import service.UserService;
import Utils.GoogleOAuthConfig;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;


/**
 * Handles Google OAuth 2.0 callback
 */
@WebServlet(name = "GoogleAuthCallback", urlPatterns = {"/GoogleAuthCallback"})
public class GoogleAuthCallback extends HttpServlet {
    
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String code = request.getParameter("code");
        String error = request.getParameter("error");
        
        // Check for errors from Google
        if (error != null) {
            request.setAttribute("error", "Google login failed: " + error);
            request.getRequestDispatcher("Login.jsp").forward(request, response);
            return;
        }
        
        // Check if authorization code is provided
        if (code == null || code.isEmpty()) {
            request.setAttribute("error", "No authorization code received from Google");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
            return;
        }
        
        try {
            // Exchange authorization code for access token
            String accessToken = getAccessToken(code);
            
            if (accessToken == null || accessToken.isEmpty()) {
                request.setAttribute("error", "Failed to get access token from Google");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }
            
            // Get user info from Google
            JSONObject userInfo = getUserInfo(accessToken);
            
            if (userInfo == null) {
                request.setAttribute("error", "Failed to get user information from Google");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }
            
            // Extract user information (id may be String or Number from Google)
            Object idObj = userInfo.get("id");
            String googleId = idObj != null ? String.valueOf(idObj) : null;
            String email = (String) userInfo.get("email");
            String name = (String) userInfo.get("name");
            
            if (googleId == null || googleId.isEmpty() || email == null || email.isEmpty()) {
                request.setAttribute("error", "Invalid user information from Google");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }
            // Find or create user in database
            Users user = userService.findOrCreateGoogleUser(googleId, email, name);
            
            if (user == null) {
                request.setAttribute("error", "Failed to create or retrieve user account");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }
            
            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());
            session.setAttribute("googleLogin", true);
            
            // Redirect based on role
            String role = user.getRole();
            if (role != null) {
                switch (role) {
                    case "Admin":
                        response.sendRedirect("AdminDashboard.jsp");
                        break;
                    case "Manager":
                    case "User":
                        response.sendRedirect("UserDashboard.jsp");
                        break;
                    case "IT Support":
                        response.sendRedirect("ITDashboard.jsp");
                        break;
                    default:
                        request.setAttribute("error", "Invalid role. Please contact administrator.");
                        request.getRequestDispatcher("Login.jsp").forward(request, response);
                        return;
                }
            } else {
                request.setAttribute("error", "Cannot determine user role. Please contact administrator.");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            System.err.println("Google OAuth error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred during Google login: " + e.getMessage());
            request.getRequestDispatcher("Login.jsp").forward(request, response);
        }
    }
    
    /**
     * Exchange authorization code for access token
     */
    private String getAccessToken(String code) throws Exception {
        URL url = new URL(GoogleOAuthConfig.GOOGLE_TOKEN_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        
        String params = "code=" + java.net.URLEncoder.encode(code, "UTF-8")
                + "&client_id=" + java.net.URLEncoder.encode(GoogleOAuthConfig.GOOGLE_CLIENT_ID, "UTF-8")
                + "&client_secret=" + java.net.URLEncoder.encode(GoogleOAuthConfig.GOOGLE_CLIENT_SECRET, "UTF-8")
                + "&redirect_uri=" + java.net.URLEncoder.encode(GoogleOAuthConfig.GOOGLE_REDIRECT_URI, "UTF-8")
                + "&grant_type=authorization_code";
        
        OutputStream os = conn.getOutputStream();
        os.write(params.getBytes());
        os.flush();
        os.close();
        
        int status = conn.getResponseCode();
        InputStream is = status >= 200 && status < 300 ? conn.getInputStream() : conn.getErrorStream();
        if (is == null) {
            throw new IOException("Google token API returned HTTP " + status + " with empty response");
        }
        InputStreamReader isr = new InputStreamReader(is);
        JSONParser parser = new JSONParser();
        JSONObject response = (JSONObject) parser.parse(isr);
        isr.close();

        if (status < 200 || status >= 300) {
            Object err = response.get("error");
            Object errDesc = response.get("error_description");
            throw new IOException("Google token API HTTP " + status + ": " + err + " - " + errDesc);
        }
        
        return (String) response.get("access_token");
    }
    
    /**
     * Get user information from Google using access token
     */
    private JSONObject getUserInfo(String accessToken) throws Exception {
        URL url = new URL(GoogleOAuthConfig.GOOGLE_USERINFO_URL + "?access_token=" + accessToken);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        InputStream is = conn.getInputStream();
        InputStreamReader isr = new InputStreamReader(is);
        JSONParser parser = new JSONParser();
        JSONObject userInfo = (JSONObject) parser.parse(isr);
        isr.close();
        
        return userInfo;
    }
}
