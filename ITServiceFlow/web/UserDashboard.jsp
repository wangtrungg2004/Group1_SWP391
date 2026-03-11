<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Service Portal - ITServiceFlow</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        .dashboard-container { max-width: 1200px; margin: 0 auto; padding-top: 10px; }
        .dashboard-hero { background: linear-gradient(135deg, #0052cc 0%, #0747a6 100%); padding: 50px 20px; border-radius: 12px; color: white; margin-bottom: 30px; box-shadow: 0 8px 16px rgba(0,82,204,0.15); position: relative; overflow: hidden;}
        .dashboard-hero-bg { position: absolute; right: -5%; top: -20%; font-size: 15rem; color: rgba(255,255,255,0.05); z-index: 0; transform: rotate(-15deg); }
        .hero-content { position: relative; z-index: 1; }
        .hero-title { font-size: 2rem; font-weight: 700; margin-bottom: 10px; color: #fff;}
        .hero-subtitle { font-size: 1.1rem; opacity: 0.9; margin-bottom: 25px; }
        .hero-search { max-width: 600px; position: relative; }
        .hero-search input { width: 100%; padding: 16px 20px 16px 50px; border-radius: 8px; border: none; font-size: 1.05rem; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .hero-search i { position: absolute; left: 18px; top: 50%; transform: translateY(-50%); color: #5e6c84; font-size: 1.2rem; }
        .quick-action-card { background: white; border-radius: 10px; padding: 25px 20px; display: flex; align-items: center; border: 1px solid #dfe1e6; transition: all 0.2s; text-decoration: none !important; color: #172b4d; margin-bottom: 20px; }
        .quick-action-card:hover { transform: translateY(-3px); box-shadow: 0 8px 16px rgba(9, 30, 66, 0.08); border-color: #0052cc; }
        .quick-icon { width: 50px; height: 50px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-right: 15px; flex-shrink: 0; }
        .icon-blue { background: #e9f2ff; color: #0052cc; }
        .icon-green { background: #e3fcef; color: #00875a; }
        .icon-purple { background: #eae6ff; color: #403294; }
        .quick-text h5 { margin: 0 0 5px 0; font-weight: 700; font-size: 1.1rem; color: #172b4d;}
        .quick-text p { margin: 0; font-size: 0.85rem; color: #5e6c84; }
        .panel-card { background: white; border-radius: 10px; border: 1px solid #dfe1e6; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); margin-bottom: 30px; height: calc(100% - 30px);}
        .panel-title { font-size: 1.15rem; font-weight: 700; color: #172b4d; border-bottom: 2px solid #f4f5f7; padding-bottom: 15px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;}
        .mini-ticket-item { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid #f4f5f7; }
        .mini-ticket-item:last-child { border-bottom: none; }
        .ticket-info .t-key { font-weight: 700; color: #0052cc; text-decoration: none; font-size: 0.9rem; margin-right: 10px;}
        .ticket-info .t-title { font-weight: 500; color: #172b4d; font-size: 0.95rem; }
        .ticket-info .t-meta { font-size: 0.8rem; color: #6b778c; margin-top: 4px; display: block;}
        .jira-badge { display: inline-block; padding: 3px 8px; border-radius: 3px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
        .badge-new { background-color: #e9f2ff; color: #0052cc; }
        .badge-progress { background-color: #fff0b3; color: #ff8b00; }
        .badge-resolved { background-color: #e3fcef; color: #00875a; }
        .badge-closed { background-color: #dfe1e6; color: #42526e; }
        .kb-item { display: flex; align-items: flex-start; padding: 10px 0; }
        .kb-item i { color: #0052cc; margin-top: 3px; margin-right: 10px; }
        .kb-item a { color: #172b4d; font-weight: 500; text-decoration: none; font-size: 0.9rem;}
        .kb-item a:hover { color: #0052cc; text-decoration: underline; }
    </style>
</head>

<body class="">
    <div class="loader-bg"><div class="loader-track"><div class="loader-fill"></div></div></div>
    
    <jsp:include page="includes/sidebar.jsp" />
    <jsp:include page="includes/header.jsp" />

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper dashboard-container">
                            
                            <div class="dashboard-hero">
                                <i class="feather icon-life-buoy dashboard-hero-bg"></i>
                                <div class="hero-content">
                                    <h1 class="hero-title">Welcome, ${user.fullName}! 👋</h1>
                                    <p class="hero-subtitle">How can the IT department help you today?</p>
                                    <div class="hero-search">
                                        <i class="feather icon-search"></i>
                                        <input type="text" placeholder="Search for troubleshooting guides, software...">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <a href="${pageContext.request.contextPath}/CreateTicket" class="quick-action-card">
                                        <div class="quick-icon icon-blue"><i class="feather icon-plus-circle"></i></div>
                                        <div class="quick-text">
                                            <h5>Create New Request</h5>
                                            <p>Report an issue or request IT service</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <a href="${pageContext.request.contextPath}/Tickets" class="quick-action-card">
                                        <div class="quick-icon icon-purple"><i class="feather icon-list"></i></div>
                                        <div class="quick-text">
                                            <h5>My Tickets</h5>
                                            <p>Manage all created requests</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <c:choose>
                                        <c:when test="${role == 'Manager'}">
                                            <a href="#!" class="quick-action-card">
                                                <div class="quick-icon icon-green"><i class="feather icon-check-square"></i></div>
                                                <div class="quick-text">
                                                    <h5>Approvals</h5>
                                                    <p>Approve employee service requests</p>
                                                </div>
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="#!" class="quick-action-card">
                                                <div class="quick-icon icon-green"><i class="feather icon-book"></i></div>
                                                <div class="quick-text">
                                                    <h5>Help Center</h5>
                                                    <p>Read self-service troubleshooting guides</p>
                                                </div>
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-8">
                                    <div class="panel-card">
                                        <div class="panel-title">
                                            <span><i class="feather icon-activity text-primary mr-2"></i> Your recent requests</span>
                                            <a href="${pageContext.request.contextPath}/Tickets" class="btn btn-sm btn-outline-primary" style="font-size: 0.8rem;">View all</a>
                                        </div>
                                        
                                        <div class="mini-ticket-list">
                                            <c:choose>
                                                <c:when test="${empty recentTickets}">
                                                    <div class="text-center text-muted py-4">
                                                        <i class="feather icon-inbox d-block mb-2" style="font-size: 2rem; opacity: 0.5;"></i>
                                                        You have no requests.
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach items="${recentTickets}" var="ticket">
                                                        <div class="mini-ticket-item">
                                                            <div class="ticket-info">
                                                                <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="t-key">${ticket.ticketNumber}</a>
                                                                <span class="t-title">${ticket.title}</span>
                                                                <span class="t-meta">
                                                                    <i class="feather icon-clock"></i> <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/> 
                                                                    &nbsp;|&nbsp; Type: ${ticket.ticketType}
                                                                </span>
                                                            </div>
                                                            <div class="ticket-status">
                                                                <span class="jira-badge 
                                                                    ${ticket.status == 'New' ? 'badge-new' : 
                                                                      ticket.status == 'In Progress' ? 'badge-progress' : 
                                                                      ticket.status == 'Resolved' ? 'badge-resolved' : 'badge-closed'}">
                                                                    ${ticket.status == 'New' ? 'Pending' : ticket.status}
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-4">
                                    <div class="panel-card">
                                        <div class="panel-title">
                                            <span><i class="feather icon-book-open text-warning mr-2"></i> Popular Articles</span>
                                        </div>
                                        <div class="kb-list">
                                            <div class="kb-item"><i class="feather icon-file-text"></i><a href="#!">ERP system password reset guide</a></div>
                                            <div class="kb-item"><i class="feather icon-file-text"></i><a href="#!">Fix printer offline error on Windows</a></div>
                                            <div class="kb-item"><i class="feather icon-file-text"></i><a href="#!">New employee laptop request process</a></div>
                                        </div>
                                        <hr class="my-4">
                                        <div class="panel-title mb-3">
                                            <span><i class="feather icon-bell text-danger mr-2"></i> IT Announcements</span>
                                        </div>
                                        <div class="alert alert-primary p-2" style="font-size: 0.85rem;">
                                            <strong><i class="feather icon-info"></i> Maintenance:</strong> The ERP system will be down this Saturday (March 12) from 22:00 - 02:00.
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

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
</body>
</html>