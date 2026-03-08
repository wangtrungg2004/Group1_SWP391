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
import java.time.Year;
import model.Tickets;
import model.TimeLog;
/**
 *
 * @author DELL
 */
public class ProblemDao extends DbContext{
    public List<Problems> getAllProblems()
    {
        List<Problems> list = new ArrayList<>();
        String sql = "SELECT p.[Id], p.[TicketNumber], p.[Title], p.[Description], p.[RootCause], p.[Workaround], p.[Status],\n" +
                        "       p.[CreatedBy], u.[FullName] AS CreatedByName, p.[AssignedTo], u2.[FullName] AS AssignedToName, p.[CreatedAt]\n" +
                        "FROM [dbo].[Problems] p\n" +
                        "LEFT JOIN [dbo].[Users] u ON p.[CreatedBy] = u.[Id]\n" +
                        "LEFT JOIN [dbo].[Users] u2 ON p.[AssignedTo] = u2.[Id]";
        
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
               pro.setAssignedToName(rs.getString("AssignedToName"));
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
    
    public List<Problems> getProblemsWithPages(int page, int pageSize) {
        List<Problems> list = new ArrayList<>();
        try {
            String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description, "
                      + "p.RootCause, p.Workaround, p.Status, p.CreatedBy, "
                      + "u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt "
                      + "FROM dbo.Problems p "
                      + "LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id "
                      + "LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id "
                      + "ORDER BY p.CreatedAt DESC "
                      + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            PreparedStatement stm = connection.prepareStatement(sql);
            int offset = (page - 1) * pageSize;
            stm.setInt(1, offset);
            stm.setInt(2, pageSize);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
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
                pro.setAssignedToName(rs.getString("AssignedToName"));
                pro.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(pro);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public int getTotalProblem() {
        String sql = "SELECT COUNT(Id) FROM dbo.Problems";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }
    
    public Problems getProblemById(int ProblemId)
    {
        String sql = "SELECT p.[Id], p.[TicketNumber], p.[Title], p.[Description], " +
             "p.[RootCause], p.[Workaround], p.[Status], p.[RejectedReason], " +
             "p.[CreatedBy], u1.[FullName] AS CreatedByName, " +
             "p.[AssignedTo], u2.[FullName] AS AssignedToName, p.[CreatedAt] " +
             "FROM [dbo].[Problems] p " +
             "LEFT JOIN [dbo].[Users] u1 ON p.CreatedBy = u1.Id " +
             "LEFT JOIN [dbo].[Users] u2 ON p.AssignedTo = u2.Id " +
             "WHERE p.Id = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, ProblemId);
            try (ResultSet rs = stm.executeQuery()) {
                if(rs.next())
                {
                    Problems p = new Problems();
                    p.setId(rs.getInt("Id"));
                    p.setTicketNumber(rs.getString("TicketNumber"));
                    p.setTitle(rs.getString("Title"));
                    p.setDescription(rs.getString("Description"));
                    p.setRootCause(rs.getString("RootCause"));
                    p.setWorkaround(rs.getString("Workaround"));
                    p.setStatus(rs.getString("Status"));
                    p.setCreatedBy(rs.getInt("CreatedBy"));
                    p.setCreatedByName(rs.getString("CreatedByName"));
                    p.setAssignedTo(rs.getInt("AssignedTo"));
                    p.setAssignedToName(rs.getString("AssignedToName"));
                    p.setCreatedAt(rs.getDate("CreatedAt"));
                    p.setRejectedReason(rs.getString("RejectedReason"));
                    return p;
                }
            }
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }
    
    public boolean updateProblem(Problems p)
    {
        String sql = "UPDATE [dbo].[Problems]\n" +
            "   SET [TicketNumber] = ?\n" +
            "      ,[Title] = ?\n" +
            "      ,[Description] = ?\n" +
            "      ,[RootCause] = ?\n" +
            "      ,[Workaround] = ?\n" +
            "      ,[Status] = ?\n" +
            "      ,[AssignedTo] = ?\n" +
            "      ,[RejectedReason] = ?\n" +   
            " WHERE Id = ?";
            try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1,p.getTicketNumber());
            stm.setString(2, p.getTitle());
            stm.setString(3, p.getDescription());
            stm.setString(4, p.getRootCause());
            stm.setString(5, p.getWorkaround());
            stm.setString(6, p.getStatus());
            if (p.getAssignedTo() > 0) {
                stm.setInt(7, p.getAssignedTo());
            } else {
                stm.setNull(7, java.sql.Types.INTEGER);
            }
            stm.setString(8, p.getRejectedReason());
            stm.setInt(9, p.getId());

            return stm.executeUpdate() > 0;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
    
    public boolean addProblem(String Title, String Description,
            String RootCause, String WalkAround, String Status, int CreatedBy, int AssignedTo, Date CreatedAt) {
        
        String TicketNumber = getNextTicketNumber();
        
        String sql = "INSERT INTO [dbo].[Problems]\n" +
"           ([TicketNumber]\n" +
"           ,[Title]\n" +
"           ,[Description]\n" +
"           ,[RootCause]\n" +
"           ,[Workaround]\n" +
"           ,[Status]\n" +
"           ,[CreatedBy]\n" +
"           ,[AssignedTo]\n" +
"           ,[CreatedAt])\n" +
"     VALUES\n" +
"           (?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,?\n" +
"           ,GETDATE())";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, TicketNumber);
            stm.setString(2, Title);
            stm.setString(3, Description);
            stm.setString(4, RootCause);
            stm.setString(5, WalkAround);
            stm.setString(6, Status);
            stm.setInt(7, CreatedBy);
            if (AssignedTo > 0) {
                stm.setInt(8, AssignedTo);
            } else {
                stm.setNull(8, java.sql.Types.INTEGER);
            }
            stm.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }
    
    
    public String getNextTicketNumber() {

        int year = Year.now().getValue();
        String prefix = "PRB-" + year + "-";

        String sql =
            "SELECT MAX(TicketNumber) " +
            "FROM Problems " +
            "WHERE TicketNumber LIKE ?";

        int next = 1;

        try (PreparedStatement stm = connection.prepareStatement(sql)) {

            stm.setString(1, prefix + "%");
            ResultSet rs = stm.executeQuery();

            if (rs.next() && rs.getString(1) != null) {
                String last = rs.getString(1); // PRB-2026-015
                String seq = last.substring(last.lastIndexOf('-') + 1);
                next = Integer.parseInt(seq) + 1;
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            // fallback an toàn
//            return prefix + "001";
        }

        return prefix + String.format("%03d", next);
    }

    public boolean deleteProblem(int ProblemId)
    {
        String sql = "DELETE FROM [dbo].[Problems]\n" +
                "      WHERE Id = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, ProblemId);
            stm.executeUpdate();
            return true;
//            int rows = stm.executeUpdate();
//            return rows > 0;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }

    public List<Problems> searchProblem(String keyword)
    {
        List<Problems> list = new ArrayList<>();
        try
        {
            String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description, " +
             "p.RootCause, p.Workaround, p.Status, p.CreatedBy, " +
             "u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt " +
             "FROM dbo.Problems p " +
             "LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id " +
             "LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id " +
             "WHERE (p.Title LIKE ? OR p.TicketNumber LIKE ?)";
            
            PreparedStatement stm = connection.prepareStatement(sql);
            String searchValue = "%" + keyword + "%";
            stm.setString(1, searchValue);
            stm.setString(2, searchValue);
            
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
               pro.setAssignedToName(rs.getString("AssignedToName"));
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
    
    public List<Tickets> viewRelatedTicket(int Id)
    {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT\n" +
                "    t.Id,\n" +
                "    t.TicketNumber,\n" +
                "    t.TicketType,\n" +
                "    t.Title,\n" +
                "    t.Description,\n" +
                "    t.CategoryId,\n" +
                "    t.LocationId,\n" +
                "    t.Impact,\n" +
                "    t.Urgency,\n" +
                "    t.PriorityId,\n" +
                "    t.ServiceCatalogId,\n" +
                "    t.RequiresApproval,\n" +
                "    t.ApprovedBy,\n" +
                "    t.ApprovedAt,\n" +
                "    t.Status,\n" +
                "    t.CreatedBy,\n" +
                "    t.AssignedTo,\n" +
                "    t.ParentTicketId,\n" +
                "    t.ResolvedAt,\n" +
                "    t.ClosedAt,\n" +
                "    t.CreatedAt,\n" +
                "    t.UpdatedAt,\n" +
                "    t.CurrentLevel\n" +
                "FROM dbo.ProblemTickets AS pt\n" +
                "INNER JOIN dbo.Tickets AS t\n" +
                "    ON pt.TicketId = t.Id\n" +
                "WHERE pt.ProblemId = ?\n" +
                "ORDER BY t.CreatedAt DESC;";
        try
        {
           PreparedStatement stm = connection.prepareStatement(sql);
           stm.setInt(1, Id);
           ResultSet rs = stm.executeQuery();
           while(rs.next())
           {
               Tickets ticket = new Tickets();
            ticket.setId(rs.getInt("Id"));
            ticket.setTicketNumber(rs.getString("TicketNumber"));
            ticket.setTicketType(rs.getString("TicketType"));
            ticket.setTitle(rs.getString("Title"));
            ticket.setDescription(rs.getString("Description"));
            ticket.setCategoryId(rs.getInt("CategoryId"));
            ticket.setLocationId(rs.getInt("LocationId"));
            ticket.setImpact(rs.getInt("Impact"));
            ticket.setUrgency(rs.getInt("Urgency"));
            ticket.setPriorityId(rs.getInt("PriorityId"));
            ticket.setServiceCatalogId(rs.getInt("ServiceCatalogId"));
            ticket.setRequiresApproval(rs.getBoolean("RequiresApproval"));
            ticket.setApprovedBy(rs.getInt("ApprovedBy"));
            ticket.setApprovedAt(rs.getDate("ApprovedAt"));
            ticket.setStatus(rs.getString("Status"));
            ticket.setCreatedBy(rs.getInt("CreatedBy"));
            ticket.setAssignedTo(rs.getInt("AssignedTo"));
            ticket.setParentTicketId(rs.getInt("ParentTicketId"));
            ticket.setResolvedAt(rs.getDate("ResolvedAt"));
            ticket.setClosedAt(rs.getDate("ClosedAt"));
            ticket.setCreatedAt(rs.getDate("CreatedAt"));
            ticket.setUpdatedAt(rs.getDate("UpdatedAt"));
            ticket.setCurrentLevel(rs.getInt("CurrentLevel"));
            list.add(ticket);
           }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
        }
        return list;
    }
    
    public int getLatestProblemId() {
        String sql = "SELECT TOP 1 Id FROM [dbo].[Problems] ORDER BY Id DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             ResultSet rs = stm.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("Id");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1;
    }
    
    public List<Problems> getAssignProblems(int userId, int page, int pageSize)
    {
        List<Problems> list = new ArrayList<>();
        String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description,\n" +
"               p.RootCause, p.Workaround, p.Status, p.CreatedBy,\n" +
"               u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt\n" +
"        FROM dbo.Problems p\n" +
"        LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id\n" +
"        LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id\n" +
"        WHERE p.AssignedTo = ?\n" +
"        ORDER BY p.CreatedAt DESC\n" +
"        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            int offset = (page - 1) * pageSize;

            stm.setInt(1, userId);
            stm.setInt(2, offset);
            stm.setInt(3, pageSize);
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
                pro.setAssignedToName(rs.getString("AssignedToName"));
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
    
    public int getTotalAssignProblems(int userId) {
        String sql = "SELECT COUNT(Id) FROM dbo.Problems WHERE AssignedTo = ?";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
    
    public boolean startInvestigation(int problemId) {
        String sql = "UPDATE [dbo].[Problems] " +
                     "SET [Status] = ? " +
                     "WHERE Id = ? AND Status = 'NEW'";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, "UNDER_INVESTIGATION");
            stm.setInt(2, problemId);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }
    
    public List<Problems> filterByStatus(String status) {
        List<Problems> list = new ArrayList<>();

        String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description, " +
                     "p.RootCause, p.Workaround, p.Status, p.CreatedBy, " +
                     "u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt " +
                     "FROM dbo.Problems p " +
                     "LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id " +
                     "LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id " +
                     "WHERE p.Status = ?";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, status);

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
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
                pro.setAssignedToName(rs.getString("AssignedToName"));
                pro.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(pro);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Problems> filterByDateRange(Date fromDate, Date toDate) {
        List<Problems> list = new ArrayList<>();

        String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description, " +
                     "p.RootCause, p.Workaround, p.Status, p.CreatedBy, " +
                     "u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt " +
                     "FROM dbo.Problems p " +
                     "LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id " +
                     "LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id " +
                     "WHERE p.CreatedAt BETWEEN ? AND ?";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setDate(1, fromDate);
            stm.setDate(2, toDate);

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
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
                pro.setAssignedToName(rs.getString("AssignedToName"));
                pro.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(pro);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public List<Problems> searchAssignedProblem(int UserId,String keyword)
    {
        List<Problems> list = new ArrayList<>();
        try
        {
            String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description, " +
             "p.RootCause, p.Workaround, p.Status, p.CreatedBy, " +
             "u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt " +
             "FROM dbo.Problems p " +
             "LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id " +
             "LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id " +
             "WHERE p.AssignedTo = ? " +
             "AND (p.Title LIKE ? OR p.TicketNumber LIKE ?)";
            
            PreparedStatement stm = connection.prepareStatement(sql);
            String searchValue = "%" + keyword + "%";
            stm.setInt(1, UserId);
            stm.setString(2, searchValue);
            stm.setString(3, searchValue);
            
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
               pro.setAssignedToName(rs.getString("AssignedToName"));
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
    
    public List<Problems> getProblemsPendingWithPages(int page, int pageSize) {
        List<Problems> list = new ArrayList<>();
        try {
            String sql = "SELECT p.Id, p.TicketNumber, p.Title, p.Description, "
                      + "p.RootCause, p.Workaround, p.Status, p.CreatedBy, "
                      + "u.FullName AS CreatedByName, p.AssignedTo, u2.FullName AS AssignedToName, p.CreatedAt "
                      + "FROM dbo.Problems p "
                      + "LEFT JOIN dbo.Users u ON p.CreatedBy = u.Id "
                      + "LEFT JOIN dbo.Users u2 ON p.AssignedTo = u2.Id "
                      + "WHERE p.Status = 'PENDING' "
                      + "ORDER BY p.CreatedAt DESC "
                      + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            PreparedStatement stm = connection.prepareStatement(sql);
            int offset = (page - 1) * pageSize;
            stm.setInt(1, offset);
            stm.setInt(2, pageSize);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
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
                pro.setAssignedToName(rs.getString("AssignedToName"));
                pro.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(pro);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    public boolean updateProblemStatus(int problemId, String status)
    {
        String sql = "UPDATE [dbo].[Problems]\n" +
                    "   SET [Status] = ?\n" +
                    "   WHERE Id =?";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, status);
            stm.setInt(2, problemId);
            stm.executeUpdate();
            return true;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
    
    public boolean addProblemTickets(int problemId, List<Integer> tickets)
    {
        String sql = "INSERT INTO [dbo].[ProblemTickets]\n" +
"           ([ProblemId]\n" +
"           ,[TicketId])\n" +
"     VALUES\n" +
"           (?\n" +
"           ,?)";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            for (Integer ticketId : tickets) {
                stm.setInt(1, problemId);
                stm.setInt(2, ticketId);
                stm.executeUpdate();
            }
            return true;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
    
    
    public boolean unlinkProblemTicket(int problemId, int ticketId)
    {
        String sql = "DELETE FROM [dbo].[ProblemTickets]"
                + " WHERE ProblemId = ? "
                + " AND TicketId = ?";
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, problemId);
            stm.setInt(2, ticketId);
            stm.executeUpdate();
            return true;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return false;
        }
    }
    
    public boolean unlinkAllProblemTickets(int problemId)
    {
        String sql = "DELETE FROM [dbo].[ProblemTickets]"
                + "   WHERE ProblemId = ?";
         try
         {
             PreparedStatement stm = connection.prepareStatement(sql);
             stm.setInt(1, problemId);
             stm.executeUpdate();
             return true;
         }
         catch(Exception ex)
         {
             ex.printStackTrace();
             return false;
         }
    }
//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao(); // constructor đã mở connection
//        int testProblemId = 1;
//
//        Problems p = dao.getProblemById(testProblemId);
//
//        if (p != null) {
//            System.out.println("===== PROBLEM FOUND =====");
//            System.out.println("Id: " + p.getId());
//            System.out.println("TicketNumber: " + p.getTicketNumber());
//            System.out.println("Title: " + p.getTitle());
//            System.out.println("Description: " + p.getDescription());
//            System.out.println("RootCause: " + p.getRootCause());
//            System.out.println("Workaround: " + p.getWorkaround());
//            System.out.println("Status: " + p.getStatus());
//            System.out.println("CreatedByName: " + p.getCreatedByName());
//            System.out.println("AssignedTo: " + p.getAssignedTo());
//            System.out.println("CreatedAt: " + p.getCreatedAt());
//        } else {
//            System.out.println("❌ Problem NOT found with Id = " + testProblemId);
//        }
//    }
    
    
//public static void main(String[] args) {
//
//    ProblemDao dao = new ProblemDao();
//
//    boolean result = dao.addProblem(
//        "Test add problem",                 // Title
//        "This is a test description",       // Description
//        null,                               // RootCause
//        "Restart application",              // Workaround
//        "OPEN",                             // Status
//        1,                                  // CreatedBy (userId có sẵn trong DB)
//        2,                                  // AssignedTo (userId có sẵn trong DB)
//        new java.sql.Date(System.currentTimeMillis())
//    );
//
//    if (result) {
//        System.out.println("Insert Problem SUCCESS");
//    } else {
//        System.out.println("Insert Problem FAILED");
//    }
//}


//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao();
//        List<Problems> list = dao.getAllProblems();
//
//        if (list.isEmpty()) {
//            System.out.println("Errored");
//            return;
//        }
//
//        for (Problems p : list) {
//            System.out.println("Id          : " + p.getId());
//            System.out.println("TicketNumber: " + p.getTicketNumber());
//            System.out.println("Title       : " + p.getTitle());
//            System.out.println("Description : " + p.getDescription());
//            System.out.println("RootCause   : " + p.getRootCause());
//            System.out.println("Workaround  : " + p.getWorkaround());
//            System.out.println("Status      : " + p.getStatus());
//            System.out.println("CreatedBy   : " + p.getCreatedBy());
//            System.out.println("AssignedTo  : " + p.getAssignedTo());
//            System.out.println("CreatedAt   : " + p.getCreatedAt());
//            System.out.println("--------------------------------------");
//        }
//    }
//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao();
//
//        int testProblemId = 1;
//
//        // 1️⃣ Lấy problem hiện tại từ DB
//        Problems p = dao.getProblemById(testProblemId);
//
//        if (p == null) {
//            System.out.println("Problem NOT found with Id = " + testProblemId);
//            return;
//        }
//
//        // 2️⃣ In dữ liệu trước khi update
//        System.out.println("===== BEFORE UPDATE =====");
//        System.out.println("Title: " + p.getTitle());
//        System.out.println("Status: " + p.getStatus());
//        System.out.println("Workaround: " + p.getWorkaround());
//
//        p.setTitle(p.getTitle() + " (Updated)");
//        p.setStatus("RESOLVED");
//        p.setWorkaround("Restart service and clear cache");
//
//        boolean success = dao.updateProblem(p);
//
//        if (success) {
//            System.out.println("UPDATE SUCCESS");
//        } else {
//            System.out.println("UPDATE FAILED");
//        }
//
//        Problems updated = dao.getProblemById(testProblemId);
//
//        System.out.println("===== AFTER UPDATE =====");
//        System.out.println("Title: " + updated.getTitle());
//        System.out.println("Status: " + updated.getStatus());
//        System.out.println("Workaround: " + updated.getWorkaround());
//    }
    
    
//    public static void main(String[] args) {
//        ProblemDao dao = new ProblemDao();
//
//        String keyword = "2026"; 
//        List<Problems> result = dao.searchProblem(keyword);
//
//        System.out.println("Total results: " + result.size());
//        for (Problems p : result) {
//            System.out.println(
//                p.getTicketNumber() + " | " +
//                p.getTitle() + " | " +
//                p.getStatus() + " | " +
//                p.getCreatedByName()
//            );
//        }
//    }
    
//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao();
//
//        int testProblemId = 8; // đổi sang ID có thật, status = NEW
//
//        Problems before = dao.getProblemById(testProblemId);
//        System.out.println("===== BEFORE =====");
//        System.out.println("Status: " + before.getStatus());
//
//        boolean result = dao.startInvestigation(testProblemId);
//
//        if (result) {
//            System.out.println("✅ Start Investigation SUCCESS");
//        } else {
//            System.out.println("❌ Start Investigation FAILED");
//        }
//
//        Problems after = dao.getProblemById(testProblemId);
//        System.out.println("===== AFTER =====");
//        System.out.println("Status: " + after.getStatus());
//    }
    
//    public static void main(String[] args) {
//    ProblemDao dao = new ProblemDao(); // hoặc DAO bạn đang dùng
//
//    int testProblemId = 3; // đổi ID có thật trong DB
//    List<Tickets> tickets = dao.viewRelatedTicket(testProblemId);
//
//    if (tickets.isEmpty()) {
//        System.out.println("No ticket linked with problemId = " + testProblemId);
//    } else {
//        System.out.println("✅ list Problem Linked:");
//        for (Tickets t : tickets) {
//            System.out.println(
//                "ID: " + t.getId() +
//                " | Number: " + t.getTicketNumber() +
//                " | Title: " + t.getTitle() +
//                " | Status: " + t.getStatus()
//            );
//        }
//    }
//}
    
//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao();
//
//        int userId = 3;          // ID người được assign
//        String keyword = "003";  // từ khóa tìm kiếm
//
//        List<Problems> list = dao.searchAssignedProblem(userId, keyword);
//
//        if (list.isEmpty()) {
//            System.out.println("Errored");
//            return;
//        }
//
//        for (Problems p : list) {
//            System.out.println("Id          : " + p.getId());
//            System.out.println("TicketNumber: " + p.getTicketNumber());
//            System.out.println("Title       : " + p.getTitle());
//            System.out.println("Description : " + p.getDescription());
//            System.out.println("RootCause   : " + p.getRootCause());
//            System.out.println("Workaround  : " + p.getWorkaround());
//            System.out.println("Status      : " + p.getStatus());
//            System.out.println("CreatedBy   : " + p.getCreatedBy());
//            System.out.println("AssignedTo  : " + p.getAssignedTo());
//            System.out.println("CreatedAt   : " + p.getCreatedAt());
//            System.out.println("--------------------------------------");
//        }
//    }
//
//    
    
//    
//    public static void main(String[] args) {
//        // Khởi tạo DAO
//        ProblemDao dao = new ProblemDao();
//
//        // Test phân trang
//        int page = 1;
//        int pageSize = 5;
//
//        List<Problems> list = dao.getProblemsPendingWithPages(page, pageSize);
//
//        // In kết quả ra console
//        if (list.isEmpty()) {
//            System.out.println("Không có problem nào ở trạng thái PENDING.");
//        } else {
//            System.out.println("Danh sách Problems (PENDING):");
//            for (Problems p : list) {
//                System.out.println("-----------------------------");
//                System.out.println("ID: " + p.getId());
//                System.out.println("Ticket: " + p.getTicketNumber());
//                System.out.println("Title: " + p.getTitle());
//                System.out.println("Status: " + p.getStatus());
//                System.out.println("Created By: " + p.getCreatedByName());
//                System.out.println("Assigned To: " + p.getAssignedToName());
//                System.out.println("Created At: " + p.getCreatedAt());
//            }
//        }
//    }
    
//    
//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao();
//
//        int testProblemId = 27; // đổi sang problemId có thật trong DB
//
//        List<Integer> ticketIds = new ArrayList<>();
//        ticketIds.add(23);
////        ticketIds.add(26);
//
//        boolean result = dao.addProblemTickets(testProblemId, ticketIds);
//
//        if (result) {
//            System.out.println("✅ Link tickets to problem SUCCESS");
//            System.out.println("ProblemId: " + testProblemId);
//            System.out.println("TicketIds: " + ticketIds);
//        } else {
//            System.out.println("❌ Link tickets to problem FAILED");
//        }
//    }
    
//    public static void main(String[] args) {
//
//        ProblemDao dao = new ProblemDao();
//
//        int testProblemId = 27;   // problemId có thật
//        int testTicketId  = 23;   // ticketId đang link với problem
//
//        System.out.println("===== BEFORE UNLINK =====");
//        System.out.println("ProblemId = " + testProblemId + ", TicketId = " + testTicketId);
//
//        boolean result = dao.unlinkProblemTicket(testProblemId, testTicketId);
//
//        if (result) {
//            System.out.println("✅ Unlink ticket SUCCESS");
//        } else {
//            System.out.println("❌ Unlink ticket FAILED");
//        }
//
//        // Verify lại trong DB bằng SQL:
//        System.out.println("👉 Check DB:");
//        System.out.println(
//            "SELECT * FROM ProblemTickets WHERE ProblemId = "
//            + testProblemId + " AND TicketId = " + testTicketId
//        );
//    }
    
    public static void main(String[] args) {

        ProblemDao dao = new ProblemDao();

        int testProblemId = 27;

        System.out.println("===== TEST UNLINK ALL TICKETS =====");
        System.out.println("ProblemId = " + testProblemId);

        boolean result = dao.unlinkAllProblemTickets(testProblemId);

        if (result) {
            System.out.println("✅ Unlink ALL tickets SUCCESS");
        } else {
            System.out.println("⚠️ No ticket was unlinked (or failed)");
        }

        System.out.println("👉 Verify bằng SQL:");
        System.out.println(
            "SELECT * FROM ProblemTickets WHERE ProblemId = " + testProblemId
        );
    }
    

    // Lưu log thời gian mới
public boolean addTimeLog(int problemId, int userId, double hours) {
    String sql = "INSERT INTO TimeLogs (TicketId, UserId, Hours, LogDate) " +
                 "VALUES (?, ?, ?, CONVERT(date, GETDATE()))";
    try (PreparedStatement stm = connection.prepareStatement(sql)) {
        stm.setInt(1, problemId);
        stm.setInt(2, userId);
        stm.setDouble(3, hours);
        return stm.executeUpdate() > 0;
    } catch (Exception ex) {
        ex.printStackTrace();
        return false;
    }
}



// Tính tổng giờ cho 1 problem
public double getTotalHoursByProblem(int problemId) {
    String sql = "SELECT ISNULL(SUM(Hours), 0) FROM TimeLogs WHERE TicketId = ?";
    try (PreparedStatement stm = connection.prepareStatement(sql)) {
        stm.setInt(1, problemId);
        ResultSet rs = stm.executeQuery();
        if (rs.next()) {
            return rs.getDouble(1);
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
    return 0.0;
}
    
    // Bắt đầu timer (chỉ insert StartTime)
public int startTimer(int problemId, int userId) {
    String sql = "INSERT INTO TimeLogs (TicketId, UserId, StartTime, LogDate) " +
                 "VALUES (?, ?, GETDATE(), CONVERT(date, GETDATE()))";
    try (PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        stm.setInt(1, problemId);
        stm.setInt(2, userId);
        int rows = stm.executeUpdate();
        System.out.println("startTimer: inserted " + rows + " rows for problem " + problemId);
        
        ResultSet rs = stm.getGeneratedKeys();
        if (rs.next()) {
            int newId = rs.getInt(1);
            System.out.println("New TimeLog ID: " + newId);
            return newId;
        }
    } catch (Exception ex) {
        System.err.println("LỖI startTimer: " + ex.getMessage());
        ex.printStackTrace();
    }
    return -1;
}

// Kết thúc timer (update EndTime và Hours)
public boolean stopTimer(int timeLogId) {
    String sql = "UPDATE TimeLogs " +
                 "SET EndTime = GETDATE(), " +
                 "    Hours = DATEDIFF(SECOND, StartTime, GETDATE()) / 3600.0 " +
                 "WHERE Id = ? AND EndTime IS NULL";
    try (PreparedStatement stm = connection.prepareStatement(sql)) {
        stm.setInt(1, timeLogId);
        return stm.executeUpdate() > 0;
    } catch (Exception ex) {
        ex.printStackTrace();
        return false;
    }
}

// Lấy tất cả time logs (đã có từ trước, nhưng cập nhật query để join fullName)
public List<TimeLog> getTimeLogsByProblemId(int problemId) {
    List<TimeLog> list = new ArrayList<>();
    String sql = "SELECT tl.Id, tl.TicketId, tl.UserId, tl.StartTime, tl.EndTime, tl.Hours, tl.LogDate, " +
                 "       u.FullName " +
                 "FROM TimeLogs tl " +
                 "LEFT JOIN Users u ON tl.UserId = u.Id " +
                 "WHERE tl.TicketId = ? " +
                 "ORDER BY tl.StartTime DESC";
    try (PreparedStatement stm = connection.prepareStatement(sql)) {
        stm.setInt(1, problemId);
        ResultSet rs = stm.executeQuery();
        while (rs.next()) {
            TimeLog log = new TimeLog();
            log.setId(rs.getInt("Id"));
            log.setTicketId(rs.getInt("TicketId"));
            log.setUserId(rs.getInt("UserId"));
            log.setStartTime(rs.getTimestamp("StartTime"));
            log.setEndTime(rs.getTimestamp("EndTime"));
            log.setHours(rs.getDouble("Hours"));
            log.setLogDate(rs.getDate("LogDate"));
            log.setFullName(rs.getString("FullName"));
            list.add(log);
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
    return list;
}
    
}
