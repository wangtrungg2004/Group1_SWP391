<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <title>CMDB - CI List | ITServiceFlow</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/animation/css/animate.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    </head>

    <body>

        <jsp:include page="/includes/header.jsp" />
        <jsp:include page="/includes/sidebar.jsp" />

        <%-- MAIN CONTENT --%>
        <div class="pcoded-main-container">
            <div class="pcoded-wrapper">
                <div class="pcoded-content">
                    <div class="pcoded-inner-content">
                        <div class="main-body">
                            <div class="page-wrapper">

                                <%-- PAGE HEADER --%>
                                <div class="page-header">
                                    <div class="row align-items-end">
                                        <div class="col-lg-12">
                                            <div class="page-header-title">
                                                <div class="d-inline">
                                                    <h4>Configuration Items</h4>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%-- FLASH MESSAGES --%>
                                <c:if test="${not empty sessionScope.message}">
                                    <div class="alert alert-${sessionScope.messageType} alert-dismissible fade show" role="alert">
                                        <i class="feather ${sessionScope.messageType eq 'success' ? 'icon-check-circle' : 'icon-alert-triangle'}"></i>
                                        ${sessionScope.message}
                                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <c:remove var="message" scope="session"/>
                                    <c:remove var="messageType" scope="session"/>
                                </c:if>

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
                                    <div id="linkSuccessAlert" class="alert alert-success alert-dismissible fade show" role="alert">
                                        <i class="feather icon-check-circle"></i>
                                        <strong>Link successfull</strong>
                                    </div>
                                </c:if>

                                <%-- PAGE BODY --%>
                                <div class="page-body">
                                    <div class="row">
                                        <div class="col-sm-12">

                                            <%-- SEARCH CARD --%>
                                            <div class="card">
                                                <div class="card-block">

                                                    <form id="searchForm" action="CIListServlet" method="GET">
                                                        <c:if test="${not empty ticketId}">
                                                            <input type="hidden" name="ticketId" value="${ticketId}">
                                                        </c:if>

                                                        <div class="row">
                                                            <%-- Keyword --%>
                                                            <div class="col-md-6">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-search mr-1"></i>Search CI
                                                                </label>
                                                                <div class="input-group">
                                                                    <input type="text"
                                                                           name="keyword"
                                                                           class="form-control"
                                                                           placeholder="Search by name, owner, date (dd/MM/yyyy)..."
                                                                           value="${keyword}">
                                                                    <div class="input-group-append">
                                                                        <button type="submit" class="btn btn-primary">
                                                                            <i class="feather icon-search"></i> Search
                                                                        </button>
                                                                        <c:if test="${not empty keyword or (status ne 'all') or (assetType ne 'all' and not empty assetType) or (location ne 'all' and not empty location)}">
                                                                            <a href="CIListServlet"
                                                                               class="btn btn-outline-secondary" title="Clear filters">
                                                                                <i class="feather icon-x"></i>
                                                                            </a>
                                                                        </c:if>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Status
                                                                </label>
                                                                <select name="status"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"         ${status eq 'all'         ? 'selected' : ''}>All</option>
                                                                    <option value="Active"      ${status eq 'Active'      ? 'selected' : ''}>Active</option>
                                                                    <option value="Inactive"    ${status eq 'Inactive'    ? 'selected' : ''}>Inactive</option>
                                                                    <option value="Maintenance" ${status eq 'Maintenance' ? 'selected' : ''}>Maintenance</option>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Type
                                                                </label>
                                                                <select name="assetType"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"     ${assetType eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="Laptop"  ${assetType eq 'Laptop' ? 'selected' : ''}>Laptop</option>
                                                                    <option value="Server"  ${assetType eq 'Server' ? 'selected' : ''}>Server</option>
                                                                    <option value="Network" ${assetType eq 'Network' ? 'selected' : ''}>Network</option>
                                                                    <option value="Printer" ${assetType eq 'Printer' ? 'selected' : ''}>Printer</option>
                                                                    <option value="Moniter" ${assetType eq 'Moniter' ? 'selected' : ''}>Moniter</option>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Location
                                                                </label>
                                                                <select name="location"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all" ${location eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="Tầng 1 - Hà Nội" ${location eq 'Tầng 1 - Hà Nội' ? 'selected' : ''}>Tầng 1 - Hà Nội</option>
                                                                    <option value="Tầng 2 - Hà Nội" ${location eq 'Tầng 2 - Hà Nội' ? 'selected' : ''}>Tầng 2 - Hà Nội</option>
                                                                    <option value="Tầng 3 - Hà Nội" ${location eq 'Tầng 3 - Hà Nội' ? 'selected' : ''}>Tầng 3 - Hà Nội</option>
                                                                    <option value="Tầng 4 - Hà Nội" ${location eq 'Tầng 4 - Hà Nội' ? 'selected' : ''}>Tầng 4 - Hà Nội</option>
                                                                    <option value="Tầng 1 - HCM" ${location eq 'Tầng 1 - HCM' ? 'selected' : ''}>Tầng 1 - HCM</option>
                                                                    <option value="Tầng 2 - HCM" ${location eq 'Tầng 2 - HCM' ? 'selected' : ''}>Tầng 2 - HCM</option>
                                                                    <option value="Tầng 1 - Đà Nẵng" ${location eq 'Tầng 1 - Đà Nẵng' ? 'selected' : ''}>Tầng 1 - Đà Nẵng</option>
                                                                    <option value="Tầng 2 - Đà Nẵng" ${location eq 'Tầng 2 - Đà Nẵng' ? 'selected' : ''}>Tầng 2 - Đà Nẵng</option>
                                                                    <option value="Tầng 1 - Cần Thơ" ${location eq 'Tầng 1 - Cần Thơ' ? 'selected' : ''}>Tầng 1 - Cần Thơ</option>
                                                                    <option value="Tầng 2 - Cần Thơ" ${location eq 'Tầng 2 - Cần Thơ' ? 'selected' : ''}>Tầng 2 - Cần Thơ</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <small class="text-muted mt-1 d-block">
                                                            Searches across: Name, Owner, Created Date (dd/MM/yyyy)
                                                        </small>
                                                    </form>

                                                </div>
                                            </div>

                                            <%-- CI LIST TABLE CARD --%>
                                            <div class="card">
                                                <div class="card-header d-flex justify-content-between align-items-center">
                                                    <h5 class="mb-0">
                                                        Configuration Items List
                                                    </h5>
                                                    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#addCIModal">
                                                        <i class="feather icon-plus-circle mr-1"></i>Add Configuration Item
                                                    </button>
                                                </div>
                                                <div class="card-block table-border-style">
                                                    <div class="table-responsive">
                                                        <table class="table table-hover table-bordered">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th style="width:50px">No</th>
                                                                    <th>CI Tag</th>
                                                                    <th>Name</th>
                                                                    <th>Type</th>
                                                                    <th>Status</th>
                                                                    <th>Location</th>
                                                                    <th>Owner</th>
                                                                    <th>Created At</th>
                                                                    <th style="width:150px">Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:choose>
                                                                    <c:when test="${not empty ciList}">
                                                                        <c:forEach var="ci" items="${ciList}" varStatus="loop">
                                                                            <tr>

                                                                                <td class="text-muted">${(currentPage - 1) * 10 + loop.count}</td>

                                                                                <td>
                                                                                    <strong class="text-primary">${ci.assetTag}</strong>
                                                                                </td>

                                                                                <td>${ci.name}</td>

                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty ci.assetType}">${ci.assetType}</c:when>
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>

                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${ci.status eq 'Active'}">
                                                                                            <span class="badge badge-success">Active</span>
                                                                                        </c:when>
                                                                                        <c:when test="${ci.status eq 'Inactive'}">
                                                                                            <span class="badge badge-secondary">Inactive</span>
                                                                                        </c:when>
                                                                                        <c:when test="${ci.status eq 'Maintenance'}">
                                                                                            <span class="badge badge-warning">Maintenance</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span class="badge badge-light">${ci.status}</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>

                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty ci.locationName}">
                                                                                            <i class="feather icon-map-pin text-muted mr-1"></i>${ci.locationName}
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span class="text-muted">—</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>

                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty ci.ownerName}">
                                                                                            <i class="feather icon-user text-muted mr-1"></i>${ci.ownerName}
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span class="text-muted">—</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>

                                                                                <td>
                                                                                    <fmt:formatDate value="${ci.createdAt}" pattern="dd/MM/yyyy"/>
                                                                                </td>

                                                                                <%-- ACTIONS --%>
                                                                                <td>
                                                                                    <%-- View detail --%>
                                                                                    <a href="CIDetailServlet?id=${ci.id}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}"
                                                                                       class="btn btn-sm btn-info mb-1"
                                                                                       title="View CI details">
                                                                                        <i class="feather icon-eye"></i> View
                                                                                    </a>
                                                                                    <%-- Delete Asset --%>
                                                                                    <form action="CIDeleteServlet" method="POST" style="display:inline;"
                                                                                          onsubmit="return confirm('Are you sure you want to delete this asset?');">
                                                                                        <input type="hidden" name="id" value="${ci.id}" />
                                                                                        <button type="submit" class="btn btn-sm btn-danger mb-1" title="Delete Asset">
                                                                                            <i class="feather icon-trash-2"></i> Delete
                                                                                        </button>
                                                                                    </form>
                                                                                </td>

                                                                            </tr>
                                                                        </c:forEach>
                                                                    </c:when>

                                                                    <c:otherwise>
                                                                        <tr>
                                                                            <td colspan="9" class="text-center py-5">
                                                                                <i class="feather icon-database"
                                                                                   style="font-size:2rem; color:#ccc;"></i>
                                                                                <p class="mt-2 mb-1 font-weight-bold text-muted">
                                                                                    No Configuration Items found
                                                                                </p>
                                                                                <small class="text-muted">
                                                                                    Try adjusting your search keyword or status filter.
                                                                                </small>
                                                                            </td>
                                                                        </tr>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                <%-- TABLE END --%>

                                            </div>
                                            <%-- CI LIST CARD END --%>

                                            <%-- PAGINATION --%>
                                            <c:if test="${totalPages ge 1}">
                                                <div class="text-center mt-3 mb-3">
                                                    <nav aria-label="Pagination">
                                                        <ul class="pagination pagination-sm justify-content-center mb-0">

                                                            <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                                                                <a class="page-link"
                                                                   href="CIListServlet?page=${currentPage - 1}&keyword=${keyword}&status=${status}&assetType=${assetType}&location=${location}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}">
                                                                    Prev
                                                                </a>
                                                            </li>

                                                            <c:forEach begin="1" end="${totalPages}" var="i">
                                                                <li class="page-item ${currentPage eq i ? 'active' : ''}">
                                                                    <a class="page-link"
                                                                       href="CIListServlet?page=${i}&keyword=${keyword}&status=${status}&assetType=${assetType}&location=${location}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}"
                                                                       >
                                                                        ${i}
                                                                    </a>
                                                                </li>
                                                            </c:forEach>

                                                            <li class="page-item ${currentPage ge totalPages ? 'disabled' : ''}">
                                                                <a class="page-link"
                                                                   href="CIListServlet?page=${currentPage + 1}&keyword=${keyword}&status=${status}&assetType=${assetType}&location=${location}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}">
                                                                    Next
                                                                </a>
                                                            </li>

                                                        </ul>
                                                    </nav>
                                                </div>
                                            </c:if>
                                            <%-- PAGINATION END --%>

                                        </div>
                                    </div>
                                </div>
                                <%-- PAGE BODY END --%>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%-- MAIN CONTENT END --%>

        <%-- ADD CI MODAL --%>
        <div class="modal fade" id="addCIModal" tabindex="-1" role="dialog" aria-labelledby="addCIModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <form action="CIAddServlet" method="POST">
                        <div class="modal-header">
                            <h5 class="modal-title" id="addCIModalLabel">Add New Configuration Item</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="font-weight-bold">CI Tag <span class="text-danger">*</span></label>
                                        <input type="text" name="assetTag" class="form-control" placeholder="Enter CI Tag (e.g. LAP-001)" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="font-weight-bold">Name <span class="text-danger">*</span></label>
                                        <input type="text" name="name" class="form-control" placeholder="Enter CI Name" required>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="font-weight-bold">Asset Type</label>
                                        <select name="assetType" class="form-control">
                                            <option value="Laptop">Laptop</option>
                                            <option value="Server">Server</option>
                                            <option value="Network">Network</option>
                                            <option value="Printer">Printer</option>
                                            <option value="Moniter">Moniter</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="font-weight-bold">Location</label>
                                        <select name="locationId" id="addCI-location" class="form-control">
                                            <c:forEach var="loc" items="${locationList}">
                                                <option value="${loc.id}">${loc.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="font-weight-bold">Owner</label>
                                        <select name="ownerId" id="addCI-owner" class="form-control">
                                            <c:forEach var="u" items="${userList}">
                                                <option value="${u.id}" 
                                                        data-location-id="${u.locationId}"
                                                        ${u.username eq 'admin' or u.fullName eq 'admin' ? 'selected' : ''}>
                                                    ${u.fullName} (${u.username})
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary">Save Configuration Item</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>

        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const locationSelect = document.getElementById('addCI-location');
                const ownerSelect = document.getElementById('addCI-owner');
                const allOwnerOptions = Array.from(ownerSelect.options);
                
                function filterOwners() {
                    const selectedLocationId = locationSelect.value;
                    
                    // Clear current options
                    ownerSelect.innerHTML = '';
                    
                    // Add filtered options
                    let foundAdmin = false;
                    allOwnerOptions.forEach(option => {
                        const optionLocId = option.getAttribute('data-location-id');
                        const isGlobalAdmin = option.text.toLowerCase().includes('(admin)'); // fallback check
                        
                        // Show if location matches OR if it's the admin user (optional based on your requirement)
                        // User said: filtered by location equal to location in field location
                        // If we must strictly filter by location, we do:
                        if (optionLocId == selectedLocationId || option.text.toLowerCase().includes('admin')) {
                            ownerSelect.appendChild(option.cloneNode(true));
                            if (option.text.toLowerCase().includes('admin')) foundAdmin = true;
                        }
                    });

                    // Set default to Admin if found
                    if (foundAdmin) {
                        for (let i = 0; i < ownerSelect.options.length; i++) {
                            if (ownerSelect.options[i].text.toLowerCase().includes('admin')) {
                                ownerSelect.selectedIndex = i;
                                break;
                            }
                        }
                    }
                }

                if (locationSelect && ownerSelect) {
                    locationSelect.addEventListener('change', filterOwners);
                    // Initial filter on load/modal open
                    $('#addCIModal').on('shown.bs.modal', filterOwners);
                }
            });

            setTimeout(function () {
                                                                                                  var alertBox = document.getElementById('linkSuccessAlert');
                                                                                                  if (alertBox) {
                                                                                                      alertBox.remove();
                                                                                                  }
                                                                                              }, 2000);
        </script>

    </body>
</html>
