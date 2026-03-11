/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.KnowErrors;
import Utils.DbContext;
import java.time.Year;
import model.Tickets;
import model.TimeLog;
import model.Problems;
/**
 *
 * @author DELL
 */
public class KnowErrorDao extends DbContext{
    
    
    public List<KnowErrors> getAllActiveKnowErrors()
    {
        List<KnowErrors> list = new ArrayList<>();
        String sql = "SELECT Id, ProblemId, Title, Workaround, Status, ViewCount, CreatedAt "
                + "FROM [dbo].[KnownErrors] "
                + "WHERE Status = 'Active' "
                + "ORDER BY CreatedAt DESC";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                KnowErrors kn = new KnowErrors();
                kn.setId(rs.getInt("Id"));
                kn.setProblemId(rs.getInt("ProblemId"));
                kn.setTitle(rs.getString("Title"));
                kn.setWorkAround(rs.getString("Workaround"));
                kn.setStatus(rs.getString("Status"));
                kn.setViewCount(rs.getInt("ViewCount"));
                kn.setCreatedAt(rs.getTimestamp("CreatedAt"));
                list.add(kn);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public List<KnowErrors> getAllKnowErrors()
    {
        List<KnowErrors> list = new ArrayList<>();
        String sql = "SELECT Id, ProblemId, Title, Workaround, Status, ViewCount, CreatedAt "
                + "FROM [dbo].[KnownErrors] "
                + "ORDER BY CreatedAt DESC";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                KnowErrors kn = new KnowErrors();
                kn.setId(rs.getInt("Id"));
                kn.setProblemId(rs.getInt("ProblemId"));
                kn.setTitle(rs.getString("Title"));
                kn.setWorkAround(rs.getString("Workaround"));
                kn.setStatus(rs.getString("Status"));
                kn.setViewCount(rs.getInt("ViewCount"));
                kn.setCreatedAt(rs.getTimestamp("CreatedAt"));
                list.add(kn);
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public boolean addNewKnowError(int problemId, String title, String workAround)
    {
        String sql = "INSERT INTO [dbo].[KnownErrors] "
                + "([ProblemId], [Title], [Workaround], [Status], [ViewCount])"
                + " VALUES (?, ?, ?, 'Active', 0)";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, problemId);
            stm.setString(2, title);
            stm.setString(3, workAround);
            stm.executeUpdate();
            return true;

        }
        catch(Exception ex){
            ex.printStackTrace();
            return false;
        }
    }
    
    public KnowErrors getKnowErrorById(int Id)
    {
        String sql = "SELECT Id, ProblemId, Title, Workaround,"
                + " Status, ViewCount, CreatedAt"
                + " FROM [dbo].[KnownErrors]"
                + " WHERE Id = ?";
        try 
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, Id);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                KnowErrors kn = new KnowErrors();
                kn.setId(rs.getInt("Id"));
                kn.setProblemId(rs.getInt("ProblemId"));
                kn.setTitle(rs.getString("Title"));
                kn.setWorkAround(rs.getString("Workaround"));
                kn.setStatus(rs.getString("Status"));
                kn.setViewCount(rs.getInt("ViewCount"));
                kn.setCreatedAt(rs.getTimestamp("CreatedAt"));
                return kn; 
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return null;
    }
    
    public KnowErrors findKnowErrorByProblemId(int problemId)
    {
        String sql = "SELECT Id, ProblemId, Title, Workaround,"
                + " Status, ViewCount, CreatedAt"
                + " FROM [dbo].[KnownErrors]"
                + " WHERE ProblemId = ?";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, problemId);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                KnowErrors kn = new KnowErrors();
                kn.setId(rs.getInt("Id"));
                kn.setProblemId(rs.getInt("ProblemId"));
                kn.setTitle(rs.getString("Title"));
                kn.setWorkAround(rs.getString("Workaround"));
                kn.setStatus(rs.getString("Status"));
                kn.setViewCount(rs.getInt("ViewCount"));
                kn.setCreatedAt(rs.getTimestamp("CreatedAt"));
                return kn;
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return null;
    }

    public boolean updateKnowError(int id, String title, String workAround)
    {
        String sql = "UPDATE [dbo].[KnownErrors] SET [Title] = ?, [Workaround] = ? WHERE [Id] = ?";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, title);
            stm.setString(2, workAround);
            stm.setInt(3, id);
            int rows = stm.executeUpdate();
            return rows > 0;
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
    
    public boolean closedKnowError(int id, String status)
    {
        String sql = "UPDATE [dbo].[KnownErrors] SET [Status] = ? WHERE [Id] = ?";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, status);
            stm.setInt(2, id);
            int rows = stm.executeUpdate();
            return rows > 0;
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
}
