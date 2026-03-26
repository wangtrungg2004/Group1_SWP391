<%-- 
    Top bar (header) - thanh tr�n c�ng.
    S? d?ng request attribute "notifications" n?u c� (t�y ch?n).
    T�n user c� th? l?y t? session "user" (model.Users) ho?c "userName".
--%>
<%@page import="dao.NotificationDao"%>
<%@page import="model.Notifications"%>
<%@page import="java.util.List"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
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
        .noti-text-ellipsis {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: normal;
            word-break: break-word;
        }
    </style>
    <c:set var="role" value="${sessionScope.role}" />

    <div class="m-header">
        <a class="mobile-menu" id="mobile-collapse1" href="#!"><span></span></a>

        <c:choose>
            <c:when test="${role == 'Admin'}">
                <a href="${pageContext.request.contextPath}/AdminDashboard.jsp" class="b-brand">
            </c:when>
            <c:when test="${role == 'Manager'}">
                <a href="${pageContext.request.contextPath}/ManagerDashboard" class="b-brand">
            </c:when>
            <c:when test="${role == 'IT Support'}">
                <a href="${pageContext.request.contextPath}/ITDashboard.jsp" class="b-brand">
            </c:when>
            <c:when test="${role == 'User'}">
                <a href="${pageContext.request.contextPath}/UserDashboard" class="b-brand">
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/Login" class="b-brand">
            </c:otherwise>
        </c:choose>

            <img src="${pageContext.request.contextPath}/assets/images/logo.svg" alt="" class="logo images">
            <img src="${pageContext.request.contextPath}/assets/images/logo-icon.svg" alt="" class="logo-thumb images">
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
<!--                    <div class="input-group">
                        <input type="text" id="m-search" class="form-control" placeholder="Search . . .">
                        <a href="#!" class="input-group-append search-close">
                            <i class="feather icon-x input-group-text"></i>
                        </a>
                        <span class="input-group-append search-btn btn btn-primary">
                            <i class="feather icon-search input-group-text"></i>
                        </span>
                    </div>-->
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
                                                        <p class="noti-text-ellipsis" title="${notification.message}">
                                                            <c:choose>
                                                                <c:when test="${fn:length(notification.message) > 120}">
                                                                    <c:out value="${fn:substring(notification.message, 0, 120)}"/>...
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:out value="${notification.message}"/>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </p>
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
