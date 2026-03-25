<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <% if (session.getAttribute("user")==null) { response.sendRedirect("Login.jsp"); return; } 
           String role=(String) session.getAttribute("role"); 
           // Allow all roles to view knowledge articles
           if (role==null) { response.sendRedirect("Login.jsp"); return; } %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
                <meta http-equiv="X-UA-Compatible" content="IE=edge" />
                <title>${article != null ? article.title : 'Bài viết'} - Knowledge Base - ITServiceFlow</title>
                <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
                <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
                <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
                <link rel="stylesheet" href="assets/css/style.css">
                <style>
                    .article-header {
                        background: linear-gradient(135deg, #3f4d67 0%, #4f6082 100%);
                        color: #fff;
                        border-radius: 8px 8px 0 0;
                        padding: 28px 32px 20px;
                    }

                    .article-header h4 {
                        font-weight: 700;
                        margin-bottom: 8px;
                    }

                    .article-meta span {
                        font-size: 0.84rem;
                        opacity: 0.85;
                        margin-right: 18px;
                    }

                    .article-body {
                        background: #fff;
                        border: 1px solid #e8ecf1;
                        border-top: none;
                        border-radius: 0 0 8px 8px;
                        padding: 28px 32px;
                    }

                    .article-content {
                        line-height: 1.8;
                        font-size: 0.98rem;
                        color: #3a3a4a;
                        white-space: pre-wrap;
                    }

                    .badge-published {
                        background: #1dd393;
                        color: #fff;
                        border-radius: 4px;
                        padding: 3px 10px;
                        font-size: 0.78rem;
                        font-weight: 600;
                    }

                    .view-count-badge {
                        background: rgba(255, 255, 255, 0.18);
                        color: #fff;
                        border-radius: 4px;
                        padding: 2px 8px;
                        font-size: 0.8rem;
                    }
                </style>
            </head>

            <body>
                <div class="loader-bg">
                    <div class="loader-track">
                        <div class="loader-fill"></div>
                    </div>
                </div>
                <jsp:include page="includes/sidebar.jsp" />
                <jsp:include page="includes/header.jsp" />

                <div class="pcoded-main-container">
                    <div class="pcoded-wrapper">
                        <div class="pcoded-content">
                            <div class="pcoded-inner-content">

                                <!-- Breadcrumb -->
                                <div class="page-header">
                                    <div class="page-block">
                                        <div class="row align-items-center">
                                            <div class="col-md-12">
                                                <div class="page-header-title">
                                                    <h5 class="m-b-10">Knowledge Article</h5>
                                                </div>
                                                <ul class="breadcrumb">
                                                    <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i
                                                                class="feather icon-home"></i></a></li>
                                                    <li class="breadcrumb-item"><a href="KnowledgeSearch">Knowledge
                                                            Search</a></li>
                                                    <li class="breadcrumb-item active">Chi tiết bài viết</li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="main-body">
                                    <div class="page-wrapper">

                                        <c:if test="${not empty errorMessage}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="feather icon-alert-circle mr-2"></i> ${errorMessage}
                                                <button type="button" class="close"
                                                    data-dismiss="alert"><span>&times;</span></button>
                                            </div>
                                        </c:if>

                                        <div class="row">
                                            <div class="col-xl-12">
                                                <a href="KnowledgeSearch" class="btn btn-light btn-sm mb-3"
                                                    id="btn-back-search">
                                                    <i class="feather icon-arrow-left mr-1"></i> Quay lại tìm kiếm
                                                </a>

                                                <c:choose>
                                                    <c:when test="${not empty article}">
                                                        <!-- Article Header -->
                                                        <div class="article-header">
                                                            <div
                                                                class="d-flex justify-content-between align-items-start flex-wrap">
                                                                <div>
                                                                    <span class="badge-published mb-2 d-inline-block">
                                                                        <i class="feather icon-check-circle mr-1"></i>
                                                                        <c:out value="${article.status}" />
                                                                    </span>
                                                                    <h4>
                                                                        <c:out value="${article.title}" />
                                                                    </h4>
                                                                </div>
                                                                <span class="view-count-badge mt-1">
                                                                    <i
                                                                        class="feather icon-eye mr-1"></i>${article.viewCount
                                                                    != null ? article.viewCount : 0} lượt xem
                                                                </span>
                                                            </div>
                                                            <div class="article-meta mt-2">
                                                                <span><i class="feather icon-hash mr-1"></i>
                                                                    <c:out value="${article.articleNumber}" />
                                                                </span>
                                                                <span><i
                                                                        class="feather icon-calendar mr-1"></i>${article.createdAt}</span>
                                                            </div>
                                                        </div>

                                                        <!-- Article Body -->
                                                        <div class="article-body">
                                                            <h6 class="text-uppercase text-muted mb-3"
                                                                style="letter-spacing:0.08em; font-size:0.78rem;">
                                                                <i class="feather icon-align-left mr-1"></i> Nội dung
                                                                bài viết
                                                            </h6>
                                                            <div class="article-content" id="article-content">
                                                                <c:out value="${article.content}" />
                                                            </div>

                                                            <c:if test="${not empty attachments}">
                                                                <hr />
                                                                <h6 class="mb-2"><i class="feather icon-paperclip mr-1"></i> Đính kèm</h6>
                                                                <ul class="list-unstyled mb-3">
                                                                    <c:forEach items="${attachments}" var="att">
                                                                        <li class="mb-1">
                                                                            <i class="feather icon-file mr-1 text-muted"></i>
                                                                            <a href="${att.storagePath}" target="_blank">${att.originalName}</a>
                                                                            <small class="text-muted">(${att.mimeType})</small>
                                                                        </li>
                                                                    </c:forEach>
                                                                </ul>
                                                            </c:if>

                                                            <hr class="mt-4" />
                                                            <div
                                                                class="d-flex justify-content-between align-items-center flex-wrap pt-2">
                                                                <a href="KnowledgeSearch"
                                                                    class="btn btn-outline-secondary btn-sm"
                                                                    id="btn-back-bottom">
                                                                    <i class="feather icon-arrow-left mr-1"></i> Quay
                                                                    lại tìm kiếm
                                                                </a>
                                                                <a href="CreateTicket" class="btn btn-primary btn-sm"
                                                                    id="btn-create-ticket">
                                                                    <i class="feather icon-plus-circle mr-1"></i> Vẫn
                                                                    cần hỗ trợ? Tạo Ticket
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="card">
                                                            <div class="card-body text-center py-5">
                                                                <i class="feather icon-file-text"
                                                                    style="font-size:3rem; color:#dee2e6;"></i>
                                                                <h6 class="mt-3 text-muted">Bài viết không tồn tại hoặc
                                                                    đã bị xóa.</h6>
                                                                <a href="KnowledgeSearch" class="btn btn-primary mt-3"
                                                                    id="btn-go-search">Quay lại tìm kiếm</a>
                                                            </div>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <script src="assets/plugins/jquery/js/jquery.min.js"></script>
                <script src="assets/js/vendor-all.min.js"></script>
                <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
                <script src="assets/js/pcoded.min.js"></script>
                <script>
                    $(document).ready(function () {
                        $('.fixed-button').remove();
                    });
                </script>
            </body>

            </html>