<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Edit Knowledge Article</title>
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
                                <h5 class="m-b-10">Chỉnh sửa bài viết tri thức</h5>
                            </div>
                            <ul class="breadcrumb">
                                <li class="breadcrumb-item"><a href="ITDashboard.jsp"><i
                                            class="feather icon-home"></i></a></li>
                                <li class="breadcrumb-item"><a href="KnowledgeArticleManage">Quản lý bài viết</a></li>
                                <li class="breadcrumb-item active">Chỉnh sửa</li>
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
                                <c:if test="${not empty errorMessage}">
                                    <div class="alert alert-danger alert-dismissible fade show">
                                        ${errorMessage}
                                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                                    </div>
                                </c:if>
                                <c:if test="${not empty successMessage}">
                                    <div class="alert alert-success alert-dismissible fade show">
                                        ${successMessage}
                                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                                    </div>
                                </c:if>

                                <div class="card">
                                    <div class="card-header">
                                        <h5><i class="feather icon-edit mr-1"></i> Thông tin bài viết</h5>
                                    </div>
                                    <div class="card-body">
                                        <form action="KnowledgeArticleEdit" method="POST" enctype="multipart/form-data">
                                            <input type="hidden" name="id" value="${article.id}">
                                            
                                            <div class="form-group">
                                                <label>Tiêu đề</label>
                                                <input type="text" class="form-control" name="title" value="${article.title}" required>
                                            </div>

                                            <div class="form-group">
                                                <label>Nội dung</label>
                                                <textarea class="form-control" name="content" rows="10" required>${article.content}</textarea>
                                            </div>

                                            <div class="form-group">
                                                <label>Trạng thái</label>
                                                <select class="form-control" name="status">
                                                    <option value="Draft" ${article.status == 'Draft' ? 'selected' : ''}>Draft</option>
                                                    <option value="Published" ${article.status == 'Published' ? 'selected' : ''}>Published</option>
                                                    <option value="Archived" ${article.status == 'Archived' ? 'selected' : ''}>Archived</option>
                                                </select>
                                            </div>

                                            <hr>
                                            <h5><i class="feather icon-paperclip mr-1"></i> Tài liệu đính kèm</h5>
                                            
                                            <div class="mb-3">
                                                <h6>Danh sách đính kèm hiện tại:</h6>
                                                <c:forEach var="file" items="${article.attachments}">
                                                    <div class="d-flex align-items-center mb-2">
                                                        <a href="<c:url value='/files/download?id=${file.id}'/>" target="_blank" class="mr-3">
                                                            <i class="feather icon-file mr-1"></i>${file.originalName}
                                                        </a>
                                                        <a href="<c:url value='/KnowledgeArticleAttachmentDelete?articleId=${article.id}&fileId=${file.id}'/>" 
                                                           class="text-danger" onclick="return confirm('Bạn có chắc muốn xóa file này?')">
                                                            <i class="feather icon-trash-2"></i>
                                                        </a>
                                                    </div>
                                                </c:forEach>
                                                <c:if test="${empty article.attachments}">
                                                    <p class="text-muted italic">Chưa có tệp đính kèm nào.</p>
                                                </c:if>
                                            </div>

                                            <div class="form-group">
                                                <label>Thêm đính kèm mới</label>
                                                <input type="file" name="newAttachment" class="form-control-file">
                                                <small class="text-muted">Dung lượng tối đa 15MB. Hỗ trợ JPG, PNG, PDF, Docx...</small>
                                            </div>

                                            <div class="mt-4 pt-2 border-top d-flex justify-content-between">
                                                <a href="KnowledgeArticleManage" class="btn btn-secondary">
                                                    <i class="feather icon-arrow-left mr-1"></i> Quay lại
                                                </a>
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="feather icon-save mr-1"></i> Lưu thay đổi
                                                </button>
                                            </div>
                                        </form>
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
