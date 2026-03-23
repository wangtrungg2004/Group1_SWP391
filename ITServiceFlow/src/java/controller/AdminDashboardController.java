package controller.Dashboard;

import Utils.DbContext;
import dao.AuditLogsDAO;
import dao.ChangeRequestDao;
import dao.CsatSurveyDAO;
import dao.ProblemDao;
import dao.SLATrackingDao;
import dao.TicketDAO;
import dao.UserDao;
import model.AuditLog;
import model.ChangeRequests;
import model.Tickets;
import model.Users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Admin Dashboard Controller
 * URL: /AdminDashboard
 * Role: Admin only
 *
 * Loads all 7 data zones:
 *   Zone 1 - System health KPIs (8 cards)
 *   Zone 2 - Ticket management (volume chart, status breakdown, type breakdown, unassigned)
 *   Zone 3 - SLA compliance (stats, near-breach list, compliance by priority)
 *   Zone 4 - Problem & Change management (status counts, RFC pending)
 *   Zone 5 - User & Agent management (role breakdown, top agents)
 *   Zone 6 - CSAT & service quality (avg, distribution, knowledge base)
 *   Zone 7 - Audit log & system activity (recent logs)
 */
@WebServlet(name = "AdminDashboardController", urlPatterns = {"/AdminDashboard"})
public class AdminDashboardController extends HttpServlet {

    // ── DAO instances ────────────────────────────────────────────────────────
    private final TicketDAO       ticketDAO       = new TicketDAO();
    private final UserDao         userDao         = new UserDao();
    private final ProblemDao      problemDao      = new ProblemDao();
    private final ChangeRequestDao changeDao      = new ChangeRequestDao();
    private final SLATrackingDao  slaDao          = new SLATrackingDao();
    private final CsatSurveyDAO   csatDAO         = new CsatSurveyDAO();
    private final AuditLogsDAO    auditDAO        = new AuditLogsDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth check ──────────────────────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        Users user = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");
        if (user == null || !"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        // ════════════════════════════════════════════════════════════════════
        // ZONE 1 — System Health KPIs
        // ════════════════════════════════════════════════════════════════════
        int totalTickets       = ticketDAO.getTotalTicket();
        int ticketsThisMonth   = ticketDAO.getTotalTicketThisMonth();
        int totalActiveUsers   = userDao.getTotalUser();
        int totalProblems      = problemDao.getTotalProblem();

        Map<String, Integer> slaStats = slaDao.getSLAStatistics();
        int slaBreached  = slaStats.getOrDefault("Breached",  0);
        int slaNearBreach= slaStats.getOrDefault("NearBreach",0);

        List<ChangeRequests> pendingRFCs = changeDao.getPendingRequests();
        int rfcPendingCount = pendingRFCs.size();

        double avgCsat = csatDAO.getAverageRating();

        List<Tickets> unassignedTickets = ticketDAO.get10UnassignedTickets();
        int unassignedCount = unassignedTickets.size();

        request.setAttribute("totalTickets",      totalTickets);
        request.setAttribute("ticketsThisMonth",  ticketsThisMonth);
        request.setAttribute("totalActiveUsers",  totalActiveUsers);
        request.setAttribute("totalProblems",     totalProblems);
        request.setAttribute("slaBreached",       slaBreached);
        request.setAttribute("slaNearBreach",     slaNearBreach);
        request.setAttribute("rfcPendingCount",   rfcPendingCount);
        request.setAttribute("avgCsat",           String.format("%.1f", avgCsat));
        request.setAttribute("unassignedCount",   unassignedCount);

        // ════════════════════════════════════════════════════════════════════
        // ZONE 2 — Ticket Management
        // ════════════════════════════════════════════════════════════════════
        // 2a. Volume chart last 6 months (reuse ManagerDashboard method)
        Map<String, Object> chartData = ticketDAO.getTicketStatsLast6Months();
        request.setAttribute("chartLabels",   chartData.get("labels"));
        request.setAttribute("chartResolved", chartData.get("daXuLy"));
        request.setAttribute("chartOpen",     chartData.get("chuaXuLy"));

        // 2b. Status breakdown (new method — see AdminTicketDAO below)
        Map<String, Integer> ticketsByStatus = getTicketCountByStatus();
        request.setAttribute("ticketsByStatus", ticketsByStatus);

        // 2c. Type breakdown
        Map<String, Integer> ticketsByType = getTicketCountByType();
        request.setAttribute("ticketsByType", ticketsByType);

        // 2d. Unassigned ticket list
        request.setAttribute("unassignedTickets", unassignedTickets);

        // ════════════════════════════════════════════════════════════════════
        // ZONE 3 — SLA Compliance
        // ════════════════════════════════════════════════════════════════════
        // 3a. Already loaded: slaStats (Breached, NearBreach, TotalTracked)
        int slaTotalTracked = slaStats.getOrDefault("TotalTracked", 0);
        int slaWithin = slaTotalTracked - slaBreached;
        int slaCompliancePct = slaTotalTracked > 0
                ? (int) Math.round(slaWithin * 100.0 / slaTotalTracked) : 0;
        request.setAttribute("slaTotalTracked",   slaTotalTracked);
        request.setAttribute("slaWithin",         slaWithin);
        request.setAttribute("slaCompliancePct",  slaCompliancePct);

        // 3b. Near-breach ticket list (top 5)
        List<Map<String, Object>> nearBreachList = slaDao.getNearBreachTickets(5);
        request.setAttribute("nearBreachList", nearBreachList);

        // 3c. Compliance by priority (new method — see below)
        Map<String, Object> slaByPriority = getSLAComplianceByPriority();
        request.setAttribute("slaByPriority", slaByPriority);

        // ════════════════════════════════════════════════════════════════════
        // ZONE 4 — Problem & Change Management
        // ════════════════════════════════════════════════════════════════════
        // 4a. Problem status counts
        Map<String, Integer> problemsByStatus = getProblemCountByStatus();
        request.setAttribute("problemsByStatus", problemsByStatus);

        // 4b. RFC status counts
        Map<String, Integer> rfcByStatus = getRFCCountByStatus();
        request.setAttribute("rfcByStatus", rfcByStatus);

        // 4c. Top 5 pending RFCs (already loaded pendingRFCs, take first 5)
        List<ChangeRequests> top5PendingRFCs = pendingRFCs.size() > 5
                ? pendingRFCs.subList(0, 5) : pendingRFCs;
        request.setAttribute("top5PendingRFCs", top5PendingRFCs);

        // ════════════════════════════════════════════════════════════════════
        // ZONE 5 — User & Agent Management
        // ════════════════════════════════════════════════════════════════════
        // 5a. User breakdown by role
        Map<String, Integer> usersByRole = getUserCountByRole();
        request.setAttribute("usersByRole", usersByRole);

        // 5b. Top agents this month
        List<Users> topAgents = userDao.getTopAgentsThisMonth();
        request.setAttribute("topAgents", topAgents);

        // 5c. Agent CSAT leaderboard
        List<Object[]> agentCsat = csatDAO.getAvgRatingByAgent();
        request.setAttribute("agentCsat", agentCsat);

        // ════════════════════════════════════════════════════════════════════
        // ZONE 6 — CSAT & Service Quality
        // ════════════════════════════════════════════════════════════════════
        int   totalSurveys   = csatDAO.getTotalSurveys();
        double responseRate  = csatDAO.getResponseRate();
        int[] ratingDist     = csatDAO.getRatingDistribution();

        request.setAttribute("csatAvg",        String.format("%.1f", avgCsat));
        request.setAttribute("csatTotal",       totalSurveys);
        request.setAttribute("csatResponseRate",String.format("%.0f", responseRate * 100));
        request.setAttribute("csatDist",        ratingDist);

        // ════════════════════════════════════════════════════════════════════
        // ZONE 7 — Audit Log & System Activity (Admin-only)
        // ════════════════════════════════════════════════════════════════════
        List<AuditLog> recentLogs = auditDAO.getRecentSystemLogs();
        // Limit to 10 most recent
        if (recentLogs != null && recentLogs.size() > 10) {
            recentLogs = recentLogs.subList(0, 10);
        }
        request.setAttribute("recentAuditLogs", recentLogs);

        // Forward to JSP
        request.getRequestDispatcher("/AdminDashboard.jsp").forward(request, response);
    }

    // ════════════════════════════════════════════════════════════════════════
    // INLINE QUERY HELPERS
    // (small SELECT ... GROUP BY queries that don't exist yet in DAOs)
    // ════════════════════════════════════════════════════════════════════════

    /**
     * Returns ticket count grouped by Status.
     * Key order: New, Open, Pending, In Progress, Resolved, Closed
     */
    private Map<String, Integer> getTicketCountByStatus() {
        Map<String, Integer> result = new LinkedHashMap<>();
        // Pre-fill with 0 so JSP always has all keys
        for (String s : new String[]{"New","Open","Pending","In Progress","Resolved","Closed"}) {
            result.put(s, 0);
        }
        String sql = "SELECT Status, COUNT(*) AS cnt FROM [dbo].[Tickets] GROUP BY Status";
        try (Connection conn = new DbContext() {
                { /* expose connection */ }
                public Connection get() { return connection; }
             }.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("Status");
                int cnt = rs.getInt("cnt");
                if (status != null) result.put(status, cnt);
            }
        } catch (SQLException e) {
            System.err.println("[AdminDashboard] getTicketCountByStatus: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns ticket count grouped by TicketType.
     */
    private Map<String, Integer> getTicketCountByType() {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT TicketType, COUNT(*) AS cnt FROM [dbo].[Tickets] GROUP BY TicketType ORDER BY cnt DESC";
        try (Connection conn = new DbContext() {
                public Connection get() { return connection; }
             }.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String type = rs.getString("TicketType");
                int cnt = rs.getInt("cnt");
                if (type != null) result.put(type, cnt);
            }
        } catch (SQLException e) {
            System.err.println("[AdminDashboard] getTicketCountByType: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns problem count grouped by Status.
     */
    private Map<String, Integer> getProblemCountByStatus() {
        Map<String, Integer> result = new LinkedHashMap<>();
        for (String s : new String[]{"New","Under Investigation","Pending","Approved","Resolved","Rejected","Closed"}) {
            result.put(s, 0);
        }
        String sql = "SELECT Status, COUNT(*) AS cnt FROM [dbo].[Problems] GROUP BY Status";
        try (Connection conn = new DbContext() {
                public Connection get() { return connection; }
             }.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("Status");
                int cnt = rs.getInt("cnt");
                if (status != null) result.put(status, result.getOrDefault(status, 0) + cnt);
            }
        } catch (SQLException e) {
            System.err.println("[AdminDashboard] getProblemCountByStatus: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns RFC count grouped by Status.
     */
    private Map<String, Integer> getRFCCountByStatus() {
        Map<String, Integer> result = new LinkedHashMap<>();
        for (String s : new String[]{"Draft","Pending Approval","Approved","In Progress","Completed","Rejected","RolledBack"}) {
            result.put(s, 0);
        }
        String sql = "SELECT Status, COUNT(*) AS cnt FROM [dbo].[ChangeRequests] GROUP BY Status";
        try (Connection conn = new DbContext() {
                public Connection get() { return connection; }
             }.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("Status");
                int cnt = rs.getInt("cnt");
                if (status != null) result.put(status, result.getOrDefault(status, 0) + cnt);
            }
        } catch (SQLException e) {
            System.err.println("[AdminDashboard] getRFCCountByStatus: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns SLA compliance % grouped by Priority level (P1–P4).
     * Returns Map with keys: P1_total, P1_breached, P1_pct, P2_...  etc.
     */
    private Map<String, Object> getSLAComplianceByPriority() {
        Map<String, Object> result = new HashMap<>();
        String sql =
            "SELECT p.Level AS PriorityLevel, " +
            "  COUNT(st.Id) AS Total, " +
            "  SUM(CASE WHEN st.IsBreached = 1 THEN 1 ELSE 0 END) AS Breached " +
            "FROM [dbo].[SLATracking] st " +
            "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id " +
            "JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id " +
            "GROUP BY p.Level " +
            "ORDER BY p.Level";
        try (Connection conn = new DbContext() {
                public Connection get() { return connection; }
             }.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String lvl = rs.getString("PriorityLevel");  // P1, P2, P3, P4
                int total    = rs.getInt("Total");
                int breached = rs.getInt("Breached");
                int pct = total > 0 ? (int) Math.round((total - breached) * 100.0 / total) : 0;
                result.put(lvl + "_total",    total);
                result.put(lvl + "_breached", breached);
                result.put(lvl + "_pct",      pct);
            }
        } catch (SQLException e) {
            System.err.println("[AdminDashboard] getSLAComplianceByPriority: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns active user count grouped by Role.
     */
    private Map<String, Integer> getUserCountByRole() {
        Map<String, Integer> result = new LinkedHashMap<>();
        for (String r : new String[]{"IT Support","Manager","EndUser","Admin"}) {
            result.put(r, 0);
        }
        String sql = "SELECT Role, COUNT(*) AS cnt FROM [dbo].[Users] WHERE IsActive = 1 GROUP BY Role ORDER BY cnt DESC";
        try (Connection conn = new DbContext() {
                public Connection get() { return connection; }
             }.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String r = rs.getString("Role");
                int cnt  = rs.getInt("cnt");
                if (r != null) result.put(r, cnt);
            }
        } catch (SQLException e) {
            System.err.println("[AdminDashboard] getUserCountByRole: " + e.getMessage());
        }
        return result;
    }
}