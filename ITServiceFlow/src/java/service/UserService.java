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
}
