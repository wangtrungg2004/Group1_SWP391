<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
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
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>
    <jsp:include page="/includes/sidebar.jsp" />
    <jsp:include page="/includes/header.jsp" />

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
                                        <h5 class="mb-0"><i class="feather icon-book mr-1"></i> Danh sách bài viết tri thức</h5>
                                        <a href="<c:url value='/KnowledgeArticleCreate'/>" class="btn btn-primary btn-sm">
                                            <i class="feather icon-plus mr-1"></i> Tạo bài viết mới
                                        </a>
                                    </div>
                                    <div class="card-body">
                                        <form action="KnowledgeArticleManage" method="GET" class="mb-4">
                                            <div class="row align-items-end">
                                                <div class="col-md-5">
                                                    <div class="form-group mb-0">
                                                        <label class="floating-label">Tìm kiếm</label>
                                                        <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tiêu đề, nội dung hoặc mã bài viết...">
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group mb-0">
                                                        <label class="floating-label">Trạng thái</label>
                                                        <select class="form-control" name="status">
                                                            <option value="All" ${status == 'All' || empty status ? 'selected' : ''}>Tất cả trạng thái</option>
                                                            <option value="Draft" ${status == 'Draft' ? 'selected' : ''}>Draft</option>
                                                            <option value="Published" ${status == 'Published' ? 'selected' : ''}>Published</option>
                                                            <option value="Archived" ${status == 'Archived' ? 'selected' : ''}>Archived</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="feather icon-search mr-1"></i> Lọc
                                                    </button>
                                                    <a href="KnowledgeArticleManage" class="btn btn-outline-secondary">
                                                        <i class="feather icon-refresh-cw mr-1"></i> Reset
                                                    </a>
                                                </div>
                                            </div>
                                        </form>

                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Tiêu đề</th>
                                                        <th>Ngày tạo</th>
                                                        <th>Đính kèm</th>
                                                        <th class="text-center">Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="article" items="${articles}">
                                                        <tr>
                                                            <td>${article.id}</td>
                                                            <td><strong>${article.title}</strong></td>
                                                            <td>${article.createdAt}</td>
                                                            <td>
                                                                <c:forEach var="file" items="${article.attachments}">
                                                                    <a href="<c:url value='/files/download?id=${file.id}'/>" target="_blank" class="badge badge-info mb-1">
                                                                        <i class="feather icon-paperclip mr-1"></i>${file.originalName}
                                                                    </a><br/>
                                                                </c:forEach>
                                                            </td>
                                                            <td class="text-center">
                                                                <a href="<c:url value='/KnowledgeArticleView?id=${article.id}'/>" class="btn btn-sm btn-info" title="Xem">
                                                                    <i class="feather icon-eye"></i>
                                                                </a>
                                                                <a href="<c:url value='/KnowledgeArticleEdit?id=${article.id}'/>" class="btn btn-sm btn-warning" title="Chỉnh sửa">
                                                                    <i class="feather icon-edit"></i>
                                                                </a>
                                                                <a href="<c:url value='/FileUpload.jsp?kbId=${article.id}'/>" class="btn btn-sm btn-success" title="Đính kèm file">
                                                                    <i class="feather icon-paperclip"></i>
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
                                                <p class="mt-2">Chưa có bài viết nào.</p>
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