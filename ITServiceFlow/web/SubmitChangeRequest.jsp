<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Gửi Yêu cầu Thay đổi - ITServiceFlow</title>
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-content">
            <div class="page-header">
                <h5>Gửi Yêu cầu Thay đổi (Change Request)</h5>
            </div>

            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="card">
                <div class="card-body">
                    <form action="SubmitChangeRequest" method="post">
                        <div class="form-group mb-3">
                            <label>Tiêu đề yêu cầu</label>
                            <input type="text" name="title" class="form-control" required>
                        </div>
                        <div class="form-group mb-3">
                            <label>Mô tả chi tiết</label>
                            <textarea name="description" class="form-control" rows="4" required></textarea>
                        </div>
                        <div class="form-group mb-3">
                            <label>Loại thay đổi</label>
                            <input type="text" name="changeType" class="form-control" required placeholder="Ví dụ: Nâng cấp server, Cài phần mềm mới...">
                        </div>
                        <div class="form-group mb-3">
                            <label>Mức độ rủi ro (Risk Level) - Bắt buộc</label>
                            <select name="riskLevel" class="form-control" required>
                                <option value="">-- Chọn mức độ --</option>
                                <option value="Low">Low</option>
                                <option value="Medium">Medium</option>
                                <option value="High">High</option>
                                <option value="Critical">Critical</option>
                            </select>
                        </div>
                        <div class="form-group mb-3">
                            <label>Kế hoạch rollback (Rollback Plan) - Bắt buộc</label>
                            <textarea name="rollbackPlan" class="form-control" rows="3" required placeholder="Ví dụ: Restore backup, quay lại config cũ..."></textarea>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label>Thời gian bắt đầu dự kiến</label>
                                <input type="date" name="plannedStart" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label>Thời gian kết thúc dự kiến</label>
                                <input type="date" name="plannedEnd" class="form-control">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">Gửi yêu cầu thay đổi</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>