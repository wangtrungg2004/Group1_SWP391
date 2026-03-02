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

        String sql = "SELECT Id, Name, ParentId, Level, FullPath, IsActive " +
                     "FROM [dbo].[Categories] " +
                     "WHERE IsActive = 1 " +
                     "ORDER BY FullPath";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("Id"));
                c.setName(rs.getString("Name"));

                int parentId = rs.getInt("ParentId");
                if (rs.wasNull()) {
                    c.setParentId(null);
                } else {
                    c.setParentId(parentId);
                }

                c.setLevel(rs.getInt("Level"));
                c.setFullPath(rs.getString("FullPath"));
                c.setIsActive(rs.getBoolean("IsActive"));

                // Tạo displayName có indent
                int level = c.getLevel();
                String indent = "";
                for (int i = 1; i < level; i++) {
                    indent += "-- ";
                }
                c.setDisplayName(indent + c.getName());

                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
