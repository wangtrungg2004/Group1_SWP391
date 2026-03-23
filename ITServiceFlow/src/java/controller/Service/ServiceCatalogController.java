/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ServiceCatalog;
import model.Users;
import service.ServiceCatalogService;

import java.io.IOException;

/**
 * Controller for ServiceCatalog CRUD operations
 */
@WebServlet(name = "ServiceCatalogController", urlPatterns = {"/ServiceCatalog"})
public class ServiceCatalogController extends HttpServlet {

    private ServiceCatalogService service = new ServiceCatalogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                // Lấy danh sách dịch vụ
                request.setAttribute("services", service.getAllServices());
                request.getRequestDispatcher("ServiceCatalog.jsp").forward(request, response);
                break;

            case "edit":
                // Load form sửa
                int editId = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("service", service.getServiceById(editId));
                request.getRequestDispatcher("ServiceCatalog.jsp").forward(request, response);
                break;

            case "delete":
                // Xóa dịch vụ
                int deleteId = Integer.parseInt(request.getParameter("id"));
                service.deleteService(deleteId);
                response.sendRedirect("ServiceCatalog?action=list&msg=deleted");
                break;

            case "toggle":
                // Ẩn/Hiện dịch vụ
                int toggleId = Integer.parseInt(request.getParameter("id"));
                boolean isActive = Boolean.parseBoolean(request.getParameter("isActive"));
                service.toggleActive(toggleId, !isActive); // đảo trạng thái
                response.sendRedirect("ServiceCatalog?action=list&msg=updated");
                break;

            case "add":
                // Load form thêm mới
                request.getRequestDispatcher("ServiceCatalog.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect("ServiceCatalog?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            // Thêm dịch vụ mới
            ServiceCatalog sc = new ServiceCatalog();
            sc.setName(request.getParameter("name"));
            sc.setDescription(request.getParameter("description"));
            sc.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            sc.setRequiresApproval(request.getParameter("requiresApproval") != null);
            sc.setEstimatedDeliveryDays(Integer.parseInt(request.getParameter("estimatedDeliveryDays")));
            sc.setIsActive(request.getParameter("isActive") != null);

            boolean success = service.addService(sc);
            if (success) {
                response.sendRedirect("ServiceCatalog?action=list&msg=added");
            } else {
                request.setAttribute("error", "Thêm dịch vụ thất bại!");
                request.getRequestDispatcher("ServiceCatalog.jsp").forward(request, response);
            }

        } else if ("edit".equals(action)) {
            // Cập nhật dịch vụ
            ServiceCatalog sc = new ServiceCatalog();
            sc.setId(Integer.parseInt(request.getParameter("id")));
            sc.setName(request.getParameter("name"));
            sc.setDescription(request.getParameter("description"));
            sc.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            sc.setRequiresApproval(request.getParameter("requiresApproval") != null);
            sc.setEstimatedDeliveryDays(Integer.parseInt(request.getParameter("estimatedDeliveryDays")));
            sc.setIsActive(request.getParameter("isActive") != null);

            boolean success = service.updateService(sc);
            if (success) {
                response.sendRedirect("ServiceCatalog?action=list&msg=updated");
            } else {
                request.setAttribute("error", "Cập nhật dịch vụ thất bại!");
                request.setAttribute("service", sc);
                request.getRequestDispatcher("ServiceCatalog.jsp").forward(request, response);
            }
        }
    }
}