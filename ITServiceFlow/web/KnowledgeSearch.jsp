<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <% if (session.getAttribute("user")==null) { response.sendRedirect("Login.jsp"); return; } 
           String role=(String) session.getAttribute("role"); 
           // Allow all roles to search the knowledge base
           if (role==null) { response.sendRedirect("Login.jsp"); return; } 
           model.Users currentUser=(model.Users) session.getAttribute("user"); %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
                <meta http-equiv="X-UA-Compatible" content="IE=edge" />
                <title>Knowledge Search - ITServiceFlow</title>
                <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
                <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
                <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
                <link rel="stylesheet" href="assets/css/style.css">
                <style>
                    .kb-card {
                        border: 1px solid #e8ecf1;
                        border-radius: 8px;
                        padding: 16px 20px;
                        margin-bottom: 14px;
                        background: #fff;
                        transition: box-shadow 0.2s, border-color 0.2s;
                    }

                    .kb-card:hover {
                        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.10);
                        border-color: #3f4d67;
                    }

                    .kb-title {
                        font-size: 1.05rem;
                        font-weight: 600;
                        color: #3f4d67;
                        margin-bottom: 4px;
                    }

                    .kb-meta {
                        font-size: 0.82rem;
                        color: #868e96;
                    }

                    .search-bar-group .form-control {
                        border-radius: 6px 0 0 6px;
                        font-size: 0.97rem;
                    }

                    .search-bar-group .btn {
                        border-radius: 0 6px 6px 0;
                    }

                    .badge-published {
                        background: #1dd393;
                        color: #fff;
                        border-radius: 4px;
                        padding: 2px 8px;
                        font-size: 0.75rem;
                    }

                    .no-result-icon {
                        font-size: 3rem;
                        color: #dee2e6;
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
                                                    <h5 class="m-b-10">Knowledge Search</h5>
                                                </div>
                                                <ul class="breadcrumb">
                                                    <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i
                                                                class="feather icon-home"></i></a></li>
                                                    <li class="breadcrumb-item"><a href="#">Knowledge</a></li>
                                                    <li class="breadcrumb-item active">Tìm kiếm</li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="main-body">
                                    <div class="page-wrapper">

                                        <!-- Error / Success alerts -->
                                        <c:if test="${not empty errorMessage}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="feather icon-alert-circle mr-2"></i> ${errorMessage}
                                                <button type="button" class="close"
                                                    data-dismiss="alert"><span>&times;</span></button>
                                            </div>
                                        </c:if>

                                        <!-- Search Card -->
                                        <div class="row">
                                            <div class="col-xl-12">
                                                <div class="card">
                                                    <div class="card-header">
                                                        <h5><i class="feather icon-book-open mr-2"></i>Tìm kiếm Kho Tri
                                                            Thức</h5>
                                                        <span class="text-muted" style="font-size:0.88rem;">Tìm hướng
                                                            dẫn khắc phục sự cố trước khi tạo ticket</span>
                                                    </div>
                                                    <div class="card-body">
                                                        <form action="KnowledgeSearch" method="GET">
                                                            <div class="input-group search-bar-group mb-3"
                                                                style="max-width:600px;">
                                                                <input type="text" class="form-control" name="keyword"
                                                                    value="<c:out value='${keyword}'/>"
                                                                    placeholder="Nhập từ khóa (ví dụ: lỗi mạng, màn hình xanh...)">
                                                                <div class="input-group-append">
                                                                    <button class="btn btn-primary" type="submit"
                                                                        id="btn-search">
                                                                        <i class="feather icon-search"></i> Tìm kiếm
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        </form>

                                                        <!-- Results -->
                                                        <c:choose>
                                                            <c:when test="${not empty keyword}">
                                                                <p class="text-muted mb-3">
                                                                    Kết quả cho: <strong>"
                                                                        <c:out value="${keyword}" />"
                                                                    </strong>
                                                                    — tìm thấy <strong>${totalResults}</strong> bài viết
                                                                </p>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <p class="text-muted mb-3">Hiển thị tất cả bài viết đã
                                                                    xuất bản (<strong>${totalResults}</strong> bài)</p>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <c:choose>
                                                            <c:when test="${empty articleList}">
                                                                <div class="text-center py-5">
                                                                    <div class="no-result-icon mb-3"><i
                                                                            class="feather icon-search"></i></div>
                                                                    <h6 class="text-muted">Không tìm thấy bài viết nào
                                                                    </h6>
                                                                    <p class="text-muted" style="font-size:0.88rem;">
                                                                        Thử từ khóa khác hoặc
                                                                        <a href="CreateTicket" class="text-primary">tạo
                                                                            ticket hỗ trợ</a> nếu vấn đề chưa có hướng
                                                                        dẫn.
                                                                    </p>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="art" items="${articleList}">
                                                                    <div class="kb-card" id="kb-article-${art.id}">
                                                                        <div
                                                                            class="d-flex justify-content-between align-items-start">
                                                                            <div>
                                                                                <div class="kb-title">
                                                                                    <i
                                                                                        class="feather icon-file-text mr-1"></i>
                                                                                    <a href="KnowledgeArticleView?id=${art.id}"
                                                                                        class="text-decoration-none"
                                                                                        style="color:inherit;">
                                                                                        <c:out value="${art.title}" />
                                                                                    </a>
                                                                                </div>
                                                                                <div class="kb-meta mt-1">
                                                                                    <span class="badge-published mr-2">
                                                                                        <c:out value="${art.status}" />
                                                                                    </span>
                                                                                    <span><i
                                                                                            class="feather icon-hash mr-1"></i>
                                                                                        <c:out
                                                                                            value="${art.articleNumber}" />
                                                                                    </span>
                                                                                    <span class="ml-3"><i
                                                                                            class="feather icon-eye mr-1"></i>${art.viewCount
                                                                                        != null ? art.viewCount : 0}
                                                                                        lượt xem</span>
                                                                                </div>
                                                                            </div>
                                                                            <a href="KnowledgeArticleView?id=${art.id}"
                                                                                class="btn btn-sm btn-outline-primary ml-3"
                                                                                id="view-article-${art.id}">
                                                                                Xem chi tiết <i
                                                                                    class="feather icon-chevron-right"></i>
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                                </c:forEach>
                                                            </c:otherwise>
                                                        </c:choose>

                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- End row -->

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