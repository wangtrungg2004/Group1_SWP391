<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Tạo Ticket Mới - ITServiceFlow</title>

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>

<body class="">
    <div class="loader-bg">
        <div class="loader-track"><div class="loader-fill"></div></div>
    </div>

    <jsp:include page="sidebar.jsp" />
    <jsp:include page="header.jsp" />

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    
                    <div class="page-header">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-10">Tạo Yêu Cầu Hỗ Trợ Mới</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item"><a href="#!">Tạo Ticket</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper">
                            
                            <div class="row">
                                <div class="col-sm-12 col-md-10 col-xl-8">
                                    <div class="card">
                                        <div class="card-header bg-light">
                                            <h5>Điền thông tin yêu cầu</h5>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty errorMessage}">
                                                <div class="alert alert-danger">${errorMessage}</div>
                                            </c:if>

                                            <form action="CreateTicket" method="POST" id="ticketForm">
                                                
                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Bạn đang cần gì?</label>
                                                    <select name="ticketType" id="ticketType" class="form-control" onchange="toggleFormFields()" required>
                                                        <option value="Incident" selected>Báo lỗi (Máy móc, phần mềm bị hỏng)</option>
                                                        <option value="ServiceRequest">Yêu cầu Dịch vụ (Xin cấp tài khoản, thiết bị mới)</option>
                                                    </select>
                                                </div>

                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Tiêu đề (Ngắn gọn)</label>
                                                    <input type="text" name="title" class="form-control" placeholder="Ví dụ: Không thể in tài liệu..." required maxlength="255">
                                                </div>

                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Mô tả chi tiết</label>
                                                    <textarea name="description" class="form-control" rows="5" placeholder="Vui lòng cung cấp càng nhiều chi tiết càng tốt..." required></textarea>
                                                </div>

                                                <div id="incidentSection">
                                                    <hr>
                                                    <h6 class="text-primary mb-3"><i class="feather icon-alert-triangle"></i> Chi tiết Sự cố</h6>
                                                    <div class="form-group mb-3">
                                                        <label>Danh mục (Category)</label>
                                                        <select name="categoryId" class="form-control incident-field" required>
    <option value="">-- Chọn danh mục lỗi --</option>
    <c:forEach items="${categoryList}" var="cat">
        <option value="${cat.id}">${cat.name}</option>
    </c:forEach>
</select>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-6 form-group">
                                                            <label>Mức độ ảnh hưởng (Impact)</label>
                                                            <select name="impact" class="form-control incident-field" required>
                                                                <option value="3">Low (Chỉ mình tôi)</option>
                                                                <option value="2">Medium (Cả phòng ban)</option>
                                                                <option value="1">High (Toàn công ty)</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-6 form-group">
                                                            <label>Độ khẩn cấp (Urgency)</label>
                                                            <select name="urgency" class="form-control incident-field" required>
                                                                <option value="3">Low (Có thể đợi vài ngày)</option>
                                                                <option value="2">Medium (Cần trong ngày)</option>
                                                                <option value="1">High (Đang dừng việc, cần ngay!)</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div id="requestSection" style="display: none;">
                                                    <hr>
                                                    <h6 class="text-success mb-3"><i class="feather icon-shopping-cart"></i> Chi tiết Dịch vụ</h6>
                                                    <div class="form-group mb-3">
                                                        <label>Danh mục dịch vụ (Service Catalog)</label>
                                                        <select name="serviceCatalogId" class="form-control request-field">
    <option value="">-- Chọn dịch vụ cần cấp --</option>
    <c:forEach items="${serviceList}" var="svc">
        <c:if test="${svc.isActive}">
            <option value="${svc.id}">${svc.name}</option>
        </c:if>
    </c:forEach>
</select>
                                                    </div>
                                                </div>

                                                <div class="text-right mt-4">
                                                    <button type="submit" class="btn btn-primary"><i class="feather icon-save"></i> Gửi Yêu Cầu</button>
                                                </div>
                                            </form>

                                        </div>
                                    </div>
                                </div>
                            </div>
                            </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
    
    <script>
        function toggleFormFields() {
            var type = document.getElementById("ticketType").value;
            var incSection = document.getElementById("incidentSection");
            var reqSection = document.getElementById("requestSection");
            var incFields = document.querySelectorAll(".incident-field");
            var reqFields = document.querySelectorAll(".request-field");

            if (type === "Incident") {
                incSection.style.display = "block";
                reqSection.style.display = "none";
                incFields.forEach(f => f.setAttribute("required", "true"));
                reqFields.forEach(f => f.removeAttribute("required"));
            } else {
                incSection.style.display = "none";
                reqSection.style.display = "block";
                reqFields.forEach(f => f.setAttribute("required", "true"));
                incFields.forEach(f => f.removeAttribute("required"));
            }
        }
        
        // Chạy khi load trang
        window.onload = function() {
            toggleFormFields();
        };
    </script>
</body>
</html>