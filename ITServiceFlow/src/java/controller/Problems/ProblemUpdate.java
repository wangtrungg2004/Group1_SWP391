/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import dao.TicketDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import model.Problems;
import model.Tickets;
import service.ProblemService;
import service.UserService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "ProblemUpdate", urlPatterns = { "/ProblemUpdate" })
public class ProblemUpdate extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProblemUpdate</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProblemUpdate at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the
    // + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    ProblemService problemService = new ProblemService();
    UserService userService = new UserService();
    TicketDAO ticketService = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ProblemId = request.getParameter("Id");
        if (ProblemId == null || ProblemId.trim().isEmpty()) {
            request.setAttribute("error", "Problem ID is required");
            request.getRequestDispatcher("ProblemUpdate.jsp").forward(request, response);
            return;
        }
        try {
            int id = Integer.parseInt(ProblemId);
            Problems pro = problemService.getProblemById(id);
            if (pro == null) {
                request.setAttribute("error", "Problem not found with ID: " + id);
                request.getRequestDispatcher("ProblemUpdate.jsp").forward(request, response);
                return;
            }

            if (pro.getStatus().equals("PENDING") || pro.getStatus().equals("APPROVED")) {
                response.sendRedirect("ProblemDetail?Id=" + pro.getId() + "&error=cannot_edit");
                return;
            }

            List<Tickets> tickets = ticketService.getAllTickets();
            List<Tickets> relatedTickets = problemService.getRelatedTicket(id);

            request.setAttribute("tickets", tickets);
            request.setAttribute("relatedTickets", relatedTickets);
            request.setAttribute("problem", pro);
            request.setAttribute("assignees", userService.getAllUser());
            Object roleObj = request.getSession().getAttribute("role");
            request.setAttribute("role", roleObj != null ? roleObj : "");
            request.getRequestDispatcher("ProblemUpdate.jsp").forward(request, response);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // String ProblemId = request.getParameter("Id");
        // String TicketNumber = request.getParameter("TicketNumber");
        // String Title = request.getParameter("Title");
        // String Description = request.getParameter("Description");
        // String rootCause = request.getParameter("RootCause");
        // String workaround = request.getParameter("Workaround");
        // String status = request.getParameter("Status");
        // String assignedToStr = request.getParameter("AssignedTo");
        //

        try {
            int id = Integer.parseInt(request.getParameter("Id"));
            Problems pro = problemService.getProblemById(id);
            if (pro == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Problem not found");
                return;
            }

            List<Integer> ticketIds = new ArrayList<>();
            String[] arr = request.getParameterValues("ticketIds");
            if (arr != null) {
                for (String s : arr) {
                    if (s == null || s.trim().isEmpty())
                        continue;
                    try {
                        ticketIds.add(Integer.parseInt(s.trim()));
                    } catch (NumberFormatException e) {
                    }
                }
            }
            problemService.unlinkAllProblemTickets(id);
            if (!ticketIds.isEmpty()) {
                problemService.linkProblemTicket(id, ticketIds);
            }

            String role = (String) request.getSession().getAttribute("role");
            if ("IT Support".equals(role)) {
                pro.setRootCause(request.getParameter("RootCause"));
                pro.setWorkaround(request.getParameter("Workaround"));
            } else {
                pro.setTitle(request.getParameter("Title"));
                pro.setDescription(request.getParameter("Description"));
                pro.setRootCause(request.getParameter("RootCause"));
                pro.setWorkaround(request.getParameter("Workaround"));
                pro.setStatus(request.getParameter("Status"));
                String assignedToStr = request.getParameter("AssignedTo");
                if (assignedToStr != null && !assignedToStr.isEmpty()) {
                    pro.setAssignedTo(Integer.parseInt(assignedToStr));
                }
            }
            boolean success = problemService.updateProblem(pro);
            if (success) {
                response.sendRedirect("ProblemDetail?Id=" + id);
            } else {
                request.setAttribute("error", "Update failed");
                request.setAttribute("problem", pro);
                request.getRequestDispatcher("ProblemUpdate.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Id format");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
