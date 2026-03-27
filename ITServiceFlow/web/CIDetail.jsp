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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/animation/css/animate.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>

    <body>

        <jsp:include page="/includes/header.jsp" />
        <jsp:include page="/includes/sidebar.jsp" />

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
                                                    <span>CI Tag: <strong>${ci.assetTag}</strong> | ${ci.name}</span>
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

                                    <div class="row mb-4 align-items-stretch">
                                        <div class="col-lg-7">
                                            <div class="card h-100 mb-4">
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
                                                                    <th width="160">CI Tag</th>
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

                                        <div class="col-lg-5">
                                            <div class="card h-100 mb-4">
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
                                                                            <th>CI Tag</th>
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
                                        <div class="card-block p-0 position-relative">
                                            <div class="p-2 d-flex justify-content-between align-items-center" style="position: absolute; top: 0; left: 0; right: 0; z-index: 10;">
                                                <button type="button" id="btnAutoLayout" class="btn btn-sm btn-outline-primary bg-white shadow-sm">
                                                    <i class="feather icon-refresh-cw"></i> Auto layout
                                                </button>
                                                <div class="ci-legend d-flex flex-wrap bg-white p-2 rounded shadow-sm border" style="font-size: 0.75rem;">
                                                    <div class="d-flex align-items-center mr-3">
                                                        <span class="d-inline-block rounded-circle mr-1" style="width: 10px; height: 10px; background-color: #28a745;"></span> Laptop
                                                    </div>
                                                    <div class="d-flex align-items-center mr-3">
                                                        <span class="d-inline-block rounded-circle mr-1" style="width: 10px; height: 10px; background-color: #dc3545;"></span> Network
                                                    </div>
                                                    <div class="d-flex align-items-center mr-3">
                                                        <span class="d-inline-block rounded-circle mr-1" style="width: 10px; height: 10px; background-color: #17a2b8;"></span> Monitor
                                                    </div>
                                                    <div class="d-flex align-items-center mr-3">
                                                        <span class="d-inline-block rounded-circle mr-1" style="width: 10px; height: 10px; background-color: #007bff;"></span> Server
                                                    </div>
                                                    <div class="d-flex align-items-center">
                                                        <span class="d-inline-block rounded-circle mr-1" style="width: 10px; height: 10px; background-color: #ffc107;"></span> Printer
                                                    </div>
                                                </div>
                                            </div>
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

        <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
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
                                        <option value="">-- Select Location --</option>
                                        <c:forEach var="loc" items="${locations}">
                                            <option value="${loc.id}" ${ci.locationId == loc.id ? 'selected' : ''}>
                                                <c:out value="${loc.name}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group col-md-12">
                                    <label for="ciOwner">Owner</label>
                                    <select class="form-control" id="ciOwner" name="ownerId">
                                        <option value="">-- Select Owner --</option>
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
                                            <th style="width: 60px;">Select</th>
                                            <th>CI Tag</th>
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
                    var firstVisibleIndex = -1;

                    for (var i = 0; i < options.length; i++) {
                        var opt = options[i];
                        var optLocationId = opt.getAttribute('data-location-id');
                        
                        if (!optLocationId) {
                            // "Select Owner" option
                            opt.hidden = false;
                            opt.disabled = false;
                            opt.style.display = '';
                            if (firstVisibleIndex === -1) firstVisibleIndex = i;
                            continue;
                        }
                        
                        if (!selectedLocationId) {
                            opt.hidden = false;
                            opt.disabled = false;
                            opt.style.display = '';
                            if (firstVisibleIndex === -1) firstVisibleIndex = i;
                        } else if (optLocationId === selectedLocationId) {
                            opt.hidden = false;
                            opt.disabled = false;
                            opt.style.display = '';
                            if (firstVisibleIndex === -1) firstVisibleIndex = i;
                        } else {
                            opt.hidden = true;
                            opt.disabled = true;
                            opt.style.display = 'none';
                        }
                    }

                    // Check if current selection is still valid
                    var currentOption = ownerSelect.options[ownerSelect.selectedIndex];
                    if (currentOption && (currentOption.hidden || currentOption.disabled || currentOption.style.display === 'none')) {
                        ownerSelect.selectedIndex = (firstVisibleIndex !== -1) ? firstVisibleIndex : 0;
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
                    if (!container || !rootCIId)
                        return;

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
                                            case 'server':
                                                return '#007bff';
                                            case 'laptop':
                                                return '#28a745';
                                            case 'monitor':
                                            case 'moniter':
                                                return '#17a2b8';
                                            case 'printer':
                                                return '#ffc107';
                                            case 'network':
                                                return '#dc3545';
                                            default:
                                                return '#6c757d';
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
                                runAutoLayout();
                            })
                            .catch(function (e) {
                                console.error('Load CI graph failed:', e);
                                var container = document.getElementById('ciGraph');
                                if (container) {
                                    container.innerHTML = '<div class="text-center text-muted py-5">Không thể tải sơ đồ quan hệ.</div>';
                                }
                            });
                }

                function runAutoLayout() {
                    if (cy) {
                        cy.layout({
                            name: 'breadthfirst',
                            directed: true,
                            padding: 30,
                            animate: true,
                            spacingFactor: 1.25
                        }).run();
                    }
                }

                document.addEventListener('DOMContentLoaded', function () {
                    initGraph();
                    if (cy) {
                        loadGraph();
                        
                        var btnAutoLayout = document.getElementById('btnAutoLayout');
                        if (btnAutoLayout) {
                            btnAutoLayout.addEventListener('click', function() {
                                runAutoLayout();
                            });
                        }
                    }
                });
            })();
        </script>

    </body>
</html>
