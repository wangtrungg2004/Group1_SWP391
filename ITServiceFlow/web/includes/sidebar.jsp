    ?<%-- Left sidebar - ph�n quy?n theo session attribute "role" . C�c trang c?n set role trong session (t? Login) ho?c
    filter. --%>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!-- [ navigation menu ] start -->
        <nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
            <div class="navbar-wrapper ">
                <div class="navbar-brand header-logo">
                    <a href="<c:url value='/AdminDashboard.jsp'/>" class="b-brand">
                        <img src="<c:url value='/assets/images/logo.svg'/>" alt="" class="logo images">
                        <img src="<c:url value='/assets/images/logo-icon.svg'/>" alt="" class="logo-thumb images">
                    </a>
                    <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
                </div>
                <div class="navbar-content scroll-div">
                    <ul class="nav pcoded-inner-navbar">
                        <c:if test="${role != 'IT Support'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Navigation</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/AdminDashboard.jsp'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-home"></i></span><span
                                        class="pcoded-mtext">Dashboard</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/files/upload'/>" target="_self" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-upload"></i></span><span
                                        class="pcoded-mtext">Upload Files</span></a>
                            </li>
                        </c:if>

                        <!-- Menu ch? d�nh cho Admin -->
                        <c:if test="${role == 'Admin'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>System Administration</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/UserManagement'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-users"></i></span><span class="pcoded-mtext">User Management</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/SystemSettings'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-settings"></i></span><span class="pcoded-mtext">System Settings</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/CIListServlet'/>" class="nav-link"><span class="pcoded-micon"><i class="feather icon-server"></i></span><span class="pcoded-mtext">List Configuration Items</span></a>
                            </li>
                        </c:if>

                        <!-- Menu cho Manager v� Admin -->

                        <c:if test="${role == 'Admin' || role == 'Manager'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>SLA Management</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/SLADashboard'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-activity"></i></span><span class="pcoded-mtext">SLA
                                        Dashboard</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/SLAConfig'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-settings"></i></span><span class="pcoded-mtext">SLA
                                        Configuration</span></a>
                            </li>
                        </c:if>

                        <c:if test="${role == 'Admin' || role == 'Manager'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Report</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/Reports'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-file-text"></i></span><span class="pcoded-mtext">Reports</span></a>
                            </li>
                        </c:if>

                        <!-- Menu cho IT Support v� Admin -->
                        <c:if test="${role == 'IT Support'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Navigation</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/ITDashboard.jsp'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-home"></i></span><span
                                        class="pcoded-mtext">Dashboard</span></a>
                            </li>
                            <li class="nav-item pcoded-menu-caption">
                                <label>Support</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/Tickets'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Tickets</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/AssignedTickets'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-user-check"></i></span><span
                                        class="pcoded-mtext">Assigned Tickets</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/PendingTickets'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-clock"></i></span><span class="pcoded-mtext">Pending Tickets</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/ITProblemListController'/>" class="nav-link"><span class="pcoded-micon"><i
                                            class="feather icon-clock"></i></span><span class="pcoded-mtext">Problem List</span></a>
                            </li>
                            <li class="nav-item pcoded-menu-caption">
                                <label>Knowledge</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/files/upload'/>" target="_self" class="nav-link"><span class="pcoded-micon"><i class="feather icon-upload"></i></span><span class="pcoded-mtext">Shared Upload</span></a>
                            </li>
                                <li class="nav-item">
                                    <a href="<c:url value='/KnowledgeArticleManage'/>" target="_self" class="nav-link"><span class="pcoded-micon"><i class="feather icon-book"></i></span><span class="pcoded-mtext">Knowledge Article Management</span></a>
                                </li>
                                <li class="nav-item">
                                    <a href="<c:url value='/KnowledgeSearch'/>" class="nav-link"><span class="pcoded-micon"><i class="feather icon-book-open"></i></span><span class="pcoded-mtext">Knowledge Search</span></a>
                                </li>
                            <li class="nav-item">
                                <a href="<c:url value='/TicketResolutionReview'/>" class="nav-link"><span class="pcoded-micon"><i class="feather icon-check-square"></i></span><span class="pcoded-mtext">Ticket Resolution Review</span></a>
                            </li>
                        </c:if>

                        <!-- Menu cho End User -->
                        <c:if test="${role == 'User'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Knowledge Base</label>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/CreateTicket'/>" class="nav-link"><span class="pcoded-micon"><i class="feather icon-plus-circle"></i></span><span class="pcoded-mtext">Create Ticket</span></a>
                            </li>
                            <li class="nav-item">
                                <a href="<c:url value='/KnowledgeSearch'/>" class="nav-link"><span class="pcoded-micon"><i class="feather icon-book-open"></i></span><span class="pcoded-mtext">Knowledge Search</span></a>
                            </li>
                        </c:if>
                    </ul>
                </div>
            </div>
        </nav>
        <!-- [ navigation menu ] end -->