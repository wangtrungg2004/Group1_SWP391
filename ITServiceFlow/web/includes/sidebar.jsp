<<<<<<< HEAD
<%-- Left sidebar - ph�n quy?n theo session attribute "role" --%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="role" value="${sessionScope.role}" />
<c:choose>
    <c:when test="${role == 'Admin'}">
        <c:set var="dashboardHref" value="${pageContext.request.contextPath}/AdminDashboard" />
    </c:when>
    <c:when test="${role == 'Manager'}">
        <c:set var="dashboardHref" value="${pageContext.request.contextPath}/ManagerDashboard" />
    </c:when>
    <c:when test="${role == 'IT Support'}">
        <c:set var="dashboardHref" value="${pageContext.request.contextPath}/ITDashboard" />
    </c:when>
    <c:when test="${role == 'User'}">
        <c:set var="dashboardHref" value="${pageContext.request.contextPath}/UserDashboard" />
    </c:when>
    <c:otherwise>
        <c:set var="dashboardHref" value="${pageContext.request.contextPath}/Login" />
    </c:otherwise>
</c:choose>
<!-- [ navigation menu ] start -->
<nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
    <div class="navbar-wrapper ">
        <c:set var="role" value="${sessionScope.role}" />

        <div class="navbar-brand header-logo">
            <a href="${dashboardHref}" class="b-brand">
                <img src="assets/images/logo.svg" alt="" class="logo images">
                <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">
            </a>
            <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
        </div>
        <div class="navbar-content scroll-div">
            <ul class="nav pcoded-inner-navbar">
               

                <!-- ??? USER MENU ??????????????????????????????????????? -->
                <c:if test="${role == 'User'}">
                    <li class="nav-item pcoded-menu-caption"><label>IT Service</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/UserDashboard" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/CreateTicket" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-plus-circle"></i></span>
                            <span class="pcoded-mtext">Create New Ticket</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/Tickets" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-list"></i></span>
                            <span class="pcoded-mtext">My Tickets</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/KnowledgeSearch" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-inbox"></i></span>
                            <span class="pcoded-mtext">Knowledge Base</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/KnowErrorList" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-alert-triangle"></i></span>
                            <span class="pcoded-mtext">Known Errors</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/TemporaryAccessRequest" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-unlock"></i></span>
                            <span class="pcoded-mtext">Temporary Access</span>
                        </a>
                    </li>
                </c:if>

                <!-- ??? IT SUPPORT MENU ?????????????????????????????????? -->
                <c:if test="${role == 'IT Support'}">

                    <li class="nav-item pcoded-menu-caption"><label>Overview</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/ITDashboard" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>

                    <li class="nav-item pcoded-menu-caption"><label>Ticket Management</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/Queues" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-inbox"></i></span>
                            <span class="pcoded-mtext">Ticket Queues</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/Long_TicketListServlet" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-inbox"></i></span>
                            <span class="pcoded-mtext">Ticket - Assets</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="CreateTicket" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-plus-circle"></i></span>
                            <span class="pcoded-mtext">Create Ticket</span>
                        </a>
                    </li>

                    <li class="nav-item pcoded-menu-caption"><label>Problem & Knowledge</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/ITProblemListController" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-alert-circle"></i></span>
                            <span class="pcoded-mtext">Problem List</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/KnowErrorList" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-alert-triangle"></i></span>
                            <span class="pcoded-mtext">Known Errors</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/files/upload" target="_self" class="nav-link"><span class="pcoded-micon"><i class="feather icon-upload"></i></span><span class="pcoded-mtext">Shared Upload</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/KnowledgeArticleManage" target="_self" class="nav-link"><span class="pcoded-micon"><i class="feather icon-book"></i></span><span class="pcoded-mtext">Knowledge Article Management</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/TicketResolutionReview" class="nav-link"><span class="pcoded-micon"><i class="feather icon-check-square"></i></span><span class="pcoded-mtext">Ticket Resolution Review</span></a>
                    </li>

                    <li class="nav-item pcoded-menu-caption"><label>Change Management</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/SubmitChangeRequest" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-edit"></i></span>
                            <span class="pcoded-mtext">Submit RFC</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/MyChangeRequests" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                            <span class="pcoded-mtext">My Change Requests</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/TemporaryAccessRequest" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-unlock"></i></span>
                            <span class="pcoded-mtext">Temporary Access</span>
                        </a>
                    </li>

                </c:if>

                <!-- MANAGER MENU -->
                <c:if test="${role == 'Manager'}">

                    <li class="nav-item pcoded-menu-caption"><label>Overview</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/ManagerDashboard" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>
                     <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/Queues" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-inbox"></i></span>
                            <span class="pcoded-mtext">Ticket Queues</span>
                        </a>
                    </li>

                    <li class="nav-item pcoded-menu-caption"><label>SLA Management</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/SLADashboard" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-activity"></i></span>
                            <span class="pcoded-mtext">SLA Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/SLAConfig" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-settings"></i></span>
                            <span class="pcoded-mtext">SLA Configuration</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/SLABreachList" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-alert-circle"></i></span>
                            <span class="pcoded-mtext">SLA Breach List</span>
                        </a>
                    </li>

                    <li class="nav-item pcoded-menu-caption"><label>Problem Management</label></li>
                    <li class="nav-item pcoded-hasmenu">
                        <a href="#!" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-box"></i></span>
                            <span class="pcoded-mtext">Problems</span>
                        </a>
                        <ul class="pcoded-submenu">
                            <li>
                                <a href="${pageContext.request.contextPath}/ProblemPendingList" class="nav-link">
                                    <span class="pcoded-micon"><i class="feather icon-clock"></i></span>
                                    <span class="pcoded-mtext">Pending Approval</span>
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/ProblemList" class="nav-link">
                                    <span class="pcoded-micon"><i class="feather icon-list"></i></span>
                                    <span class="pcoded-mtext">All Problems</span>
                                </a>
                            </li>
                        </ul>
                    </li>
                    
                    
                    <li class="nav-item pcoded-menu-caption"><label>Configuration Items Management</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/CIListServlet" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-box"></i></span>
                            <span class="pcoded-mtext">Configuration Items</span>
                        </a>
                    </li>
                    

                    <li class="nav-item pcoded-menu-caption"><label>Change Management</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/ManagerChangeApprovals" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-check-square"></i></span>
                            <span class="pcoded-mtext">Approve RFC</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/TemporaryAccessApproval" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-shield"></i></span>
                            <span class="pcoded-mtext">Approve Temp Access</span>
                        </a>
                    </li>

                    <li class="nav-item pcoded-menu-caption"><label>Reports</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/PerformanceDashboard" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-bar-chart-2"></i></span>
                            <span class="pcoded-mtext">Performance</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/CsatReport" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-star"></i></span>
                            <span class="pcoded-mtext">CSAT Report</span>
                        </a>
                    </li>

                </c:if>

                <!-- ??? ADMIN MENU ??????????????????????????????????????? -->
                <c:if test="${role == 'Admin'}">
                    <li class="nav-item pcoded-menu-caption"><label>System Administration</label></li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/AdminDashboard" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/UserManagement" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-users"></i></span>
                            <span class="pcoded-mtext">User Management</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/CIListServlet" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-server"></i></span>
                            <span class="pcoded-mtext">Configuration Items</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/TemporaryAccessApproval" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-shield"></i></span>
                            <span class="pcoded-mtext">Temp Access Approval</span>
                        </a>
                    </li>
                </c:if>

            </ul>
        </div>
    </div>
</nav>
<!-- [ navigation menu ] end -->
=======
﻿<%-- Left sidebar - phân quyền theo session attribute "role" . Các trang cần set role trong session (từ Login) hoặc
    filter. --%>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!-- [ navigation menu ] start -->
        <nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
            <div class="navbar-wrapper ">
                <div class="navbar-brand header-logo">
                    <a href="AdminDashboard.jsp" class="b-brand">
                        <img src="assets/images/logo.svg" alt="" class="logo images">
                        <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">
                    </a>
                    <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
                </div>
                <div class="navbar-content scroll-div">
                    <ul class="nav pcoded-inner-navbar">
                        <li class="nav-item pcoded-menu-caption">
                            <label>Navigation</label>
                        </li>
                        <li class="nav-item">
                            <a href="AdminDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i
                                        class="feather icon-home"></i></span><span
                                    class="pcoded-mtext">Dashboard</span></a>
                        </li>
                        <li class="nav-item">
                            <a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i
                                        class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem
                                    List</span></a>
                        </li>

                        <!-- Menu chỉ dành cho Admin -->
                        <c:if test="${role == 'Admin'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Quản trị hệ thống</label>
                            </li>
                            <li class="nav-item">
                                <a href="UserManagement" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-users"></i></span><span class="pcoded-mtext">Quản lý
                                        User</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="SystemSettings" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-settings"></i></span><span class="pcoded-mtext">Cài đặt
                                        hệ thống</span></a>
                            </li>
                        </c:if>

                        <!-- Menu cho Manager và Admin -->

                        <c:if test="${role == 'Admin' || role == 'Manager'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>SLA Management</label>
                            </li>
                            <li class="nav-item">
                                <a href="SLADashboard" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-activity"></i></span><span class="pcoded-mtext">SLA
                                        Dashboard</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="SLAConfig" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-settings"></i></span><span class="pcoded-mtext">SLA
                                        Configuration</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="SLABreachList" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-alert-circle"></i></span><span class="pcoded-mtext">SLA
                                        Breach List</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="PerformanceDashboard" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-bar-chart-2"></i></span><span
                                        class="pcoded-mtext">Performance
                                        Dashboard</span></a>
                            </li>
                        </c:if>

                        <c:if test="${role == 'Admin' || role == 'Manager'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Report</label>
                            </li>
                            <li class="nav-item">
                                <a href="Reports" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-file-text"></i></span><span class="pcoded-mtext">Xem báo
                                        cáo</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="AgentPerformanceReport" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-users"></i></span><span class="pcoded-mtext">Agent
                                        Performance</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="AuditLogs" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-shield"></i></span><span class="pcoded-mtext">System
                                        Audit Logs</span></a>
                            </li>
                        </c:if>

                        <!-- Menu cho IT Support và Admin -->
                        <c:if test="${role == 'IT Support'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Navigation</label>
                            </li>
                            <li class="nav-item">
                                <a href="ITDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-home"></i></span><span
                                        class="pcoded-mtext">Dashboard</span></a>
                            </li>
                            <li class="nav-item pcoded-menu-caption">
                                <label>H? tr?</label>
                            </li>
                            <li class="nav-item">
                                <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Qu?n
                                        l� Tickets</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="AssignedTickets" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-user-check"></i></span><span
                                        class="pcoded-mtext">Tickets ???c giao</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="PendingTickets" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-clock"></i></span><span class="pcoded-mtext">Tickets
                                        ?ang ch?</span></a>
                            </li>
                        </c:if>
                    </ul>
                </div>
            </div>
        </nav>
        <!-- [ navigation menu ] end -->
>>>>>>> HoangNV4
