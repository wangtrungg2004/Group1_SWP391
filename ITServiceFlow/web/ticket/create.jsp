<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    // Kiểm tra session đăng nhập
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
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

    <jsp:include page="../includes/header.jsp" />
    <jsp:include page="../includes/sidebar.jsp" />

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
                            
                            <div class="row justify-content-center">
                                <div class="col-sm-12 col-md-12 col-xl-10">
                                    <div class="card shadow-sm">
                                        <div class="card-header bg-light">
                                            <h5>Điền thông tin yêu cầu</h5>
                                        </div>
                                        <div class="card-body">
                                            
                                            <c:if test="${not empty errorMessage}">
                                                <div class="alert alert-danger">${errorMessage}</div>
                                            </c:if>

                                            <form action="${pageContext.request.contextPath}/CreateTicket" method="POST" id="ticketForm">
                                                
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
                                                    
                                                    <div class="row mb-3">
                                                        <div class="col-md-4">
                                                            <label>1. Lĩnh vực</label>
                                                            <select id="level1" class="form-control incident-field" onchange="loadLevel2()" required>
                                                                <option value="">-- Chọn Lĩnh vực --</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label>2. Nhóm lỗi</label>
                                                            <select id="level2" class="form-control incident-field" onchange="loadLevel3()" required disabled>
                                                                <option value="">-- Chọn Nhóm lỗi --</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label>3. Lỗi chi tiết</label>
                                                            <select name="categoryId" id="level3" class="form-control incident-field" required disabled>
                                                                <option value="">-- Chọn Lỗi chi tiết --</option>
                                                            </select>
                                                        </div>
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
                                                    
                                                    <div class="row mb-3">
                                                        <div class="col-md-6">
                                                            <label>1. Nhóm dịch vụ</label>
                                                            <select id="reqCategory" class="form-control request-field" onchange="loadServices()" required>
                                                                <option value="">-- Chọn Nhóm dịch vụ --</option>
                                                            </select>
                                                        </div>
                                                        
                                                        <div class="col-md-6">
                                                            <label>2. Dịch vụ chi tiết</label>
                                                            <select name="serviceCatalogId" id="reqService" class="form-control request-field" required disabled>
                                                                <option value="">-- Chọn Dịch vụ --</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="text-right mt-4">
                                                    <a href="${pageContext.request.contextPath}/Tickets" class="btn btn-secondary mr-2"><i class="feather icon-x"></i> Hủy</a>
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
        // ==========================================
        // 1. DATA TỪ SERVER TRUYỀN XUỐNG
        // ==========================================
        var categoryData = [
            <c:forEach items="${categoryList}" var="cat" varStatus="loop">
                { id: ${cat.id}, name: "${cat.name}", parentId: ${cat.parentId != null ? cat.parentId : 'null'}, level: ${cat.level} }${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        var serviceData = [
            <c:forEach items="${serviceList}" var="svc" varStatus="loop">
                { id: ${svc.id}, name: "${svc.name}", categoryId: ${svc.categoryId}, isActive: ${svc.isActive} }${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        var serviceCategoryIds = [...new Set(serviceData.filter(s => s.isActive).map(s => s.categoryId))];

        // ==========================================
        // 2. LOGIC ẨN/HIỆN THEO LOẠI TICKET
        // ==========================================
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

        // ==========================================
        // 3. LOGIC XỬ LÝ DROPDOWN INCIDENT (3 CẤP)
        // ==========================================
        function initCategoryDropdown() {
            var level1 = document.getElementById("level1");
            level1.innerHTML = '<option value="">-- Chọn Lĩnh vực --</option>'; 
            
            var incidentRoots = categoryData.filter(c => c.level === 1 && !serviceCategoryIds.includes(c.id));
            
            incidentRoots.forEach(c => {
                level1.add(new Option(c.name, c.id));
            });
        }

        function loadLevel2() {
            var l1Id = document.getElementById("level1").value;
            var l2 = document.getElementById("level2");
            var l3 = document.getElementById("level3");
            
            l2.innerHTML = '<option value="">-- Chọn Nhóm lỗi --</option>';
            l3.innerHTML = '<option value="">-- Chọn Lỗi chi tiết --</option>';
            l3.disabled = true;

            if (l1Id) {
                l2.disabled = false;
                categoryData.filter(c => c.parentId == l1Id).forEach(c => l2.add(new Option(c.name, c.id)));
            } else {
                l2.disabled = true;
            }
        }

        function loadLevel3() {
            var l2Id = document.getElementById("level2").value;
            var l3 = document.getElementById("level3");
            
            l3.innerHTML = '<option value="">-- Chọn Lỗi chi tiết --</option>';

            if (l2Id) {
                l3.disabled = false;
                categoryData.filter(c => c.parentId == l2Id).forEach(c => l3.add(new Option(c.name, c.id)));
            } else {
                l3.disabled = true;
            }
        }

        // ==========================================
        // 4. LOGIC XỬ LÝ DROPDOWN SERVICE (CASCADING 2 CẤP)
        // ==========================================
        function initServiceDropdown() {
            var reqCat = document.getElementById("reqCategory");
            reqCat.innerHTML = '<option value="">-- Chọn Nhóm dịch vụ --</option>';
            
            var serviceCategories = categoryData.filter(c => serviceCategoryIds.includes(c.id));
            
            serviceCategories.forEach(c => {
                reqCat.add(new Option(c.name, c.id));
            });
            // Đảm bảo không bị disabled
            reqCat.disabled = false;
        }

        function loadServices() {
            var catId = document.getElementById("reqCategory").value;
            var reqSvc = document.getElementById("reqService");
            
            reqSvc.innerHTML = '<option value="">-- Chọn Dịch vụ --</option>';

            if (catId) {
                reqSvc.disabled = false;
                serviceData.filter(s => s.categoryId == catId && s.isActive).forEach(s => reqSvc.add(new Option(s.name, s.id)));
            } else {
                reqSvc.disabled = true;
            }
        }

        // ==========================================
        // 5. KHỞI TẠO TẤT CẢ KHI TRANG TẢI XONG
        // ==========================================
        window.addEventListener('load', function() {
            toggleFormFields();       
            initCategoryDropdown();   
            initServiceDropdown();    
        });
    </script>
</body>
</html>