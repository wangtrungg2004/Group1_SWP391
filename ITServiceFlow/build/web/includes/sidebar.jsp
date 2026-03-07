?<%-- Left sidebar - phân quy?n theo session attribute "role" . Các trang c?n set role trong session (t? Login) ho?c
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

                <!-- Menu ch? dành cho Admin -->
                <c:if test="${role == 'Admin'}">
                    <li class="nav-item pcoded-menu-caption">
                        <label>Qu?n tr? h? th?ng</label>
                    </li>
                    <li class="nav-item">
                        <a href="UserManagement" class="nav-link"><span class="pcoded-micon"><i
                                    class="feather icon-users"></i></span><span class="pcoded-mtext">Qu?n lý
                                User</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="SystemSettings" class="nav-link"><span class="pcoded-micon"><i
                                    class="feather icon-settings"></i></span><span class="pcoded-mtext">Cài ??t
                                h? th?ng</span></a>
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

                    <!--                            <li class="nav-item">
                                                    <a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i
                                                                class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a>
                                                </li>
                                                
                                                <li class="nav-item">
                                                    <a href="ProblemPendingList" class="nav-link"><span class="pcoded-micon"><i
                                                                class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem Pending List</span></a>
                                                </li>-->
                    <li class="nav-item pcoded-hasmenu">
                        <a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-box"></i></span><span class="pcoded-mtext">PROBLEMS</span></a>
                        <ul class="pcoded-submenu">
                            <li class=""><a href="ProblemPendingList" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem Pending List</span></a></li>
                            <li class=""><a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a></li>

                        </ul>
                    </li>
                    <c:if test="${role eq 'Manager'}">
                        <li class="nav-item">
                            <a class="nav-link" href="ManagerChangeApprovals">
                                <span class="pcoded-micon"><i class="feather icon-check-square"></i></span>
                                <span class="pcoded-mtext">Approve Change Request</span>
                            </a>
                        </li>
                    </c:if>
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
                    <!--                            <li class="nav-item pcoded-menu-caption">
                                                    <label>H? tr?</label>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i
                                                                class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Qu?n
                                                            l? Tickets</span></a>
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
                                                </li>-->
                    <!-- Menu cho IT Support: G?i Y?u c?u Thay ??i -->
                    <c:if test="${role eq 'IT Support'}">
                        <li class="nav-item">
                            <a class="nav-link" href="SubmitChangeRequest">
                                <span class="pcoded-micon"><i class="feather icon-plus-square"></i></span>
                                <span class="pcoded-mtext">Send Change Request</span>z
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

                    <!-- Menu cho Manager: Duy?t Y?u c?u Thay ??i -->
                    

                    <li class="nav-item">
                        <a href="ITProblemListController" class="nav-link"><span class="pcoded-micon"><i
                                    class="feather icon-clock"></i></span><span class="pcoded-mtext">Problem List</span></a>
                    </li>
                </c:if>
            </ul>
        </div>
    </div>
</nav>
<!-- [ navigation menu ] end -->