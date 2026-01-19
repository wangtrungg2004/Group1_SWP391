/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Users;
import Utils.DbContext;
/**
 *
 * @author DELL
 */
public class UserDao extends DbContext{
    public List<Users> getAllUsers()
    {
        List<Users> list = new ArrayList<>();
        String sql = "SELECT [Id]\n" +
            "      ,[Username]\n" +
            "      ,[Email]\n" +
            "      ,[PasswordHash]\n" +
            "      ,[FullName]\n" +
            "      ,[Role]\n" +
            "      ,[DepartmentId]\n" +
            "      ,[LocationId]\n" +
            "      ,[IsActive]\n" +
            "      ,[CreatedAt]\n" +
            "  FROM [dbo].[Users]";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                Users user = new Users();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username")); // Username là cột thứ 2
                user.setEmail(rs.getString("Email"));
                user.setPasswordHash(rs.getString("PasswordHash"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                user.setDepartmentId(rs.getInt("DepartmentId"));
                user.setLocationId(rs.getInt("LocationId"));
                user.IsActive(rs.getBoolean("IsActive"));
                user.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(user);
                
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public Users login(String username, String password) {
    String sql = """
        SELECT Id, Username, FullName, Role, IsActive
        FROM Users
        WHERE Username = ?
          AND PasswordHash = ?
          AND IsActive = 1
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, username);
        ps.setString(2, password); 
        
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            Users u = new Users();
            u.setId(rs.getInt("Id"));
            u.setUsername(rs.getString("Username"));
            u.setFullName(rs.getString("FullName"));
            u.setRole(rs.getString("Role"));
            return u;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

    
//    public static void main(String[] args) {
//        UserDao dao = new UserDao();
//        List<Users> users = dao.getAllUsers();
//
//        if (users == null || users.isEmpty()) {
//            System.out.println("Error");
//        } else {
//            System.out.println("User List:");
//            for (Users u : users) {
//                System.out.println(
//                    u.getId() + " | "
//                    + u.getUsername()+ " | "
//                    + u.getEmail() + " | "
//                    + u.getRole()
//                );
//            }
//        }
//    }

    
    
     public static void main(String[] args) {
        UserDao dao = new UserDao();

        String username = "admin";   
        String password = "123";  

        Users user = dao.login(username, password);

        if (user == null) {
            System.out.println("Login Success");
        } else {
            System.out.println("Login Failed");
            System.out.println("ID: " + user.getId());
            System.out.println("Username: " + user.getUsername());
            System.out.println("FullName: " + user.getFullName());
            System.out.println("Role: " + user.getRole());
        }
    }
}
