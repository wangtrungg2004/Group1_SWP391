package controller.ticket.user;

import dao.AssetsDAO;
import dao.CategoryDao;
import dao.ServiceCatalogDao;
import dao.TicketAssetsDAO;
import dao.TicketDAO;
import model.Assets;
import model.ServiceCatalog;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 15,      // 15MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
@WebServlet(name = "CreateTicket", urlPatterns = { "/CreateTicket" })
public class TicketCreateController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        CategoryDao catDao = new CategoryDao();
        ServiceCatalogDao svcDao = new ServiceCatalogDao();

        request.setAttribute("categoryList", catDao.getAllCategories());
        request.setAttribute("serviceList", svcDao.getAllServices());

        request.getRequestDispatcher("/ticket/create.jsp").forward(request, response);
    }

    private int calculatePriority(int impact, int urgency) {
        int score = impact + urgency;
        if (score <= 2) {
            return 1; 
        }
        if (score <= 4) {
            return 2; 
        }
        if (score <= 5) {
            return 3; 
        }
        return 4; 
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String ticketType = request.getParameter("ticketType");

        Tickets t = new Tickets();
        t.setTicketNumber("TKT-" + System.currentTimeMillis());
        t.setTicketType(ticketType);
        t.setTitle(request.getParameter("title"));
        t.setDescription(request.getParameter("description"));
        t.setCreatedBy(currentUser.getId());
        t.setLocationId(currentUser.getLocationId() > 0 ? currentUser.getLocationId() : 1);

        if ("Incident".equals(ticketType)) {

            String catStr = request.getParameter("categoryId");

            int impact = Integer.parseInt(request.getParameter("impact"));
            int urgency = Integer.parseInt(request.getParameter("urgency"));

            int calculatedPriority = calculatePriority(impact, urgency);

            if (catStr == null || catStr.isEmpty() || "null".equals(catStr)) {
                request.setAttribute("errorMessage", "Vui lòng chọn đầy đủ đến mục 'Lỗi chi tiết'.");
                doGet(request, response);
                return;
            }

            try {
                t.setCategoryId(Integer.parseInt(catStr));
                t.setImpact(impact);
                t.setUrgency(urgency);
                t.setPriorityId(calculatedPriority);

                t.setServiceCatalogId(null);
                t.setRequiresApproval(false);

            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Dữ liệu độ khẩn cấp/ảnh hưởng không hợp lệ.");
                doGet(request, response);
                return;
            }

        } else if ("ServiceRequest".equals(ticketType)) {

            String serviceStr = request.getParameter("serviceCatalogId");

            if (serviceStr == null || serviceStr.isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng chọn dịch vụ cụ thể.");
                doGet(request, response);
                return;
            }

            try {
                int serviceId = Integer.parseInt(serviceStr);
                ServiceCatalogDao svcDao = new ServiceCatalogDao();
                ServiceCatalog svc = svcDao.getServiceById(serviceId);

                if (svc != null) {
                    t.setServiceCatalogId(serviceId);
                    t.setCategoryId(svc.getCategoryId());
                    t.setRequiresApproval(svc.isRequiresApproval());

                    t.setImpact(null);
                    t.setUrgency(null);
                    t.setPriorityId(null);
                } else {
                    request.setAttribute("errorMessage", "Dịch vụ không tồn tại trong hệ thống.");
                    doGet(request, response);
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Lỗi dữ liệu dịch vụ.");
                doGet(request, response);
                return;
            }
        }

        String assetTag = request.getParameter("assetTag");
        if (assetTag == null || assetTag.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập Asset tag.");
            doGet(request, response);
            return;
        }

        AssetsDAO assetsDAO = new AssetsDAO();
        Assets asset = assetsDAO.getAssetByTag(assetTag.trim());
        if (asset == null) {
            request.setAttribute("errorMessage", "Asset tag is wrong.");
            preserveFormForError(request, ticketType);
            doGet(request, response);
            return;
        }

        TicketDAO dao = new TicketDAO();
        String isCreated = dao.createTicket(t);

        if ("ok".equals(isCreated)) {
            Tickets created = dao.getTicketByNumber(t.getTicketNumber());
            if (created != null) {
                TicketAssetsDAO ticketAssetsDAO = new TicketAssetsDAO();
                boolean linked = ticketAssetsDAO.addLink(created.getId(), asset.getId());
                if (!linked) {
                    request.setAttribute("errorMessage", "Could not link asset to ticket. Please try again from ticket detail.");
                    preserveFormForError(request, ticketType);
                    doGet(request, response);
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/Tickets?created=1");
                return;
            }
            request.setAttribute("errorMessage", "Could not load the new ticket after creation.");
            preserveFormForError(request, ticketType);
            doGet(request, response);
            return;
        } else {
            preserveFormForError(request, ticketType);
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + isCreated);
            doGet(request, response);
        }

    }

    private void preserveFormForError(HttpServletRequest request, String ticketType) {
        request.setAttribute("ticketType_val", ticketType);
        request.setAttribute("title_val", request.getParameter("title"));
        request.setAttribute("description_val", request.getParameter("description"));
        request.setAttribute("categoryId_val", request.getParameter("categoryId"));
        request.setAttribute("impact_val", request.getParameter("impact"));
        request.setAttribute("urgency_val", request.getParameter("urgency"));
        request.setAttribute("serviceCatalogId_val", request.getParameter("serviceCatalogId"));
        request.setAttribute("assetTag_val", request.getParameter("assetTag"));
    }
}