<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Upload File - ITServiceFlow</title>
    <link rel="stylesheet" href="<c:url value='/assets/fonts/fontawesome/css/fontawesome-all.min.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/plugins/animation/css/animate.min.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/plugins/bootstrap/css/bootstrap.min.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css'/>">
</head>

<body>
    <div class="loader-bg">
        <div class="loader-track"><div class="loader-fill"></div></div>
    </div>

    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="page-header">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-10">Upload File Chung</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item active">Shared Upload</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper">
                            <div class="row">
                                <div class="col-sm-12 col-md-8 col-xl-7">
                                    <div class="card">
                                        <div class="card-header bg-light">
                                            <h5>Upload File (tối đa 15MB)</h5>
                                        </div>
                                        <div class="card-body">
                                            <form id="uploadForm" enctype="multipart/form-data">
                                                <div class="form-group mb-3">
                                                    <label>Chọn file</label>
                                                    <input type="file" id="fileInput" name="file" class="form-control-file" required>
                                                    <small class="form-text text-muted">PNG, JPG, PDF, DOC, DOCX, TXT (≤15MB)</small>
                                                </div>
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="feather icon-upload"></i> Upload
                                                </button>
                                            </form>

                                            <div id="progress" class="mt-3" style="display:none;">
                                                <div class="progress">
                                                    <div class="progress-bar" role="progressbar" style="width: 0%"></div>
                                                </div>
                                            </div>
                                            <div id="result" class="mt-3" style="display:none;"></div>
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

    <script src="<c:url value='/assets/js/vendor-all.min.js'/>"></script>
    <script src="<c:url value='/assets/plugins/bootstrap/js/bootstrap.min.js'/>"></script>
    <script src="<c:url value='/assets/js/pcoded.min.js'/>"></script>

    <script>
        const ctx = '<c:url value="/" />'.replace(/\/$/, '');
        const form = document.getElementById('uploadForm');
        const fileInput = document.getElementById('fileInput');
        const progressWrap = document.getElementById('progress');
        const progressBar = progressWrap.querySelector('.progress-bar');
        const result = document.getElementById('result');

        form.addEventListener('submit', function(e) {
            e.preventDefault();
            const file = fileInput.files[0];
            if (!file) {
                alert('Vui lòng chọn file');
                return;
            }

            const formData = new FormData();
            formData.append('file', file);

            progressWrap.style.display = 'block';
            result.style.display = 'none';
            progressBar.style.width = '0%';

            const xhr = new XMLHttpRequest();
            xhr.open('POST', form.action || '/ITServiceFlow/files/upload', true);
            xhr.upload.addEventListener('progress', function(evt) {
                if (evt.lengthComputable) {
                    const pct = (evt.loaded / evt.total) * 100;
                    progressBar.style.width = pct + '%';
                }
            });
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    progressWrap.style.display = 'none';
                    let msg;
                    if (xhr.status === 200) {
                        try {
                            const data = JSON.parse(xhr.responseText);
                            const fileUrl = data.url || (ctx + data.path);
                            msg = '<div class="alert alert-success">' +
                                  '<strong>Upload thành công!</strong><br>' +
                                  'File ID: ' + data.fileId + '<br>' +
                                  'Tên file: ' + data.originalName + '<br>' +
                                  'Đường dẫn: <a href="' + fileUrl + '" target="_blank">' + fileUrl + '</a>' +
                                  '</div>';
                            fileInput.value = '';
                        } catch (err) {
                            msg = '<div class="alert alert-danger">Không đọc được phản hồi máy chủ.</div>';
                        }
                    } else {
                        msg = '<div class="alert alert-danger">Lỗi: ' + (xhr.responseText || xhr.status) + '</div>';
                    }
                    result.innerHTML = msg;
                    result.style.display = 'block';
                }
            };
            xhr.send(formData);
        });
    </script>
</body>
</html>