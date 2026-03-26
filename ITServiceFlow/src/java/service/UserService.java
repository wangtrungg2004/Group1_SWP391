/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.UserDao;
import java.util.List;
import model.Users;

/**
 *
 * @author DELL
 */
public class UserService {
    private UserDao dao = new UserDao();
    
    public List<Users> getAllUser()
    {
        return dao.getAllUsers();
    }
    public Users login(String Username, String PasswordHash)
    {
        if (Username == null || PasswordHash == null) return null;
        return dao.login(Username, PasswordHash);
    }
    
    public boolean createUser(Users user)
    {
        if (user == null) {
            System.err.println("User object is null");
            return false;
        }
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            System.err.println("Username is null or empty");
            return false;
        }
        if (user.getPasswordHash() == null || user.getPasswordHash().trim().isEmpty()) {
            System.err.println("PasswordHash is null or empty");
            return false;
        }
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            System.err.println("Email is null or empty");
            return false;
        }
        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            System.err.println("FullName is null or empty");
            return false;
        }
        if (user.getRole() == null || user.getRole().trim().isEmpty()) {
            System.err.println("Role is null or empty");
            return false;
        }
        
        // Kiểm tra username đã tồn tại chưa
        if (dao.usernameExists(user.getUsername())) {
            System.err.println("Username đã tồn tại: " + user.getUsername());
            return false;
        }

        // Kiểm tra email đã tồn tại chưa
        if (dao.emailExists(user.getEmail())) {
            System.err.println("Email đã tồn tại: " + user.getEmail());
            return false;
        }
        
        return dao.createUser(user);
    }
    
    // Method để kiểm tra username (có thể dùng ở controller)
    public boolean usernameExists(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        return dao.usernameExists(username.trim());
    }

    // Method để kiểm tra email (có thể dùng ở controller)
    public boolean emailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return dao.emailExists(email.trim());
    }
    
    /**
     * Find or create user from Google OAuth data
     * If user exists with the email, return existing user
     * If not, create new user and return it
     */
    public Users findOrCreateGoogleUser(String googleId, String email, String fullName) {
        if (email == null || email.trim().isEmpty()) {
            System.err.println("Email is null or empty");
            return null;
        }
        
        // Try to find existing user by email
        Users existingUser = dao.findByEmail(email.trim());
        if (existingUser != null) {
            System.out.println("Found existing Google user: " + email);
            return existingUser;
        }
        
        // Create new user
        System.out.println("Creating new Google user: " + email);
        Users newUser = dao.createGoogleUser(email.trim(), fullName, googleId);
        return newUser;
    }

    /**
     * Request password reset: find user by email, generate token, save and return reset link.
     * Token valid 1 hour. Caller can send link by email or show on page.
     */
    public String requestPasswordReset(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        Users user = dao.findByEmail(email.trim());
        if (user == null) return null;
        String token = java.util.UUID.randomUUID().toString().replace("-", "");
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.add(java.util.Calendar.HOUR_OF_DAY, 1);
        if (!dao.setResetToken(user.getId(), token, cal.getTime())) return null;
        return token;
    }

    /**
     * Kiểm tra email có tồn tại và đang active hay không.
     * Dùng để phân biệt lỗi "không tìm thấy email" với lỗi kỹ thuật khi tạo reset token.
     */
    public boolean activeEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        return dao.findByEmail(email.trim()) != null;
    }

    /**
     * Reset password using token; returns true if success.
     */
    public boolean resetPassword(String token, String newPassword) {
        if (token == null || token.isEmpty() || newPassword == null || newPassword.trim().isEmpty()) return false;
        Users user = dao.findByResetToken(token);
        if (user == null) return false;
        boolean ok = dao.updatePassword(user.getId(), newPassword.trim());
        if (ok) dao.clearResetToken(user.getId());
        return ok;
    }
}
