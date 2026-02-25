/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author Dumb Trung
 */

import Utils.DbContext;
import model.Category;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CategoryDao extends DbContext {
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        if (connection == null) return list;
        
        String sql = "SELECT Id, Name, Description FROM [dbo].[Categories]";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("Id"));
                c.setName(rs.getString("Name"));
                c.setDescription(rs.getString("Description"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
