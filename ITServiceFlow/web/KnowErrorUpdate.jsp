<%--
    Document   : KnowErrorUpdate
    Update Known Error - Title and Work Around only.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="dao.NotificationDao" %>
<%@ page import="model.Notifications" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    List<Notifications> notifications = new java.util.ArrayList<>();
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId != null) {
        NotificationDao notificationDao = new NotificationDao();
        notifications = notificationDao.getAllNotifications();
    }
    request.setAttribute("notifications", notifications);
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Update Known Error - IT Service Flow</title>
    <!--[if lt IE 11]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="Update Known Error - IT Service Flow" />
    <meta name="keywords" content="known error, update, IT service" />
    <meta name="author" content="Codedthemes" />

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
    .pcoded-wrapper { max-width: 100% !important; width: 100% !important; margin: 0 !important; }
    .pcoded-main-container { width: 100% !important; margin-left: 264px !important; }
    .pcoded-navbar.navbar-collapsed ~ .pcoded-main-container { margin-left: 80px !important; }
    .pcoded-content, .pcoded-inner-content, .main-body, .page-wrapper { max-width: 100% !important; width: 100% !important; }
    body { overflow-x: hidden; }
    </style>
</head>

<body class="">
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>
    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">
                            <div class="page-header">
                                <div class="page-block">
                                    <div class="row align-items-center">
                                        <div class="col-md-12">
                                            <div class="page-header-title">
                                                <h5 class="m-b-10">Update Known Error</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="index.html"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="KnowErrorList">Known Error List</a></li>
                                                <li class="breadcrumb-item"><a href="KnowErrorUpdate?Id=${param.Id}">Update</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5><i class="feather icon-edit"></i> Update Known Error</h5>
                                            <div class="card-header-right">
                                                <c:if test="${not empty knowError}">
                                                    <a href="KnowErrorDetail?Id=${knowError.id}" class="btn btn-sm btn-secondary">
                                                        <i class="feather icon-eye"></i> View Detail
                                                    </a>
                                                </c:if>
                                                <a href="KnowErrorList" class="btn btn-sm btn-secondary">
                                                    <i class="feather icon-arrow-left"></i> Back to List
                                                </a>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">${error}</div>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${empty knowError}">
                                                    <div class="alert alert-warning">
                                                        <h4>Known Error not found</h4>
                                                        <p>The Known Error you are looking for does not exist or the link is invalid.</p>
                                                        <a href="KnowErrorList" class="btn btn-primary">Back to Known Error List</a>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <form method="post" action="KnowErrorUpdate" id="updateKnowErrorForm">
                                                        <input type="hidden" name="Id" value="${knowError.id}">
                                                        <div class="form-group">
                                                            <label for="Title"><strong>Title <span class="text-danger">*</span></strong></label>
                                                            <input type="text" class="form-control" id="Title" name="Title"
                                                                   value="${knowError.title}" required placeholder="Known error title">
                                                        </div>
                                                        <div class="form-group">
                                                            <label for="WorkAround"><strong>Work Around <span class="text-danger">*</span></strong></label>
                                                            <textarea class="form-control" id="WorkAround" name="WorkAround" rows="5"
                                                                      required placeholder="Steps or workaround...">${knowError.workAround}</textarea>
                                                        </div>
                                                        <button type="submit" class="btn btn-primary">Save</button>
                                                        <a href="KnowErrorDetail?Id=${knowError.id}" class="btn btn-secondary">Cancel</a>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
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
            $('#updateKnowErrorForm').on('submit', function(e) {
                var title = $('#Title').val().trim();
                var workAround = $('#WorkAround').val().trim();
                if (!title) {
                    e.preventDefault();
                    alert('Please enter a title for the Known Error.');
                    $('#Title').focus();
                    return false;
                }
                if (!workAround) {
                    e.preventDefault();
                    alert('Please enter the work around.');
                    $('#WorkAround').focus();
                    return false;
                }
            });
        });
    </script>
</body>
</html>
