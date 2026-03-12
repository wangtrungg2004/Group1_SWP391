<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Create Notification - ITServiceFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .pcoded-wrapper { max-width: 100% !important; width: 100% !important; margin: 0 !important; }
        .pcoded-main-container { width: 100% !important; margin-left: 264px !important; }
        .pcoded-navbar.navbar-collapsed ~ .pcoded-main-container { margin-left: 80px !important; }
        .pcoded-content, .pcoded-inner-content, .main-body, .page-wrapper { max-width: 100% !important; width: 100% !important; }
        body { overflow-x: hidden; }
        .form-actions { margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid #e9ecef; }
    </style>
</head>
<body class="">
    <div class="loader-bg"><div class="loader-track"><div class="loader-fill"></div></div></div>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">
                            <!-- breadcrumb -->
                            <div class="page-header">
                                <div class="page-block">
                                    <div class="row align-items-center">
                                        <div class="col-md-12">
                                            <div class="page-header-title">
                                                <h5 class="m-b-10">Create New Notification</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/NotificationList">Notification List</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Create New Notification</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- main content -->
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="m-0"><i class="feather icon-bell"></i> Create New Notification</h5>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">${error}</div>
                                            </c:if>
                                            <form method="post" action="${pageContext.request.contextPath}/CreateNotification" id="createNotifForm">
                                                <div class="form-group">
                                                    <label>Title <span class="text-danger">*</span></label>
                                                    <input type="text" name="title" class="form-control" required
                                                           placeholder="Notification title" value="${param.title}">
                                                </div>
                                                <div class="form-group">
                                                    <label>Message <span class="text-danger">*</span></label>
                                                    <textarea name="message" class="form-control" rows="3" required
                                                              placeholder="Content">${param.message}</textarea>
                                                </div>
                                                <div class="form-group">
                                                    <label>Type</label>
                                                    <select name="type" class="form-control">
                                                        <option value="General" ${param.type == 'General' ? 'selected' : ''}>General</option>
                                                        <option value="Problem" ${param.type == 'Problem' ? 'selected' : ''}>Problem</option>
                                                        <option value="Change" ${param.type == 'Change' ? 'selected' : ''}>Change</option>
                                                        <option value="Ticket" ${param.type == 'Ticket' ? 'selected' : ''}>Ticket</option>
                                                    </select>
                                                </div>
                                                <div class="form-group">
                                                    <label>Send to</label>
                                                    <select name="target" class="form-control" id="targetSelect">
                                                        <option value="one" ${param.target != 'all' ? 'selected' : ''}>One user</option>
                                                        <option value="all" ${param.target == 'all' ? 'selected' : ''}>All users</option>
                                                    </select>
                                                </div>
                                                <div class="form-group" id="userIdGroup">
                                                    <label>Chọn user</label>
                                                    <select name="userId" id="userIdInput" class="form-control">
                                                        <option value="">-- Chọn user --</option>
                                                        <c:forEach items="${users}" var="u">
                                                            <option value="${u.id}" ${param.userId == u.id ? 'selected' : ''}>
                                                                <c:out value="${u.fullName}"/> 
                                                                <c:if test="${not empty u.email}"> (<c:out value="${u.email}"/>)</c:if>
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="form-actions">
                                                    <button type="submit" class="btn btn-primary"><i class="feather icon-send"></i> Send Notification</button>
                                                    <a href="${pageContext.request.contextPath}/NotificationList" class="btn btn-secondary"><i class="feather icon-x"></i> Cancel</a>
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
        <script src="assets/plugins/jquery/js/jquery.min.js"></script>
	<script src="assets/js/vendor-all.min.js"></script>
	<script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
	<script src="assets/js/pcoded.min.js"></script>
    <script>
        $(document).ready(function () {
                $('.fixed-button').remove();
            });
        (function() {
            var targetSelect = document.getElementById('targetSelect');
            var userIdGroup = document.getElementById('userIdGroup');
            var userIdInput = document.getElementById('userIdInput');
            if (!targetSelect || !userIdGroup) return;
            function toggleUserId() {
                var isOne = targetSelect.value === 'one';
                userIdGroup.style.display = isOne ? 'block' : 'none';
                if (!isOne) userIdInput.removeAttribute('required');
                else userIdInput.setAttribute('required', 'required');
            }
            targetSelect.addEventListener('change', toggleUserId);
            toggleUserId();
        })();
        
            
    </script>
</body>
</html>
