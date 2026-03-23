package controller;

import dao.TicketAssetsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "TicketUnlinkCIServlet", urlPatterns = {"/TicketUnlinkCIServlet"})
public class TicketUnlinkCIServlet extends HttpServlet {

    private TicketAssetsDAO ticketAssetsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        ticketAssetsDAO = new TicketAssetsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String ticketIdStr = request.getParameter("ticketId");
        String assetIdStr = request.getParameter("assetId");

        int ticketId = 0;
        int assetId = 0;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
            assetId = Integer.parseInt(assetIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Invalid+ticketId+or+assetId");
            return;
        }

        boolean success = ticketAssetsDAO.removeLink(ticketId, assetId);

        if (success) {
            response.sendRedirect("Long_TicketListServlet?successMessage=Unlinked+asset+from+ticket+successfully");
        } else {
            response.sendRedirect("Long_TicketListServlet?errorMessage=Failed+to+unlink+asset+from+ticket");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

