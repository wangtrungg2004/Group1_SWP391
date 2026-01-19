/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Problems;
import Utils.DbContext;
/**
 *
 * @author DELL
 */
public class ProblemDao extends DbContext{
    public List<Problems> getAllProblems()
    {
        List<Problems> list = new ArrayList<>();
        String sql = "SELECT p.[Id]\n" +
            "      ,p.[TicketNumber]\n" +
            "      ,p.[Title]\n" +
            "      ,p.[Description]\n" +
            "      ,p.[RootCause]\n" +
            "      ,p.[Workaround]\n" +
            "      ,p.[Status]\n" +
            "      ,p.[CreatedBy]\n" +
            "      ,u.[FullName] AS CreatedByName\n" +
            "      ,p.[AssignedTo]\n" +
            "      ,p.[CreatedAt]\n" +
            "  FROM [dbo].[Problems] p\n" +
            "  LEFT JOIN [dbo].[Users] u ON p.[CreatedBy] = u.[Id]";
        
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
               Problems pro = new Problems();
               pro.setId(rs.getInt("Id"));
               pro.setTicketNumber(rs.getString("TicketNumber"));
               pro.setTitle(rs.getString("Title"));
               pro.setDescription(rs.getString("Description"));
               pro.setRootCause(rs.getString("RootCause"));
               pro.setWorkaround(rs.getString("Workaround"));
               pro.setStatus(rs.getString("Status"));
               pro.setCreatedBy(rs.getInt("CreatedBy"));
               pro.setCreatedByName(rs.getString("CreatedByName"));
               pro.setAssignedTo(rs.getInt("AssignedTo"));
               pro.setCreatedAt(rs.getDate("CreatedAt"));
               list.add(pro);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    
    
    
    
    public static void main(String[] args) {

        ProblemDao dao = new ProblemDao();
        List<Problems> list = dao.getAllProblems();

        if (list.isEmpty()) {
            System.out.println("Errored");
            return;
        }

        for (Problems p : list) {
            System.out.println("Id          : " + p.getId());
            System.out.println("TicketNumber: " + p.getTicketNumber());
            System.out.println("Title       : " + p.getTitle());
            System.out.println("Description : " + p.getDescription());
            System.out.println("RootCause   : " + p.getRootCause());
            System.out.println("Workaround  : " + p.getWorkaround());
            System.out.println("Status      : " + p.getStatus());
            System.out.println("CreatedBy   : " + p.getCreatedBy());
            System.out.println("AssignedTo  : " + p.getAssignedTo());
            System.out.println("CreatedAt   : " + p.getCreatedAt());
            System.out.println("--------------------------------------");
        }
    }
}
