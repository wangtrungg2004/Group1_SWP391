/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.DepartmentDao;
import java.util.List;
import model.Department;

/**
 *
 * @author DELL
 */
public class DepartmentService {
    private DepartmentDao dao = new DepartmentDao();
    
    public List<Department> getAllDepartments() {
        return dao.getAllDepartments();
    }
    
    public Department getDepartmentById(int id) {
        return dao.getDepartmentById(id);
    }
    
    public boolean createDepartment(Department department) {
        if (department == null) {
            System.err.println("Department object is null");
            return false;
        }
        if (department.getName() == null || department.getName().trim().isEmpty()) {
            System.err.println("Department name is null or empty");
            return false;
        }
        
        return dao.createDepartment(department);
    }
}
