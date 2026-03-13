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
    <style>
        .form-control:invalid {
            border-color: #f44236 !important;
        }
        .was-validated .form-control:invalid {
            background-image: none;
        }
    </style>
</head>

<body class="">
    <div class="loader-bg">
        <div class="loader-track"><div class="loader-fill"></div></div>
    </div>

    <jsp:include page="../includes/sidebar.jsp"/>
    <jsp:include page="../includes/header.jsp"/>

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

                                            <form action="${pageContext.request.contextPath}/CreateTicket" method="POST" id="ticketForm" enctype="multipart/form-data" class="needs-validation" novalidate>
                                                
                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Bạn đang cần gì?</label>
                                                    <select name="ticketType" id="ticketType" class="form-control" onchange="toggleFormFields()" required>
                                                        <option value="Incident" ${ticketType_val == 'Incident' ? 'selected' : ''}>Báo lỗi (Máy móc, phần mềm bị hỏng)</option>
                                                        <option value="ServiceRequest" ${ticketType_val == 'ServiceRequest' ? 'selected' : ''}>Yêu cầu Dịch vụ (Xin cấp tài khoản, thiết bị mới)</option>
                                                    </select>
                                                </div>

                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Tiêu đề (Ngắn gọn)</label>
                                                    <input type="text" name="title" class="form-control" placeholder="Ví dụ: Không thể in tài liệu..." required minlength="5" maxlength="255" value="${title_val}">
                                                </div>

                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Mô tả chi tiết</label>
                                                    <textarea name="description" class="form-control" rows="5" placeholder="Vui lòng cung cấp càng nhiều chi tiết càng tốt..." required minlength="10">${description_val}</textarea>
                                                </div>

                                                <div class="form-group mb-3">
                                                    <label class="font-weight-bold">Đính kèm (tối đa 15MB/file)</label>
                                                    <input type="file" name="attachments" class="form-control-file" multiple>
                                                    <small class="form-text text-muted">Hỗ trợ: png, jpg, pdf, doc, docx, txt</small>
                                                    <c:if test="${not empty uploadWarning}">
                                                        <div class="text-warning mt-1">${uploadWarning}</div>
                                                    </c:if>
                                                </div>

                                                <div id="incidentSection">
                                                    <hr>
                                                    <h6 class="text-primary mb-3"><i class="feather icon-alert-triangle"></i> Chi tiết Sự cố</h6>
                                                    <div class="form-group mb-3">
                                                        <label>Danh mục (Category)</label>
                                                        <select name="categoryId" class="form-control incident-field" required>
                                                            <option value="">-- Chọn danh mục --</option>
                                                            <c:forEach items="${categoryList}" var="cat">
                                                                <option value="${cat.id}" ${categoryId_val == cat.id ? 'selected' : ''}>${cat.displayName}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-6 form-group">
                                                            <label>Mức độ ảnh hưởng (Impact)</label>
                                                            <select name="impact" class="form-control incident-field" required>
                                                                <option value="3" ${impact_val == '3' ? 'selected' : ''}>Low (Chỉ mình tôi)</option>
                                                                <option value="2" ${impact_val == '2' ? 'selected' : ''}>Medium (Cả phòng ban)</option>
                                                                <option value="1" ${impact_val == '1' ? 'selected' : ''}>High (Toàn công ty)</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-6 form-group">
                                                            <label>Độ khẩn cấp (Urgency)</label>
                                                            <select name="urgency" class="form-control incident-field" required>
                                                                <option value="3" ${urgency_val == '3' ? 'selected' : ''}>Low (Có thể đợi vài ngày)</option>
                                                                <option value="2" ${urgency_val == '2' ? 'selected' : ''}>Medium (Cần trong ngày)</option>
                                                                <option value="1" ${urgency_val == '1' ? 'selected' : ''}>High (Đang dừng việc, cần ngay!)</option>
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
                                                                <option value="${svc.id}" ${serviceCatalogId_val == svc.id ? 'selected' : ''}>${svc.name}</option>
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
            
            // Bootstrap validation logic
            var form = document.getElementById('ticketForm');
            form.addEventListener('submit', function(event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                    alert("Vui lòng điền đầy đủ các thông tin bắt buộc!");
                }
                form.classList.add('was-validated');
            }, false);
        };
    </script>
</body>
</html>