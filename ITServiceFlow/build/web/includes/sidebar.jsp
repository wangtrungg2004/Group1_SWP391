<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<nav class="pcoded-navbar menupos-fixed menu-light brand-blue">
<div class="navbar-wrapper">

<div class="navbar-brand header-logo">

<a href="<c:url value='/AdminDashboard.jsp'/>" class="b-brand">
<img src="<c:url value='/assets/images/logo.svg'/>" class="logo images">
<img src="<c:url value='/assets/images/logo-icon.svg'/>" class="logo-thumb images">
</a>

<a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>

</div>


<div class="navbar-content scroll-div">

<ul class="nav pcoded-inner-navbar">


<!-- DASHBOARD -->

<li class="nav-item pcoded-menu-caption">
<label>Navigation</label>
</li>

<li class="nav-item">
<a href="<c:url value='/AdminDashboard.jsp'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-home"></i></span>
<span class="pcoded-mtext">Dashboard</span>
</a>
</li>


<!-- ADMIN -->

<c:if test="${role == 'Admin'}">

<li class="nav-item pcoded-menu-caption">
<label>System Administration</label>
</li>

<li class="nav-item">
<a href="<c:url value='/UserManagement'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-users"></i></span>
<span class="pcoded-mtext">User Management</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/SystemSettings'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-settings"></i></span>
<span class="pcoded-mtext">System Settings</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/CIListServlet'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-server"></i></span>
<span class="pcoded-mtext">Configuration Items</span>
</a>
</li>

</c:if>


<!-- SLA -->

<c:if test="${role == 'Admin' || role == 'Manager'}">

<li class="nav-item pcoded-menu-caption">
<label>SLA Management</label>
</li>

<li class="nav-item">
<a href="<c:url value='/SLADashboard'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-activity"></i></span>
<span class="pcoded-mtext">SLA Dashboard</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/SLAConfig'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-settings"></i></span>
<span class="pcoded-mtext">SLA Configuration</span>
</a>
</li>

</c:if>


<!-- PROBLEM MANAGEMENT -->

<c:if test="${role == 'Admin' || role == 'Manager'}">

<li class="nav-item pcoded-menu-caption">
<label>Problem Management</label>
</li>

<li class="nav-item pcoded-hasmenu">

<a href="#!" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-box"></i></span>
<span class="pcoded-mtext">Problems</span>
</a>

<ul class="pcoded-submenu">

<li>
<a href="<c:url value='/ProblemPendingList'/>">
Problem Pending List
</a>
</li>

<li>
<a href="<c:url value='/ProblemList'/>">
Problem List
</a>
</li>

</ul>

</li>

</c:if>


<!-- CHANGE REQUEST -->

<c:if test="${role == 'IT Support'}">

<li class="nav-item pcoded-menu-caption">
<label>Change Management</label>
</li>

<li class="nav-item">
<a href="<c:url value='/SubmitChangeRequest'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-plus-square"></i></span>
<span class="pcoded-mtext">Send Change Request</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/MyChangeRequests'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-list"></i></span>
<span class="pcoded-mtext">My Change Requests</span>
</a>
</li>

</c:if>


<!-- APPROVE CHANGE -->

<c:if test="${role == 'Manager'}">

<li class="nav-item">
<a href="<c:url value='/ManagerChangeApprovals'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-check-square"></i></span>
<span class="pcoded-mtext">Approve Change Request</span>
</a>
</li>

</c:if>


<!-- IT SUPPORT -->

<c:if test="${role == 'IT Support'}">

<li class="nav-item pcoded-menu-caption">
<label>Support</label>
</li>

<li class="nav-item">
<a href="<c:url value='/ITDashboard.jsp'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-home"></i></span>
<span class="pcoded-mtext">IT Dashboard</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/Tickets'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-help-circle"></i></span>
<span class="pcoded-mtext">Tickets</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/AssignedTickets'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-user-check"></i></span>
<span class="pcoded-mtext">Assigned Tickets</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/PendingTickets'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-clock"></i></span>
<span class="pcoded-mtext">Pending Tickets</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/ITProblemListController'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-alert-circle"></i></span>
<span class="pcoded-mtext">Problem List</span>
</a>
</li>

</c:if>


<!-- REPORT -->

<c:if test="${role == 'Admin' || role == 'Manager'}">

<li class="nav-item pcoded-menu-caption">
<label>Reports</label>
</li>

<li class="nav-item">
<a href="<c:url value='/Reports'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
<span class="pcoded-mtext">Reports</span>
</a>
</li>

</c:if>


<!-- USER -->

<c:if test="${role == 'User'}">

<li class="nav-item pcoded-menu-caption">
<label>User Portal</label>
</li>

<li class="nav-item">
<a href="<c:url value='/CreateTicket.jsp'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-plus-circle"></i></span>
<span class="pcoded-mtext">Create Ticket</span>
</a>
</li>

<li class="nav-item">
<a href="<c:url value='/KnowledgeSearch'/>" class="nav-link">
<span class="pcoded-micon"><i class="feather icon-book-open"></i></span>
<span class="pcoded-mtext">Knowledge Search</span>
</a>
</li>

</c:if>

</ul>
</div>
</div>
</nav>
