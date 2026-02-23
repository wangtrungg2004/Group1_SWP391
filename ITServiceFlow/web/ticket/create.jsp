<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create New Ticket</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .hidden-section { display: none; }
    </style>
</head>
<body class="bg-light">

<div class="container mt-5">
    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Submit a New Ticket</h4>
        </div>
        <div class="card-body">
            
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/ticket/create" method="POST" id="ticketForm">
                
                <div class="mb-3">
                    <label class="form-label fw-bold">How can we help you?</label>
                    <select name="ticketType" id="ticketType" class="form-select" onchange="toggleFormFields()" required>
                        <option value="Incident" selected>Report an Issue (Something is broken)</option>
                        <option value="ServiceRequest">Request a Service (I need something new)</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Title (Short Summary)</label>
                    <input type="text" name="title" class="form-control" placeholder="e.g., Cannot access email" required maxlength="255">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Detailed Description</label>
                    <textarea name="description" class="form-control" rows="4" placeholder="Please provide as much detail as possible..." required></textarea>
                </div>

                <div id="incidentSection">
                    <h5 class="text-secondary border-bottom pb-2 mt-4">Issue Details</h5>
                    
                    <div class="mb-3">
                        <label class="form-label">Category</label>
                        <select name="categoryId" id="incidentCategory" class="form-select incident-field" required>
                            <option value="">-- Select Category --</option>
                            <option value="1">Hardware (Laptop, PC, Monitor)</option>
                            <option value="2">Software (Windows, Office, ERP)</option>
                            <option value="3">Network & Internet</option>
                        </select>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Impact (How many people are affected?)</label>
                            <select name="impact" class="form-select incident-field" required>
                                <option value="3">Low </option>
                                <option value="2">Medium </option>
                                <option value="1">High </option>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Urgency (How fast do you need this fixed?)</label>
                            <select name="urgency" class="form-select incident-field" required>
                                <option value="3">Low (Can wait a few days)</option>
                                <option value="2">Medium (Need it today)</option>
                                <option value="1">High (Business is stopped!)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div id="requestSection" class="hidden-section">
                    <h5 class="text-secondary border-bottom pb-2 mt-4">Service Details</h5>
                    
                    <div class="mb-3">
                        <label class="form-label">Select from Service Catalog</label>
                        <select name="serviceCatalogId" id="serviceCatalog" class="form-select request-field">
                            <option value="">-- Select a Service --</option>
                            <option value="1">Request a new Laptop</option>
                            <option value="2">Request Software Installation</option>
                            <option value="3">VPN Access Request</option>
                        </select>
                    </div>
                </div>

                <div class="text-end mt-4">
                    <a href="${pageContext.request.contextPath}/ticket/list" class="btn btn-secondary me-2">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4">Submit Ticket</button>
                </div>

            </form>
        </div>
    </div>
</div>

<script>
    function toggleFormFields() {
        // Lấy giá trị loại Ticket (Incident hoặc ServiceRequest)
        var type = document.getElementById("ticketType").value;
        
        // Lấy các khu vực (div) và các input/select bên trong
        var incSection = document.getElementById("incidentSection");
        var reqSection = document.getElementById("requestSection");
        
        var incFields = document.querySelectorAll(".incident-field");
        var reqFields = document.querySelectorAll(".request-field");

        if (type === "Incident") {
            // Hiện form Lỗi, Ẩn form Dịch vụ
            incSection.style.display = "block";
            reqSection.style.display = "none";
            
            // Bật thuộc tính 'required' cho Incident, tắt của Request
            incFields.forEach(f => f.setAttribute("required", "true"));
            reqFields.forEach(f => f.removeAttribute("required"));
            
        } else if (type === "ServiceRequest") {
            // Hiện form Dịch vụ, Ẩn form Lỗi
            incSection.style.display = "none";
            reqSection.style.display = "block";
            
            // Bật thuộc tính 'required' cho Request, tắt của Incident
            reqFields.forEach(f => f.setAttribute("required", "true"));
            incFields.forEach(f => f.removeAttribute("required"));
        }
    }

    // Chạy hàm 1 lần khi trang vừa load xong để đảm bảo form hiển thị đúng theo giá trị mặc định
    window.onload = function() {
        toggleFormFields();
    };
</script>

</body>
</html>