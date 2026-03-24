<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Ticket List | ITServiceFlow</title>
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
        <jsp:include page="includes/header.jsp" />
        <jsp:include page="includes/sidebar.jsp" />

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
                                                    <h4>Tickets</h4>
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
                                    <div id="linkSuccessAlert" class="alert alert-success alert-dismissible fade show" role="alert">
                                        <i class="feather icon-check-circle"></i>
                                        <strong>Link successfull</strong>
                                    </div>
                                </c:if>

                                <div class="page-body">
                                    <div class="row">
                                        <div class="col-sm-12">

                                            <%-- SEARCH CARD --%>
                                            <div class="card">
                                                <div class="card-block">

                                                    <form id="searchForm" action="Long_TicketListServlet" method="GET">
                                                        <c:if test="${not empty ticketId}">
                                                            <input type="hidden" name="ticketId" value="${ticketId}">
                                                        </c:if>

                                                        <div class="row">
                                                            <%-- Keyword --%>
                                                            <div class="col-md-6">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-search mr-1"></i>Search Ticket
                                                                </label>
                                                                <div class="input-group">
                                                                    <input type="text"
                                                                           name="keyword"
                                                                           class="form-control"
                                                                           placeholder="Search by Ticket Number, Title, Status, Priority, Created At(dd/MM/yyyy)"
                                                                           value="${keyword}">
                                                                    <div class="input-group-append">
                                                                        <button type="submit" class="btn btn-primary">
                                                                            <i class="feather icon-search"></i> Search
                                                                        </button>
                                                                        <c:if test="${not empty keyword 
                                                                                      or (type ne 'all' and not empty type)
                                                                                      or (status ne 'all' and not empty status)
                                                                                      or (priority ne 'all' and not empty priority)}">
                                                                              <a href="Long_TicketListServlet"
                                                                                 class="btn btn-outline-secondary" title="Clear filters">
                                                                                  <i class="feather icon-x"></i>
                                                                              </a>
                                                                        </c:if>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Type
                                                                </label>
                                                                <select name="type"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"             ${type eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="Incident"        ${type eq 'Incident' ? 'selected' : ''}>Incident</option>
                                                                    <option value="ServiceRequest"  ${type eq 'ServiceRequest' ? 'selected' : ''}>Service Request</option>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Status
                                                                </label>
                                                                <select name="status"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"        ${status eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="New"        ${status eq 'New' ? 'selected' : ''}>New</option>
                                                                    <option value="Inprogress" ${status eq 'Inprogress' ? 'selected' : ''}>In Progress</option>
                                                                    <option value="Completed"  ${status eq 'Completed' ? 'selected' : ''}>Completed</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Priority
                                                                </label>
                                                                <select name="priority"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"      ${priority eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="Critical" ${priority eq 'Critical' ? 'selected' : ''}>Critical</option>
                                                                    <option value="High"     ${priority eq 'High' ? 'selected' : ''}>High</option>
                                                                    <option value="Medium"   ${priority eq 'Medium' ? 'selected' : ''}>Medium</option>
                                                                    <option value="Low"      ${priority eq 'Low' ? 'selected' : ''}>Low</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <small class="text-muted mt-1 d-block">
                                                            Searches across: Ticket Number, Title, Status, Priority, Created At(dd/MM/yyyy)
                                                        </small>
                                                    </form>

                                                </div>
                                            </div>

                                            <%-- Tickets LIST TABLE CARD --%>
                                            <div class="card">
                                                <div class="card-header d-flex justify-content-between align-items-center">
                                                    <h5 class="mb-0">Ticket List</h5>

                                                </div>

                                                <div class="card-block table-border-style">
                                                    <div class="table-responsive">
                                                        <table id="ticketTable" class="table table-hover table-bordered">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th style="width: 60px">No</th>
                                                                    <th>Ticket Number</th>
                                                                    <th>Type</th>
                                                                    <th>Title</th>
                                                                    <th>Status</th>
                                                                    <th>Priority</th>
                                                                    <th>Assets</th>
                                                                    <th>Created At</th>
                                                                    <th style="width: 120px">Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticketList}">
                                                                        <c:forEach var="t" items="${ticketList}" varStatus="loop">
                                                                            <tr class="ticket-row">
                                                                                <td class="text-muted ticket-row-number">${loop.count}</td>
                                                                                <td><strong class="text-primary">${t.ticketNumber}</strong></td>
                                                                                <td>${t.ticketType}</td>
                                                                                <td>${t.title}</td>
                                                                                <td>${t.status}</td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty t.priorityLevel}">${t.priorityLevel}</c:when>
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty t.linkedAssets}">
                                                                                            <c:forEach var="ci" items="${t.linkedAssets}">
                                                                                                <span class="badge badge-info mr-1">
                                                                                                    <a href="CIDetailServlet?id=${ci.id}&ticketId=${t.id}"
                                                                                                       class="text-white"
                                                                                                       style="text-decoration: underline;">
                                                                                                        ${ci.assetTag}
                                                                                                    </a>
                                                                                                    <form action="TicketUnlinkCIServlet"
                                                                                                          method="POST"
                                                                                                          style="display:inline;">
                                                                                                        <input type="hidden" name="ticketId" value="${t.id}" />
                                                                                                        <input type="hidden" name="assetId" value="${ci.id}" />
                                                                                                        <button type="submit"
                                                                                                                class="btn btn-sm btn-link text-white p-0 ml-1"
                                                                                                                title="Remove asset link"
                                                                                                                onclick="return confirm('Remove this asset from ticket?');">
                                                                                                            ×
                                                                                                        </button>
                                                                                                    </form>
                                                                                                </span>
                                                                                            </c:forEach>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span class="text-muted">—</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty t.createdAt}">
                                                                                            <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy"/>
                                                                                        </c:when>
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <a href="TicketDetailServlet?id=${t.id}" class="btn btn-sm btn-info mb-1" title="View Ticket Detail">
                                                                                        <i class="feather icon-eye"></i> View
                                                                                    </a>
                                                                                    <button type="button"
                                                                                            class="btn btn-sm btn-warning mb-1"
                                                                                            data-toggle="modal"
                                                                                            data-target="#assetPickerModal"
                                                                                            data-ticket-id="${t.id}">
                                                                                        <i class="feather icon-link"></i> Link to Asset
                                                                                    </button>
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <tr>
                                                                            <td colspan="9" class="text-center py-5">
                                                                                <i class="feather icon-file-text" style="font-size:2rem; color:#ccc;"></i>
                                                                                <p class="mt-2 mb-1 font-weight-bold text-muted">No tickets found</p>
                                                                                <small class="text-muted">There is no ticket data to display.</small>
                                                                            </td>
                                                                        </tr>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                            <div id="ticketPaginationWrapper" class="mt-3 text-center">
                                                <nav aria-label="Ticket pagination" class="mt-2">
                                                    <ul class="pagination pagination-sm justify-content-center mb-0" id="ticketPagination"></ul>
                                                </nav>
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

        <%-- Asset Picker Modal --%>
        <div class="modal fade" id="assetPickerModal" tabindex="-1" role="dialog" aria-labelledby="assetPickerModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="assetPickerModalLabel">Select the Asset to link.</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" id="apTicketId" value="" />

                        <div class="row">
                            <div class="col-md-8">
                                <label class="col-form-label">
                                    <i class="feather icon-search mr-1"></i>Search
                                </label>
                                <div class="input-group">
                                    <input type="text"
                                           id="apAssetSearch"
                                           class="form-control"
                                           placeholder="Search across: asset tag, asset name, owner" />
                                    <div class="input-group-append">
                                        <button type="button"
                                                id="apAssetSearchBtn"
                                                class="btn btn-primary">
                                            <i class="feather icon-search"></i> Search
                                        </button>
                                        <button type="button"
                                                id="apAssetSearchClearBtn"
                                                class="btn btn-outline-secondary"
                                                title="Clear filters"
                                                style="display:none;">
                                            <i class="feather icon-x"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <label class="col-form-label">
                                    <i class="feather icon-filter mr-1"></i>Filter by Asset Type
                                </label>
                                <select id="apAssetType" class="form-control">
                                    <option value="all">All</option>
                                    <option value="Laptop">Laptop</option>
                                    <option value="Server">Server</option>
                                    <option value="Network">Network</option>
                                    <option value="Printer">Printer</option>
                                </select>
                            </div>
                        </div>

                        <div class="table-responsive mt-3">
                            <table class="table table-hover table-bordered mb-0">
                                <thead class="thead-light">
                                    <tr>
                                        <th style="width: 120px;">Asset Tag</th>
                                        <th>Name</th>
                                        <th style="width: 140px;">Type</th>
                                        <th style="width: 200px;">Owner</th>
                                        <th style="width: 90px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="apTableBody">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">Chọn ticket để tải danh sách assets...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
                                                                                                                    (function () {
                                                                                                                        var successAlert = document.getElementById('linkSuccessAlert');
                                                                                                                        if (successAlert) {
                                                                                                                            setTimeout(function () {
                                                                                                                                successAlert.style.transition = 'opacity 0.3s ease';
                                                                                                                                successAlert.style.opacity = '0';
                                                                                                                                setTimeout(function () {
                                                                                                                                    if (successAlert && successAlert.parentNode) {
                                                                                                                                        successAlert.parentNode.removeChild(successAlert);
                                                                                                                                    }
                                                                                                                                }, 300);
                                                                                                                            }, 2000);
                                                                                                                        }
                                                                                                                    })();
        </script>

        <script>
            (function () {
                function escapeHtml(str) {
                    if (str === null || str === undefined)
                        return '';
                    return String(str)
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;')
                            .replace(/"/g, '&quot;')
                            .replace(/'/g, '&#39;');
                }

                function renderRows(items, ticketId) {
                    var tbody = document.getElementById('apTableBody');
                    if (!items || items.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">No suitable assets were found.</td></tr>';
                        return;
                    }

                    var html = '';
                    for (var i = 0; i < items.length; i++) {
                        var a = items[i];
                        html += '<tr>'
                                + '<td><strong class="text-primary">' + escapeHtml(a.assetTag) + '</strong></td>'
                                + '<td>' + escapeHtml(a.name) + '</td>'
                                + '<td>' + escapeHtml(a.assetType) + '</td>'
                                + '<td>' + escapeHtml(a.ownerName) + '</td>'
                                + '<td>'
                                + '<form action="TicketLinkCIServlet" method="POST" style="margin:0;">'
                                + '<input type="hidden" name="ticketId" value="' + escapeHtml(ticketId) + '"/>'
                                + '<input type="hidden" name="assetTag" value="' + escapeHtml(a.assetTag) + '"/>'
                                + '<button type="submit" class="btn btn-sm btn-primary">Link</button>'
                                + '</form>'
                                + '</td>'
                                + '</tr>';
                    }
                    tbody.innerHTML = html;
                }

                // Lưu assets gốc (theo Location của người tạo ticket + AssetType) để client lọc theo AssetTag/Name/Owner.
                // Backend popup hiện chỉ search theo Name/Owner, nên để支持 assetTag 同时命中，这里固定 lấy full rồi client filter.
                var apAllAssets = [];

                function updateApAssetSearchClearVisibility() {
                    var searchVal = (document.getElementById('apAssetSearch').value || '').trim();
                    var assetTypeVal = document.getElementById('apAssetType').value || 'all';
                    var shouldShow = searchVal.length > 0 || assetTypeVal !== 'all';
                    var clearBtn = document.getElementById('apAssetSearchClearBtn');
                    if (clearBtn)
                        clearBtn.style.display = shouldShow ? '' : 'none';
                }

                async function loadAssetsBase() {
                    var ticketId = document.getElementById('apTicketId').value;
                    var assetType = document.getElementById('apAssetType').value || 'all';

                    var tbody = document.getElementById('apTableBody');
                    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">Đang tải...</td></tr>';

                    try {
                        var url = 'TicketAssetsPickerServlet?ticketId=' + encodeURIComponent(ticketId)
                                + '&keyword=' + encodeURIComponent('') // lấy full theo location, rồi lọc ở client
                                + '&assetType=' + encodeURIComponent(assetType);
                        var res = await fetch(url, {headers: {'Accept': 'application/json'}});
                        var data = await res.json();
                        apAllAssets = data.assets || [];
                        applyClientFilters();
                    } catch (e) {
                        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger py-4">Không thể tải danh sách assets.</td></tr>';
                    }
                }

                function applyClientFilters() {
                    var ticketId = document.getElementById('apTicketId').value;
                    var searchTerm = (document.getElementById('apAssetSearch').value || '').trim().toLowerCase();

                    var filtered = (apAllAssets || []).filter(function (a) {
                        var ok = true;
                        if (searchTerm) {
                            ok = ok && (
                                    (a.assetTag || '').toLowerCase().includes(searchTerm) ||
                                    (a.name || '').toLowerCase().includes(searchTerm) ||
                                    (a.ownerName || '').toLowerCase().includes(searchTerm)
                                    );
                        }
                        return ok;
                    });

                    renderRows(filtered, ticketId);
                }

                // Khi mở modal: lấy ticketId từ button
                $('#assetPickerModal').on('show.bs.modal', function (event) {
                    var button = $(event.relatedTarget);
                    var ticketId = button.data('ticket-id');
                    document.getElementById('apTicketId').value = ticketId;
                    document.getElementById('apAssetSearch').value = '';
                    document.getElementById('apAssetType').value = 'all';
                    apAllAssets = [];
                    loadAssetsBase();
                    updateApAssetSearchClearVisibility();
                });

                // Show/Hide clear button (không trigger filter)
                document.getElementById('apAssetSearch').addEventListener('input', function () {
                    updateApAssetSearchClearVisibility();
                });

                // Search manual - lọc theo AssetTag/Name/Owner trong danh sách đã tải
                document.getElementById('apAssetSearch').addEventListener('keydown', function (e) {
                    // Nhấn Enter hoặc bấm Search mới thực hiện lọc
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        applyClientFilters();
                    }
                });
                document.getElementById('apAssetSearchBtn').addEventListener('click', function () {
                    applyClientFilters();
                });
                document.getElementById('apAssetType').addEventListener('change', function () {
                    apAllAssets = [];
                    loadAssetsBase();
                    updateApAssetSearchClearVisibility();
                });

                document.getElementById('apAssetSearchClearBtn').addEventListener('click', function () {
                    document.getElementById('apAssetSearch').value = '';
                    document.getElementById('apAssetType').value = 'all';
                    apAllAssets = [];
                    loadAssetsBase();
                    updateApAssetSearchClearVisibility();
                });
            })();
        </script>

        <script>
            (function () {
                function buildPagination(currentPage, totalPages, onPageClick) {
                    var ul = document.getElementById('ticketPagination');
                    if (!ul)
                        return;
                    ul.innerHTML = '';

                    function addItem(label, page, opts) {
                        opts = opts || {};
                        var li = document.createElement('li');
                        li.className = 'page-item' + (opts.disabled ? ' disabled' : '') + (opts.active ? ' active' : '');
                        var a = document.createElement('a');
                        a.className = 'page-link';
                        a.href = '#';
                        a.textContent = label;

                        // Hiển thị trang 1 màu vàng khi đang ở trang 1
                        if (opts.active && label === '1') {
                            a.style.backgroundColor = '#ffc107'; // Bootstrap warning yellow
                            a.style.borderColor = '#ffc107';
                            a.style.color = '#212529';
                            a.style.fontWeight = '600';
                        }
                        if (opts.disabled) {
                            a.addEventListener('click', function (e) {
                                e.preventDefault();
                            });
                        } else {
                            a.addEventListener('click', function (e) {
                                e.preventDefault();
                                onPageClick(page);
                            });
                        }
                        li.appendChild(a);
                        ul.appendChild(li);
                    }

                    addItem('Prev', currentPage - 1, {disabled: currentPage <= 1});
                    for (var p = 1; p <= totalPages; p++) {
                        addItem(String(p), p, {active: p === currentPage});
                    }

                    addItem('Next', currentPage + 1, {disabled: currentPage >= totalPages});
                }

                function init() {
                    var wrapper = document.getElementById('ticketPaginationWrapper');
                    var table = document.getElementById('ticketTable');
                    if (!wrapper || !table)
                        return;

                    var rows = Array.prototype.slice.call(table.querySelectorAll('tbody tr.ticket-row'));
                    if (!rows || rows.length <= 0)
                        return;

                    var pageSize = 10; // Mặc định: 10 tickets / trang
                    var currentPage = 1;

                    function render() {
                        var totalRows = rows.length;
                        var totalPages = Math.max(1, Math.ceil(totalRows / pageSize));
                        if (currentPage > totalPages)
                            currentPage = totalPages;

                        var startIdx = (currentPage - 1) * pageSize;
                        var endIdxExclusive = Math.min(startIdx + pageSize, totalRows);

                        rows.forEach(function (tr, idx) {
                            tr.style.display = (idx >= startIdx && idx < endIdxExclusive) ? '' : 'none';
                        });

                        var visible = rows.slice(startIdx, endIdxExclusive);
                        visible.forEach(function (tr, i) {
                            var numberCell = tr.querySelector('.ticket-row-number');
                            if (numberCell)
                                numberCell.textContent = String(startIdx + i + 1);
                        });

                        buildPagination(currentPage, totalPages, function (page) {
                            currentPage = page;
                            render();
                        });
                    }

                    wrapper.style.display = '';
                    render();
                }

                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', init);
                } else {
                    init();
                }
            })();
        </script>
    </body>
</html>
