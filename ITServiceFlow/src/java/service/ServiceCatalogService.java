/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

/**
 *
 * @author admin
 */
import dao.ServiceCatalogDao;
import model.ServiceCatalog;
import java.util.List;

/**
 * Service class for ServiceCatalog
 */
public class ServiceCatalogService {
    private ServiceCatalogDao dao = new ServiceCatalogDao();

    public List<ServiceCatalog> getAllServices() {
        return dao.getAllServices();
    }

    public ServiceCatalog getServiceById(int id) {
        return dao.getServiceById(id);
    }

    public boolean addService(ServiceCatalog sc) {
        if (sc.getName() == null || sc.getName().trim().isEmpty()) return false;
        return dao.addService(sc);
    }

    public boolean updateService(ServiceCatalog sc) {
        if (sc.getName() == null || sc.getName().trim().isEmpty()) return false;
        return dao.updateService(sc);
    }

    public boolean deleteService(int id) {
        return dao.deleteService(id);
    }

    public boolean toggleActive(int id, boolean isActive) {
        return dao.toggleActive(id, isActive);
    }
}







