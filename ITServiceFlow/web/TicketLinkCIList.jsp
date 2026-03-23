<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<!DOCTYPE html> 
<html lang="vi"> 
    <head> 
        <title>Ticket - CI Links | ITServiceFlow</title> 
        <meta charset="utf-8"> 
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui"> 
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/> 
        <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon"> 
        <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css"> 
        <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css"> 
        <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css"> 
        <link rel="stylesheet" href="assets/css/style.css"> 
    </head> 
    <body> 
        <div class="loader-bg"> 
            <div class="loader-track"> 
                <div class="loader-fill"></div> 
            </div> 
        </div> 
        <nav class="pcoded-navbar menupos-fixed menu-light brand-blue"> 
            <div class="navbar-wrapper"> 
                <div class="navbar-brand header-logo"> 
                    <a href="index.jsp" class="b-brand"> 
                        <img src="assets/images/logo.svg" alt="ITServiceFlow Logo" class="logo images"> 
                        <span class="b-title">ITServiceFlow</span> 
                    </a> 
                </div> 
                <div class="navbar-content scroll-div"> 
                    <ul class="nav pcoded-inner-navbar"> 
                        <li class="nav-item"> 
                            <a href="AdminDashboard.jsp" class="nav-link"> 
                                <span class="pcoded-micon"><i class="feather icon-home"></i></span> 
                                <span class="pcoded-mtext">Dashboard</span> 
                            </a> 
                        </li> 
                        <li class="nav-item active"> 
                            <a href="TicketLinkCIListServlet" class="nav-link"> 
                                <span class="pcoded-micon"><i class="feather icon-link"></i></span> 
                                <span class="pcoded-mtext">Ticket - CI Links</span> 
                            </a> 
                        </li> 
                        <li class="nav-item"> 
                            <a href="Long_TicketListServlet" class="nav-link"> 
                                <span class="pcoded-micon"><i class="feather icon-file-text"></i></span> 
                                <span class="pcoded-mtext">Tickets</span> 
                            </a> 
                        </li> 
                        <li class="nav-item"> 
                            <a href="CIListServlet" class="nav-link"> 
                                <span class="pcoded-micon"><i class="feather icon-file-text"></i></span> 
                                <span class="pcoded-mtext">Assets</span> 
                            </a> 
                        </li> 
                    </ul> 
                </div> 
            </div> 
        </nav> 
        <div class="pcoded-main-container"> 
            <div class="pcoded-wrapper"> 
                <div class="pcoded-content"> 
                    <div class="pcoded-inner-content"> 
                        <div class="main-body"> 
                            <div class="page-wrapper"> 
                                <div class="page-header"> 
                                    <div class="row align-items-end"> 
                                        <div class="col-lg-12"> 
                                            <div class="page-header-title"> 
                                                <div class="d-inline"> 
                                                    <h4>Ticket - CI Links</h4> 
                                                    <span>View and manage links between tickets and assets.</span> 
                                                </div> 
                                            </div> 
                                        </div> 
                                    </div> 
                                </div> 
                                <c:if test="${not empty errorMessage}"> 
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert"> 
                                        <i class="feather icon-alert-circle"></i> 
                                        <strong>Error:</strong> ${errorMessage} 
                                        <button type="button" class="close" data-dismiss="alert" aria-label="Close"> 
                                            <span aria-hidden="true">&times;</span> 
                                        </button> 
                                    </div> 
                                </c:if> 
                                <c:if test="${not empty param.successMessage}"> 
                                    <div class="alert alert-success alert-dismissible fade show" role="alert"> 
                                        <i class="feather icon-check-circle"></i> 
                                        <strong>${param.successMessage}</strong> 
                                    </div> 
                                </c:if> 
                                <div class="page-body"> 
                                    <div class="row"> 
                                        <div class="col-sm-12"> 
                                            <div class="card"> 
                                                <div class="card-block"> 
                                                    <form id="searchForm" action="TicketLinkCIListServlet" method="GET"> 
                                                        <div class="row"> 
                                                            <div class="col-md-12"> 
                                                                <label class="col-form-label"> 
                                                                    <i class="feather icon-search mr-1"></i>Search Ticket - CI Link 
                                                                </label> 
                                                                <div class="input-group"> 
                                                                    <input type="text" 
                                                                           name="keyword" 
                                                                           class="form-control" 
                                                                           placeholder="Search by Ticket Number, Type of Ticket, Status of Ticket, Priority of Ticket, Asset Tag, Type of Asset, Location, Owner" 
                                                                           value="${keyword}"> 
                                                                    <div class="input-group-append"> 
                                                                        <button type="submit" class="btn btn-primary"> 
                                                                            <i class="feather icon-search"></i> Search 
                                                                        </button> 
                                                                        <c:if test="${not empty keyword}"> 
                                                                            <a href="TicketLinkCIListServlet" 
                                                                               class="btn btn-outline-secondary" title="Clear search"> 
                                                                                <i class="feather icon-x"></i> 
                                                                            </a> 
                                                                        </c:if> 
                                                                    </div> 
                                                                </div> 
                                                                <small class="text-muted mt-1 d-block"> 
                                                                    Searches across: Ticket Number, Type of Ticket, Status of Ticket, Priority of Ticket, Asset Tag, Type of Asset, Location, Owner 
                                                                </small> 
                                                            </div> 
                                                        </div> 
                                                    </form> 
                                                </div> 
                                            </div> 
                                            <div class="card"> 
                                                <div class="card-header d-flex justify-content-between align-items-center"> 
                                                    <h5 class="mb-0">Ticket - CI Link List</h5> 
                                                    <span class="badge badge-primary">${empty ticketCiLinkList ? 0 : ticketCiLinkList.size()}</span> 
                                                </div> 
                                                <div class="card-block table-border-style"> 
                                                    <div class="table-responsive"> 
                                                        <table class="table table-hover table-bordered"> 
                                                            <thead class="thead-light"> 
                                                                <tr> 
                                                                    <th style="width: 60px">#</th> 
                                                                    <th>Ticket Number</th> 
                                                                    <th>Type of Ticket</th> 
                                                                    <th>Status of Ticket</th> 
                                                                    <th>Priority of Ticket</th> 
                                                                    <th>Asset Tag</th> 
                                                                    <th>Type of Asset</th> 
                                                                    <th>Location</th> 
                                                                    <th>Owner</th> 
                                                                    <th style="width: 120px">Action</th> 
                                                                </tr> 
                                                            </thead> 
                                                            <tbody> 
                                                                <c:choose> 
                                                                    <c:when test="${not empty ticketCiLinkList}"> 
                                                                        <c:forEach var="item" items="${ticketCiLinkList}" varStatus="loop"> 
                                                                            <tr> 
                                                                                <td class="text-muted">${loop.count}</td> 
                                                                                <td><strong class="text-primary">${item.ticketNumber}</strong></td> 
                                                                                <td>${item.ticketType}</td> 
                                                                                <td>${item.ticketStatus}</td> 
                                                                                <td> 
                                                                                    <c:choose> 
                                                                                        <c:when test="${not empty item.ticketPriority}">${item.ticketPriority}</c:when> 
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise> 
                                                                                    </c:choose> 
                                                                                </td> 
                                                                                <td><strong class="text-primary">${item.assetTag}</strong></td> 
                                                                                <td>${item.assetType}</td> 
                                                                                <td> 
                                                                                    <c:choose> 
                                                                                        <c:when test="${not empty item.locationName}">${item.locationName}</c:when> 
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise> 
                                                                                    </c:choose> 
                                                                                </td> 
                                                                                <td> 
                                                                                    <c:choose> 
                                                                                        <c:when test="${not empty item.ownerName}">${item.ownerName}</c:when> 
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise> 
                                                                                    </c:choose> 
                                                                                </td> 
                                                                                <td> 
                                                                                    <form action="TicketLinkCIListServlet" method="POST" class="m-0" 
                                                                                          onsubmit="return confirm('Delete this link?');"> 
                                                                                        <input type="hidden" name="action" value="delete"> 
                                                                                        <input type="hidden" name="ticketId" value="${item.ticketId}"> 
                                                                                        <input type="hidden" name="assetId" value="${item.assetId}"> 
                                                                                        <input type="hidden" name="keyword" value="${keyword}"> 
                                                                                        <button type="submit" class="btn btn-sm btn-danger" title="Delete link"> 
                                                                                            <i class="feather icon-trash-2"></i> Delete 
                                                                                        </button> 
                                                                                    </form> 
                                                                                </td> 
                                                                            </tr> 
                                                                        </c:forEach> 
                                                                    </c:when> 
                                                                    <c:otherwise> 
                                                                        <tr> 
                                                                            <td colspan="10" class="text-center py-5"> 
                                                                                <i class="feather icon-link" style="font-size:2rem; color:#ccc;"></i> 
                                                                                <p class="mt-2 mb-1 font-weight-bold text-muted">No ticket - CI links found</p> 
                                                                                <small class="text-muted">There is no matching linked data to display.</small> 
                                                                            </td> 
                                                                        </tr> 
                                                                    </c:otherwise> 
                                                                </c:choose> 
                                                            </tbody> 
                                                        </table> 
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
            </div> 
        </div> 
        <script src="assets/js/vendor-all.min.js"></script> 
        <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script> 
        <script src="assets/js/pcoded.min.js"></script> 
    </body> 
</html> 

