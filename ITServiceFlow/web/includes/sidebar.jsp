<%-- 
    Left sidebar - phân quyền theo session attribute "role".
    Các trang cần set role trong session (từ Login) hoặc filter.
--%>
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
                <c:if test="${role == 'Admin'}">
                    <li class="nav-item pcoded-menu-caption">
                        <label>Quản trị hệ thống</label>
                    </li>
                    <li class="nav-item">
                        <a href="UserManagement" class="nav-link"><span class="pcoded-micon"><i class="feather icon-users"></i></span><span class="pcoded-mtext">Quản lý User</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="SystemSettings" class="nav-link"><span class="pcoded-micon"><i class="feather icon-settings"></i></span><span class="pcoded-mtext">Cài đặt hệ thống</span></a>
                    </li>
                </c:if>

                <!-- Menu cho Manager và Admin -->
                <c:if test="${role == 'Admin' || role == 'Manager'}">
                    <li class="nav-item pcoded-menu-caption">
                        <label>Report</label>
                    </li>
                    <li class="nav-item">
                        <a href="Reports" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Xem báo cáo</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="AdminDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a>
                    </li>
                </c:if>
                    
                    <c:if test="${role == 'User'}">
    <li class="nav-item pcoded-menu-caption">
        <label>D?ch v? CNTT</label>
    </li>
    <li class="nav-item">
        <a href="UserDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
    </li>
    <li class="nav-item">
        <a href="CreateTicket" class="nav-link"><span class="pcoded-micon"><i class="feather icon-plus-circle"></i></span><span class="pcoded-mtext">T?o Ticket m?i</span></a>
    </li>
    <li class="nav-item">
        <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-list"></i></span><span class="pcoded-mtext">Tickets c?a t�i</span></a>
    </li>
</c:if>

                <!-- Menu cho IT Support -->
                <c:if test="${role == 'IT Support'}">
                    <li class="nav-item pcoded-menu-caption">
                        <label>Navigation</label>
                    </li>
                    <li class="nav-item">
                        <a href="ITDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
                    </li>
                    <li class="nav-item pcoded-menu-caption">
                        <label>H? tr?</label>
                    </li>
                    <li class="nav-item">
                        <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Qu?n l� Tickets</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="AssignedTickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-user-check"></i></span><span class="pcoded-mtext">Tickets ???c giao</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="PendingTickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-clock"></i></span><span class="pcoded-mtext">Tickets ?ang ch?</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="ITProblemListController" class="nav-link"><span class="pcoded-micon"><i class="feather icon-clock"></i></span><span class="pcoded-mtext">Problem List</span></a>
                    </li>
                </c:if>
                <!-- Menu cho IT Support: G?i Y�u c?u Thay ??i -->
                <c:if test="${role eq 'IT Support'}">
                    <li class="nav-item">
                        <a class="nav-link" href="SubmitChangeRequest">
                            <span class="pcoded-micon"><i class="feather icon-plus-square"></i></span>
                            <span class="pcoded-mtext">Send Change Request</span>
                        </a>
                    </li>
                </c:if>
                <c:if test="${role eq 'IT Support'}">
                    <li class="nav-item">
                        <a class="nav-link" href="MyChangeRequests">
                            <span class="pcoded-micon"><i class="feather icon-list"></i></span>
                            <span class="pcoded-mtext">My Change Request</span>
                        </a>
                    </li>
                </c:if>

                <!-- Menu cho Manager: Duy?t Y�u c?u Thay ??i -->
                <c:if test="${role eq 'Manager'}">
                    <li class="nav-item">
                        <a class="nav-link" href="ManagerChangeApprovals">
                            <span class="pcoded-micon"><i class="feather icon-check-square"></i></span>
                            <span class="pcoded-mtext">Approve Change Request</span>
                        </a>
                    </li>
                </c:if>
            </ul>
        </div>
    </div>
</nav>
<!-- [ navigation menu ] end -->
