/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import Utils.PasswordUtil;
import dao.UserDao;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;
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
    public Users login(String Username, String RawPassword)
    {
        if (Username == null || RawPassword == null) return null;
        // [PASSWORD_HASH] hash trước khi so sánh với DB; khi bỏ hash: gọi dao.login(Username, RawPassword.trim()) và đổi UserDao.login so sánh cột Password (plain)
        String passwordHash = PasswordUtil.sha256(RawPassword.trim());
        return dao.login(Username, passwordHash);
    }
    
    public boolean resetPassword(String username, String email, String rawNewPassword) {
        if (username == null || email == null || rawNewPassword == null) {
            return false;
        }
        // [PASSWORD_HASH] hash trước khi lưu; khi bỏ hash: truyền rawNewPassword.trim() và đổi UserDao dùng cột Password
        String newPasswordHash = PasswordUtil.sha256(rawNewPassword.trim());
        return dao.resetPassword(username, email, newPasswordHash);
    }
    
    public boolean createUser(String username, String email, String rawPassword, String fullName, String role, Integer departmentId) {
        if (username == null || email == null || rawPassword == null || role == null) {
            return false;
        }
        int locationId = dao.getDefaultLocationId();
        if (locationId <= 0) {
            return false;
        }
        // [PASSWORD_HASH] hash trước khi insert; khi bỏ hash: truyền rawPassword.trim() và đổi UserDao/DB dùng cột Password
        String passwordHash = PasswordUtil.sha256(rawPassword.trim());
        return dao.createUser(
                username.trim(),
                email.trim(),
                passwordHash,
                fullName == null ? null : fullName.trim(),
                role.trim(),
                departmentId,
                locationId
        );
    }
    
    public Users getUserByEmail(String email) {
        return dao.getUserByEmail(email);
    }

    public Users loginWithGoogleEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        return dao.getUserByEmail(email.trim());
    }
    
    public String createPasswordResetToken(String email) {
        Users user = dao.getUserByEmail(email);
        if (user == null) {
            return null;
        }
        String token = UUID.randomUUID().toString();
        Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + 15 * 60 * 1000L);
        boolean saved = dao.savePasswordResetToken(user.getId(), token, expiresAt);
        return saved ? token : null;
    }
    
    public boolean isValidResetToken(String token) {
        return dao.getValidUserIdByToken(token) != null;
    }
    
    public boolean resetPasswordByToken(String token, String rawNewPassword) {
        if (token == null || rawNewPassword == null || rawNewPassword.trim().isEmpty()) {
            return false;
        }
        Integer userId = dao.getValidUserIdByToken(token);
        if (userId == null) {
            return false;
        }
        // [PASSWORD_HASH] hash trước khi update; khi bỏ hash: truyền rawNewPassword.trim() và đổi UserDao/DB dùng cột Password
        String newPasswordHash = PasswordUtil.sha256(rawNewPassword.trim());
        boolean updated = dao.updatePasswordByUserId(userId, newPasswordHash);
        if (!updated) {
            return false;
        }
        return dao.markTokenUsed(token);
    }
    
    public int getTotalUser()
    {
        return dao.getTotalUser();
    }
    
    public List<Users> getTopAgentsThisMonth() {
        return dao.getTopAgentsThisMonth();
    }
}
