<%-- 
    Top bar (header) - thanh trên cùng.
    S? d?ng request attribute "notifications" n?u có (tùy ch?n).
    Tên user có th? l?y t? session "user" (model.Users) ho?c "userName".
--%>
<%@page import="dao.NotificationDao"%>
<%@page import="model.Notifications"%>
<%@page import="java.util.List"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session != null && session.getAttribute("userId") != null 
        && request.getAttribute("headerNotifications") == null) 
    {
        Integer userId = (Integer) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        NotificationDao notificationDao = new NotificationDao();
        List<Notifications> list;
        if ("Admin".equals(role) || "Manager".equals(role)) {
            list = notificationDao.getAllNotifications();
        } else {
            list = notificationDao.getNotificationsByUserIdUnread(userId);
        }
        request.setAttribute("headerNotifications", list);
    }
%>
<!-- [ Header ] start -->
<header class="navbar pcoded-header navbar-expand-lg navbar-light headerpos-fixed">
    <style>
        .noti-body {
            overflow-y: auto;
        }
    </style>
    <div class="m-header">
        <a class="mobile-menu" id="mobile-collapse1" href="#!"><span></span></a>
        <a href="AdminDashboard.jsp" class="b-brand">
            <img src="assets/images/logo.svg" alt="" class="logo images">
            <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">
        </a>
    </div>
    <a class="mobile-menu" id="mobile-header" href="#!">
        <i class="feather icon-more-horizontal"></i>
    </a>
    <div class="collapse navbar-collapse">
        <a href="#!" class="mob-toggler"></a>
        <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                <div class="main-search open">
                    <div class="input-group">
                        <input type="text" id="m-search" class="form-control" placeholder="Search . . .">
                        <a href="#!" class="input-group-append search-close">
                            <i class="feather icon-x input-group-text"></i>
                        </a>
                        <span class="input-group-append search-btn btn btn-primary">
                            <i class="feather icon-search input-group-text"></i>
                        </span>
                    </div>
                </div>
            </li>
        </ul>
        <ul class="navbar-nav ml-auto">
            <li>
                <div class="dropdown">
                    <a class="dropdown-toggle" href="#" data-toggle="dropdown"><i class="icon feather icon-bell"></i></a>
                    <div class="dropdown-menu dropdown-menu-right notification">
                        <div class="noti-head">
                            <h6 class="d-inline-block m-b-0">Notifications</h6>
<!--                            <div class="float-right">
                                <a href="#!" class="m-r-10">mark as read</a>
                                <a href="#!">clear all</a>
                            </div>-->
                        </div>
                        <ul class="noti-body">
                            <c:choose>
                                <c:when test="${empty headerNotifications}">
                                    <li class="notification"><p class="text-muted m-2">No notifications</p></li>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${headerNotifications}" var="notification">
                                        <li class="notification">
                                            <a href="NotificationDetail?Id=${notification.id}" class="d-block text-decoration-none" style="color: inherit;">
                                                <div class="media">
                                                    <img class="img-radius" src="assets/images/user/avatar-1.jpg" alt="">
                                                    <div class="media-body">
                                                        <p>
                                                            <span class="n-time text-muted">
                                                                <i class="icon feather icon-clock m-r-10"></i>
                                                                <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                            </span>
                                                        </p>
                                                        <p><c:out value="${notification.message}"/></p>
                                                    </div>
                                                </div>
                                            </a>
                                        </li>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                        <c:choose>
                            <c:when test="${role eq 'User'}">
                                <div class="noti-footer">
                                    <a href="UserNotificationList">show all</a>
                                </div>
                            </c:when>
                            <c:when test="${role eq 'IT Support'}">
                                <div class="noti-footer">
                                    <a href="ITSupportNotificationList">show all</a>
                                </div>
                            </c:when>
                            <c:when test="${role eq 'Manager'}">
                                <div class="noti-footer">
                                    <a href="NotificationList">show all</a>
                                </div>
                            </c:when>
                        </c:choose>
                    </div>
                </div>
            </li>
            <li>
                <div class="dropdown drp-user">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="icon feather icon-settings"></i>
                    </a>
                    <div class="dropdown-menu dropdown-menu-right profile-notification">
                        <div class="pro-head">
                            <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User-Profile-Image">
                            <span>
                                <c:choose>
                                    <c:when test="${not empty sessionScope.user}">
                                        <c:out value="${sessionScope.user.fullName}" />
                                    </c:when>
                                    <c:otherwise>User</c:otherwise>
                                </c:choose>
                            </span>
                            <c:if test="${not empty role}">
                                <span style="display: block; font-size: 11px; color: #999;">
                                    <c:out value="${role}" />
                                </span>
                            </c:if>
                            <a href="Logout" class="dud-logout" title="Logout">
                                <i class="feather icon-log-out"></i>
                            </a>
                        </div>
                        <ul class="pro-body">
                            <li><a href="${pageContext.request.contextPath}/MyProfile" class="dropdown-item"><i class="feather icon-user"></i> My Profile</a></li>
                            <li><a href="${pageContext.request.contextPath}/Logout" class="dropdown-item"><i class="feather icon-log-out"></i> Logout</a></li>
                        </ul>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</header>
<!-- [ Header ] end -->
