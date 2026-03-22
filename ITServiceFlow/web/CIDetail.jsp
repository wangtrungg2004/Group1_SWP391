<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <title>CI Detail - ${ci.assetTag} | ITServiceFlow</title>
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
                <img src="assets/images/logo.svg" alt="ITServiceFlow" class="logo images">
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
                        <li class="nav-item"> 
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
                                            <h4>Configuration Item Detail</h4>
                                            <span>Asset Tag: <strong>${ci.assetTag}</strong> | ${ci.name}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="page-body">

                            <c:if test="${not empty param.successMessage}">
                                <div class="alert alert-success alert-dismissible fade show" role="alert">
                                    <i class="feather icon-check-circle"></i>
                                    <c:out value="${param.successMessage}"/>
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </c:if>

                            <c:if test="${not empty param.errorMessage}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="feather icon-alert-circle"></i>
                                    <c:out value="${param.errorMessage}"/>
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </c:if>

                            <div class="row mb-4">
                                <div class="col-lg-6">
                                    <div class="card h-100">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h5 class="mb-0">Basic Information</h5>
                                            <div class="card-header-right d-flex align-items-center">
                                                <button type="button"
                                                        class="btn btn-primary btn-sm mr-2"
                                                        data-toggle="modal"
                                                        data-target="#editCIModal">
                                                    <i class="feather icon-edit"></i> Edit
                                                </button>
                                                <c:if test="${not empty ticketId}">
                                                    <a href="LinkCIServlet?ciId=${ci.id}&ticketId=${ticketId}" class="btn btn-success btn-sm">
                                                        <i class="feather icon-link"></i> Link to Ticket #${ticket.ticketNumber}
                                                    </a>
                                                </c:if>
                                            </div>
                                        </div>
                                        <div class="card-block">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <table class="table table-borderless table-striped mb-0">
                                                        <tr>
                                                            <th width="160">Asset Tag</th>
                                                            <td><strong>${ci.assetTag}</strong></td>
                                                        </tr>
                                                        <tr>
                                                            <th>Name</th>
                                                            <td>${ci.name}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Type</th>
                                                            <td><c:out value="${not empty ci.assetType ? ci.assetType : 'N/A'}"/></td>
                                                        </tr>
                                                        <tr>
                                                            <th>Status</th>
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
                                                        </tr>
                                                    </table>
                                                </div>
                                                <div class="col-md-6">
                                                    <table class="table table-borderless table-striped mb-0">
                                                        <tr>
                                                            <th width="160">Location</th>
                                                            <td><c:out value="${not empty ci.locationName ? ci.locationName : 'N/A'}"/></td>
                                                        </tr>
                                                        <tr>
                                                            <th>Owner</th>
                                                            <td><c:out value="${not empty ci.ownerName ? ci.ownerName : 'N/A'}"/></td>
                                                        </tr>
                                                        <tr>
                                                            <th>Created At</th>
                                                            <td><fmt:formatDate value="${ci.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                        </tr>
                                                        <tr>
                                                            <th>Related Tickets</th>
                                                            <td>${relatedTicketCount} linked ticket(s)</td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-6">
                                    <div class="card h-100">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h5 class="mb-0">Related Configuration Items</h5>
                                            <button type="button" class="btn btn-primary btn-sm"
                                                    data-toggle="modal" data-target="#addRelationshipModal">
                                                <i class="feather icon-plus"></i> Add Relationship
                                            </button>
                                        </div>
                                        <div class="card-block">
                                            <c:choose>
                                                <c:when test="${not empty relationships}">
                                                    <div class="table-responsive">
                                                        <table class="table table-hover table-bordered">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th>Relationship Type</th>
                                                                    <th>Related CI</th>
                                                                    <th>Asset Tag</th>
                                                                    <th>Description</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:forEach var="rel" items="${relationships}">
                                                                    <tr>
                                                                        <td><span class="badge badge-info">${rel.relationshipType}</span></td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${rel.sourceCIId == ci.id}">
                                                                                    <a href="CIDetailServlet?id=${rel.targetCIId}" class="text-primary">
                                                                                        <c:out value="${not empty rel.targetName ? rel.targetName : '-'}"/>
                                                                                    </a>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <a href="CIDetailServlet?id=${rel.sourceCIId}" class="text-primary">
                                                                                        <c:out value="${not empty rel.sourceName ? rel.sourceName : '-'}"/>
                                                                                    </a>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${rel.sourceCIId == ci.id}">
                                                                                    <c:out value="${not empty rel.targetAssetTag ? rel.targetAssetTag : '-'}"/>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <c:out value="${not empty rel.sourceAssetTag ? rel.sourceAssetTag : '-'}"/>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td><c:out value="${not empty rel.description ? rel.description : '-'}"/></td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="alert alert-info text-center mb-0">
                                                        No related configuration items found.
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">CI Map</h5>
                                </div>
                                <div class="card-block">
                                    <div id="ciGraph" style="width:100%; height: 520px; background:#f8f9fa; border:1px solid #dee2e6; border-radius:4px;"></div>
                                </div>
                            </div>

                            <div class="text-right mt-4">
                                <a href="CIListServlet" class="btn btn-secondary">
                                    <i class="feather icon-arrow-left"></i> Back to CI List
                                </a>
                                <c:if test="${not empty ticketId}">
                                    <a href="TicketLinkCIServlet?ticketId=${ticketId}" class="btn btn-primary ml-2">
                                        <i class="feather icon-file-text"></i> Back to Ticket
                                    </a>
                                </c:if>
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
<script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.26.0/cytoscape.min.js"></script>

<!-- Edit CI Modal -->
<div class="modal fade" id="editCIModal" tabindex="-1" role="dialog" aria-labelledby="editCIModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <form action="CIUpdateServlet" method="post">
                <div class="modal-header">
                    <h5 class="modal-title" id="editCIModalLabel">Edit Configuration Item</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="id" value="${ci.id}"/>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="ciName">Name</label>
                            <input type="text" class="form-control" id="ciName" name="name" value="${ci.name}" required>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="ciType">Type</label>
                            <select class="form-control" id="ciType" name="assetType" required>
                                <option value="Laptop" ${ci.assetType == 'Laptop' ? 'selected' : ''}>Laptop</option>
                                <option value="Network" ${ci.assetType == 'Network' ? 'selected' : ''}>Network</option>
                                <option value="Server" ${ci.assetType == 'Server' ? 'selected' : ''}>Server</option>
                                <option value="Printer" ${ci.assetType == 'Printer' ? 'selected' : ''}>Printer</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="ciStatus">Status</label>
                            <select class="form-control" id="ciStatus" name="status" required>
                                <option value="Active" ${ci.status == 'Active' ? 'selected' : ''}>Active</option>
                                <option value="Inactive" ${ci.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="ciLocation">Location</label>
                            <select class="form-control" id="ciLocation" name="locationId" required>
                                <option value="">-- Chọn Location --</option>
                                <option value="1" ${ci.locationId == 1 ? 'selected' : ''}>Tầng 1 - Hà Nội</option>
                                <option value="2" ${ci.locationId == 2 ? 'selected' : ''}>Tầng 2 - Hà Nội</option>
                                <option value="3" ${ci.locationId == 3 ? 'selected' : ''}>Tầng 3 - Hà Nội</option>
                                <option value="4" ${ci.locationId == 4 ? 'selected' : ''}>Tầng 4 - Hà Nội</option>
                                <option value="5" ${ci.locationId == 5 ? 'selected' : ''}>Tầng 1 - HCM</option>
                                <option value="6" ${ci.locationId == 6 ? 'selected' : ''}>Tầng 2 - HCM</option>
                                <option value="7" ${ci.locationId == 7 ? 'selected' : ''}>Tầng 1 - Đà Nẵng</option>
                                <option value="8" ${ci.locationId == 8 ? 'selected' : ''}>Tầng 2 - Đà Nẵng</option>
                                <option value="9" ${ci.locationId == 9 ? 'selected' : ''}>Tầng 1 - Cần Thơ</option>
                                <option value="10" ${ci.locationId == 10 ? 'selected' : ''}>Tầng 2 - Cần Thơ</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-12">
                            <label for="ciOwner">Owner</label>
                            <select class="form-control" id="ciOwner" name="ownerId">
                                <option value="">-- Chọn Owner --</option>
                                <c:forEach var="u" items="${users}">
                                    <option value="${u.id}"
                                            data-location-id="${u.locationId}"
                                            ${u.id == ci.ownerId ? 'selected' : ''}>
                                        <c:out value="${u.fullName}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Add Relationship Modal -->
<div class="modal fade" id="addRelationshipModal" tabindex="-1" role="dialog" aria-labelledby="addRelationshipModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <form action="CIAddRelationshipServlet" method="POST">
                <div class="modal-header">
                    <h5 class="modal-title" id="addRelationshipModalLabel">Add Relationship</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="sourceCIId" value="${ci.id}"/>

                    <div class="form-row">
                        <div class="form-group col-md-4">
                            <label>Relationship Type</label>
                            <select name="relationshipType" class="form-control" required>
                                <option value="DependsOn">DependsOn</option>
                                <option value="ConnectedTo">ConnectedTo</option>
                                <option value="HostedOn">HostedOn</option>
                                <option value="Uses">Uses</option>
                            </select>
                        </div>
                        <div class="form-group col-md-8">
                            <label>Description</label>
                            <input type="text" name="description" class="form-control" placeholder="Description..."/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="mb-1">Target CI</label>
                    </div>

                    <div class="table-responsive mb-3" style="max-height: 320px; overflow: auto; border: 1px solid #e9ecef; border-radius: 4px;">
                        <table class="table table-hover table-bordered mb-0">
                            <thead class="thead-light">
                                <tr>
                                    <th style="width: 60px;">Chọn</th>
                                    <th>Asset Tag</th>
                                    <th>Name</th>
                                    <th>Type</th>
                                    <th>Owner</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty targetCIs}">
                                        <c:forEach var="a" items="${targetCIs}">
                                            <tr>
                                                <td class="text-center">
                                                    <input type="radio" name="targetCIId" value="${a.id}" required/>
                                                </td>
                                                <td><strong><c:out value="${a.assetTag}"/></strong></td>
                                                <td><c:out value="${a.name}"/></td>
                                                <td><c:out value="${not empty a.assetType ? a.assetType : '-'}"/></td>
                                                <td><c:out value="${not empty a.ownerName ? a.ownerName : '-'}"/></td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted py-3">
                                                No suitable CI.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="feather icon-save"></i> Add
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        function filterOwnersByLocation() {
            var locationSelect = document.getElementById('ciLocation');
            var ownerSelect = document.getElementById('ciOwner');
            if (!locationSelect || !ownerSelect) {
                return;
            }
            var selectedLocationId = locationSelect.value;
            var options = ownerSelect.options;
            var firstVisibleIndex = 0;

            for (var i = 0; i < options.length; i++) {
                var opt = options[i];
                if (!opt.getAttribute('data-location-id')) {
                    opt.style.display = '';
                    continue;
                }
                if (!selectedLocationId) {
                    opt.style.display = '';
                } else if (opt.getAttribute('data-location-id') === selectedLocationId) {
                    opt.style.display = '';
                    if (firstVisibleIndex === 0) {
                        firstVisibleIndex = i;
                    }
                } else {
                    opt.style.display = 'none';
                }
            }

            if (selectedLocationId) {
                var currentOwner = ownerSelect.value;
                var currentOptionVisible = false;
                for (var j = 0; j < options.length; j++) {
                    if (options[j].value === currentOwner && options[j].style.display !== 'none') {
                        currentOptionVisible = true;
                        break;
                    }
                }
                if (!currentOptionVisible) {
                    ownerSelect.selectedIndex = firstVisibleIndex;
                }
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            var locationSelect = document.getElementById('ciLocation');
            if (locationSelect) {
                locationSelect.addEventListener('change', filterOwnersByLocation);
            }
            // When modal is shown, apply initial filter based on current location
            $('#editCIModal').on('shown.bs.modal', function () {
                filterOwnersByLocation();
            });
        });
    })();
</script>

<script>
    (function () {
        var cy;
        var rootCIId = '${ci != null ? ci.id : ""}';

        function initGraph() {
            var container = document.getElementById('ciGraph');
            if (!container || !rootCIId) return;

            cy = cytoscape({
                container: container,
                style: [
                    {
                        selector: 'node',
                        style: {
                            'label': 'data(label)',
                            'text-valign': 'bottom',
                            'text-margin-y': 6,
                            'background-color': function (ele) {
                                var type = (ele.data('type') || '').toLowerCase();
                                switch (type) {
                                    case 'server': return '#007bff';
                                    case 'laptop': return '#28a745';
                                    case 'printer': return '#ffc107';
                                    case 'network': return '#dc3545';
                                    default: return '#6c757d';
                                }
                            },
                            'width': 48,
                            'height': 48,
                            'font-size': '11px',
                            'color': '#333',
                            'text-wrap': 'wrap',
                            'text-max-width': '100px'
                        }
                    },
                    {
                        selector: 'node[id = "' + rootCIId + '"]',
                        style: {
                            'border-width': 4,
                            'border-color': '#000'
                        }
                    },
                    {
                        selector: 'edge',
                        style: {
                            'width': 2,
                            'line-color': '#999',
                            'target-arrow-color': '#999',
                            'target-arrow-shape': 'triangle',
                            'curve-style': 'bezier',
                            'label': 'data(label)',
                            'font-size': '9px',
                            'text-rotation': 'autorotate',
                            'text-margin-y': -10,
                            'text-background-color': '#fff',
                            'text-background-opacity': 1,
                            'text-background-padding': '2px'
                        }
                    }
                ],
                layout: {name: 'grid'}
            });

            cy.on('tap', 'node', function (evt) {
                var d = evt.target.data();
                if (d && d.id) {
                    window.location.href = 'CIDetailServlet?id=' + d.id;
                }
            });
        }

        function loadGraph() {
            var url = 'CIRelationshipMapServlet?format=json&id=' + encodeURIComponent(rootCIId);
            fetch(url)
                .then(function (r) {
                    if (!r.ok) {
                        throw new Error('HTTP ' + r.status);
                    }
                    return r.json();
                })
                .then(function (data) {
                    cy.elements().remove();
                    cy.add(data);
                    cy.layout({name: 'breadthfirst', directed: true, padding: 30, animate: true}).run();
                })
                .catch(function (e) {
                    console.error('Load CI graph failed:', e);
                    var container = document.getElementById('ciGraph');
                    if (container) {
                        container.innerHTML = '<div class="text-center text-muted py-5">Không thể tải sơ đồ quan hệ.</div>';
                    }
                });
        }

        document.addEventListener('DOMContentLoaded', function () {
            initGraph();
            if (cy) loadGraph();
        });
    })();
</script>

</body>
</html>
