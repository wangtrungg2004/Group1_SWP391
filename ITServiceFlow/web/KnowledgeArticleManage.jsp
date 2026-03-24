<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Knowledge Article Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/pcoded.min.css">
    <link rel="stylesheet" href="assets/fonts/feather.css">
</head>

<body>
    <jsp:include page="includes/sidebar.jsp" />
    <jsp:include page="includes/header.jsp" />

    <div class="pcoded-main-container">
        <div class="pcoded-content">
            <div class="page-header">
                <div class="page-block">
                    <div class="row align-items-center">
                        <div class="col-md-12">
                            <div class="page-header-title">
                                <h5 class="m-b-10">Knowledge Article Management</h5>
                            </div>
                            <ul class="breadcrumb">
                                <li class="breadcrumb-item"><a href="ITDashboard.jsp"><i
                                            class="feather icon-home"></i></a></li>
                                <li class="breadcrumb-item active">Article Management</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <div class="pcoded-inner-content">
                <div class="main-body">
                    <div class="page-wrapper">
                        <div class="row">
                            <div class="col-sm-12">
                                <div class="card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h5 class="mb-0"><i class="feather icon-book mr-1"></i> List of knowledge articles</h5>
                                    </div>
                                    <div class="card-body">
                                        <form id="searchForm" action="KnowledgeArticleManage" method="GET" class="mb-4">
                                            <div class="row align-items-end">
                                                <div class="col-md-7">
                                                    <div class="form-group mb-0">
                                                        <label class="floating-label">Search</label>
                                                        <div class="input-group">
                                                            <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Article title, content, or code...">
                                                            <div class="input-group-append">
                                                                <button type="submit" class="btn btn-primary">
                                                                    <i class="feather icon-search mr-1"></i> Search
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="form-group mb-0">
                                                        <label class="floating-label">Status</label>
                                                        <select class="form-control" name="status" onchange="document.getElementById('searchForm').submit()">
                                                            <option value="All" ${status eq 'All' or empty status ? 'selected' : ''}>All</option>
                                                            <option value="Draft" ${status eq 'Draft' ? 'selected' : ''}>Draft</option>
                                                            <option value="Published" ${status eq 'Published' ? 'selected' : ''}>Published</option>
                                                            <option value="Archived" ${status eq 'Archived' ? 'selected' : ''}>Archived</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="form-group mb-0">
                                                        <label class="floating-label">Category</label>
                                                        <select class="form-control" name="category" onchange="document.getElementById('searchForm').submit()">
                                                            <option value="All" ${category eq 'All' or empty category ? 'selected' : ''}>All</option>
                                                            <option value="Phần mềm" ${category eq 'Phần mềm' ? 'selected' : ''}>Phần mềm</option>
                                                            <option value="Mạng & Kết nối" ${category eq 'Mạng & Kết nối' ? 'selected' : ''}>Mạng & Kết nối</option>
                                                            <option value="Phần cứng" ${category eq 'Phần cứng' ? 'selected' : ''}>Phần cứng</option>
                                                            <option value="Bảo mật" ${category eq 'Bảo mật' ? 'selected' : ''}>Bảo mật</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="col-md-1">
                                                    <c:if test="${not empty keyword or (not empty status and status ne 'All') or (not empty category and category ne 'All')}">
                                                        <a href="KnowledgeArticleManage" class="btn btn-outline-secondary">
                                                            <i class="feather icon-refresh-cw mr-1"></i>
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </form>

                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Title</th>
                                                        <th>Status</th>
                                                        <th>Category</th>
                                                        <th>Date created</th>
                                                        <th>Attached</th>
                                                        <th class="text-center">Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="article" items="${articles}">
                                                        <tr>
                                                            <td>${article.id}</td>
                                                            <td><strong>${article.title}</strong></td>
                                                            <td>${article.status}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty article.categoryId}">
                                                                        ${categoryMap[article.categoryId]}
                                                                    </c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty article.createdAt}">
                                                                        <fmt:formatDate value="${article.createdAt}" pattern="dd/MM/yyyy" />
                                                                    </c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:forEach var="file" items="${article.attachments}">
                                                                    <a href="<c:url value='/files/download?id=${file.id}'/>" target="_blank" class="badge badge-info mb-1">
                                                                        <i class="feather icon-paperclip mr-1"></i>${file.originalName}
                                                                    </a><br/>
                                                                </c:forEach>
                                                            </td>
                                                            <td class="text-center">
                                                                <a href="<c:url value='/KnowledgeArticleView?id=${article.id}'/>" class="btn btn-sm btn-info" title="View">
                                                                    <i class="feather icon-eye"></i>View
                                                                </a>
                                                                <a href="<c:url value='/KnowledgeArticleEdit?id=${article.id}'/>" class="btn btn-sm btn-warning" title="Edit">
                                                                    <i class="feather icon-edit"></i>Edit
                                                                </a>
                                                                <a href="<c:url value='/FileUpload.jsp?kbId=${article.id}'/>" class="btn btn-sm btn-success" title="Attached file">
                                                                    <i class="feather icon-paperclip"></i>Attached file
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                        <c:if test="${empty articles}">
                                            <div class="text-center py-4 text-muted">
                                                <i class="feather icon-inbox" style="font-size:3rem;display:block;"></i>
                                                <p class="mt-2">No articles have been published yet.</p>
                                            </div>
                                        </c:if>
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
    <script src="assets/js/plugins/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
</body>

</html>