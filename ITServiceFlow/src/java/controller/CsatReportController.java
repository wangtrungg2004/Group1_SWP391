package controller;

import dao.CsatSurveyDAO;
import model.CsatSurvey;
import model.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller cho trang CSAT Report Dashboard.
 * URL: /CsatReport
 * Role: Manager
 *
 * Load:
 *  - avgRating        : điểm trung bình toàn hệ thống
 *  - totalSurveys     : tổng số đánh giá
 *  - responseRate     : tỉ lệ phản hồi (%)
 *  - ratingDist       : int[5] phân bố 1→5 sao
 *  - surveys          : danh sách tất cả survey (có join ticket + user + agent)
 *  - agentRatings     : List<Object[]> [agentName, avgRating, totalSurveys]
 */
@WebServlet(name = "CsatReport", urlPatterns = {"/CsatReport"})
public class CsatReportController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        Users user = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (user == null || (!"Manager".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        CsatSurveyDAO dao = new CsatSurveyDAO();

        // 1. KPI tổng quan
        double avgRating    = dao.getAverageRating();
        int    totalSurveys = dao.getTotalSurveys();
        double responseRate = dao.getResponseRate();
        int[]  ratingDist   = dao.getRatingDistribution();   // index 0 = 1 sao ... index 4 = 5 sao

        // 2. Danh sách tất cả survey (bảng chi tiết)
        List<CsatSurvey> surveys = dao.getAllSurveys();

        // 3. Điểm trung bình theo agent (leaderboard)
        List<Object[]> agentRatings = dao.getAvgRatingByAgent();

        // Truyền sang JSP
        request.setAttribute("avgRating",    avgRating);
        request.setAttribute("totalSurveys", totalSurveys);
        request.setAttribute("responseRate", responseRate);
        request.setAttribute("ratingDist",   ratingDist);
        request.setAttribute("surveys",      surveys);
        request.setAttribute("agentRatings", agentRatings);

        request.getRequestDispatcher("/CsatReport.jsp").forward(request, response);
    }
}