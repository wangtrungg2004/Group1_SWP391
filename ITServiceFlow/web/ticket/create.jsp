<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
        <title>IT Service Portal - ITServiceFlow</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

        <style>
            /* Container Constraint for Balance */
            .portal-container {
                max-width: 1100px;
                margin: 0 auto;
                padding-top: 20px;
            }

            /* Hero Search Section */
            .invgate-hero {
                background: linear-gradient(135deg, #0052cc 0%, #0747a6 100%);
                padding: 60px 20px;
                text-align: center;
                border-radius: 12px;
                margin-bottom: 40px;
                color: white;
                box-shadow: 0 10px 20px rgba(0,82,204,0.15);
            }
            .invgate-hero h2 {
                font-weight: 700;
                color: white;
                margin-bottom: 25px;
                font-size: 2.2rem;
            }
            .search-bar-wrapper {
                max-width: 650px;
                margin: 0 auto;
                position: relative;
            }
            .search-bar-wrapper input {
                width: 100%;
                padding: 18px 25px 18px 55px;
                border-radius: 30px;
                border: none;
                font-size: 1.1rem;
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                outline: none;
                transition: all 0.3s;
            }
            .search-bar-wrapper input:focus {
                box-shadow: 0 6px 20px rgba(0,0,0,0.2);
            }
            .search-bar-wrapper i {
                position: absolute;
                left: 20px;
                top: 50%;
                transform: translateY(-50%);
                color: #5e6c84;
                font-size: 1.3rem;
            }

            /* Card Grid (Step 1) */
            .category-card {
                background: white;
                border-radius: 12px;
                padding: 30px 20px;
                text-align: center;
                cursor: pointer;
                border: 1px solid #dfe1e6;
                transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
                height: 100%;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
            }
            .category-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 24px rgba(9, 30, 66, 0.1);
                border-color: #0052cc;
            }
            .category-icon {
                font-size: 2.8rem;
                margin-bottom: 20px;
                color: #0052cc;
            }
            .category-title {
                font-size: 1.15rem;
                font-weight: 700;
                color: #172b4d;
                margin-bottom: 10px;
            }
            .category-desc {
                font-size: 0.9rem;
                color: #5e6c84;
                line-height: 1.4;
            }

            /* Drill-down List (Step 2) */
            .drilldown-header {
                display: flex;
                align-items: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid #dfe1e6;
            }
            .btn-back {
                background: #ebecf0;
                color: #172b4d;
                border: none;
                padding: 10px 20px;
                border-radius: 6px;
                font-weight: 600;
                cursor: pointer;
                transition: 0.2s;
                margin-right: 20px;
                font-size: 0.95rem;
            }
            .btn-back:hover {
                background: #dfe1e6;
            }
            .group-title {
                font-size: 1rem;
                font-weight: 700;
                color: #5e6c84;
                margin: 25px 0 15px 0;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .action-item {
                background: white;
                border: 1px solid #dfe1e6;
                border-radius: 8px;
                padding: 18px 25px;
                margin-bottom: 12px;
                cursor: pointer;
                display: flex;
                align-items: center;
                transition: 0.2s;
                box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            }
            .action-item:hover {
                border-color: #0052cc;
                background: #e9f2ff;
                box-shadow: 0 4px 8px rgba(0,82,204,0.08);
            }
            .action-item i {
                font-size: 1.5rem;
                color: #0052cc;
                margin-right: 20px;
            }
            .action-item-text {
                font-weight: 600;
                color: #172b4d;
                font-size: 1.1rem;
                flex-grow: 1;
            }
            .action-item-arrow {
                color: #8993a4;
            }

            /* Checkout Form (Step 3) */
            .form-panel-wrapper {
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.05);
                border: 1px solid #dfe1e6;
            }
            .selected-action-badge {
                display: inline-flex;
                align-items: center;
                background: #e3fcef;
                color: #00875a;
                padding: 8px 16px;
                border-radius: 30px;
                font-weight: 700;
                font-size: 0.9rem;
                margin-bottom: 30px;
                border: 1px solid #79f2c0;
            }
            .selected-action-badge i {
                margin-right: 8px;
                font-size: 1.1rem;
            }

            /* Radio Tiles (Impact & Urgency) */
            .radio-tile-group {
                display: flex;
                gap: 15px;
            }
            .radio-tile-label {
                cursor: pointer;
                flex: 1;
            }
            .radio-tile-label input {
                display: none;
            }
            .radio-tile {
                border: 2px solid #dfe1e6;
                border-radius: 8px;
                padding: 18px 12px;
                text-align: center;
                transition: 0.2s;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.95rem;
                color: #42526e;
                font-weight: 600;
            }
            .radio-tile-label input:checked + .radio-tile {
                border-color: #0052cc;
                background-color: #e9f2ff;
                color: #0052cc;
                box-shadow: 0 4px 8px rgba(0,82,204,0.15);
            }
            .radio-tile-label input:hover:not(:checked) + .radio-tile {
                border-color: #b3bac5;
                background-color: #f4f5f7;
            }

            /* Custom File Input Upload Area */
            .file-upload-wrapper {
                border: 2px dashed #dfe1e6;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                background-color: #fafbfc;
                transition: 0.2s;
            }
            .file-upload-wrapper:hover {
                border-color: #0052cc;
                background-color: #f4f5f7;
            }

            /* Animation */
            .fade-in {
                animation: fadeIn 0.3s ease-in-out;
            }
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(15px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
        </style>
    </head>

<body class="">
        <div class="loader-bg"><div class="loader-track"><div class="loader-fill"></div></div></div>

        <jsp:include page="../includes/header.jsp" />
        <jsp:include page="../includes/sidebar.jsp" />

        <div class="pcoded-main-container">
            <div class="pcoded-wrapper">
                <div class="pcoded-content">
                    <div class="pcoded-inner-content">

                        <div class="main-body">
                            <div class="page-wrapper portal-container"> 

                                <c:if test="${not empty errorMessage}">
                                    <div class="alert alert-danger mb-4 shadow-sm"><i class="feather icon-alert-circle mr-2"></i>${errorMessage}</div>
                                </c:if>

                                <div id="step1-root" class="fade-in">
                                    <div class="invgate-hero">
                                        <h2>Hello, how can we help you today?</h2>
                                        <div class="search-bar-wrapper">
                                            <i class="feather icon-search"></i>
                                            <input type="text" id="searchInput" placeholder="Search for services, report issues..." onkeyup="filterCards()">
                                        </div>
                                    </div>

                                    <h4 class="font-weight-bold mb-4 text-dark text-center">Support Categories</h4>
                                    <div class="row justify-content-center" id="rootCardsContainer">
                                    </div>
                                </div>

                                <div id="step2-drilldown" style="display: none;" class="fade-in">
                                    <div class="drilldown-header">
                                        <button class="btn-back" onclick="goBackToStep1()"><i class="feather icon-arrow-left"></i> Back</button>
                                        <h3 class="m-0 font-weight-bold text-dark" id="drilldownTitle">Category Title</h3>
                                    </div>
                                    <div class="row justify-content-center">
                                        <div class="col-xl-9 col-lg-10" id="subItemsContainer">
                                        </div>
                                    </div>
                                </div>

                                <div id="step3-form" style="display: none;" class="fade-in">
                                    <div class="drilldown-header">
                                        <button class="btn-back" onclick="goBackToStep2()"><i class="feather icon-arrow-left"></i> Back</button>
                                        <h3 class="m-0 font-weight-bold text-dark">Complete Your Request</h3>
                                    </div>

                                    <div class="row justify-content-center">
                                        <div class="col-xl-9 col-lg-10">
                                            <div class="form-panel-wrapper">
                                                <div class="selected-action-badge" id="selectedActionLabel"><i class="feather icon-check-circle"></i> Requesting: ...</div>

                                                <form action="${pageContext.request.contextPath}/CreateTicket" method="POST" id="ticketForm" enctype="multipart/form-data">
                                                    <input type="hidden" name="ticketType" id="payload_ticketType">
                                                    <input type="hidden" name="categoryId" id="payload_categoryId">
                                                    <input type="hidden" name="serviceCatalogId" id="payload_serviceCatalogId">

                                                    <div class="form-group mb-4">
                                                        <label class="font-weight-bold">Summary <span class="text-danger">*</span></label>
                                                        <input type="text" name="title" class="form-control" placeholder="E.g., Cannot connect to the ERP system..." required maxlength="255">
                                                    </div>

                                                    <div class="form-group mb-4">
                                                        <label class="font-weight-bold">Detailed Description <span class="text-danger">*</span></label>
                                                        <textarea name="description" class="form-control" rows="5" placeholder="Please provide as much detail as possible..." required></textarea>
                                                    </div>

<!--                                                    <div class="form-group mb-4">
                                                        <label class="font-weight-bold">Asset tag <span class="text-danger">*</span></label>
                                                        <input type="text" name="assetTag" class="form-control" placeholder="E.g., CI-001" maxlength="120" autocomplete="off" required value="${assetTag_val}">
                                                    </div>

                                                    <div class="form-group mb-4">
                                                        <label class="font-weight-bold">Attachments <span class="text-muted" style="font-weight:normal; font-size:0.85rem;">(Max 15MB/file)</span></label>
                                                        <div class="file-upload-wrapper">
                                                            <input type="file" name="attachments" class="form-control-file d-block w-100" multiple>
                                                        </div>
                                                        <c:if test="${not empty uploadWarning}">
                                                            <div class="text-warning mt-2 font-weight-bold"><i class="feather icon-alert-triangle mr-1"></i>${uploadWarning}</div>
                                                        </c:if>
                                                    </div>-->

                                                    <div id="incidentQuestions" style="display: none;">
                                                        <hr class="my-5">
                                                        <h5 class="font-weight-bold mb-4 text-primary">Priority Assessment</h5>
                                                        <div class="row">
                                                            <div class="col-md-6 mb-4">
                                                                <label class="font-weight-bold text-muted mb-3">Who is affected? (Impact) <span class="text-danger">*</span></label>
                                                                <div class="radio-tile-group flex-column">
                                                                    <label class="radio-tile-label"><input type="radio" name="impact" value="3" class="inc-req"><div class="radio-tile">Just me</div></label>
                                                                    <label class="radio-tile-label"><input type="radio" name="impact" value="2" class="inc-req"><div class="radio-tile">My department / team</div></label>
                                                                    <label class="radio-tile-label"><input type="radio" name="impact" value="1" class="inc-req"><div class="radio-tile">The whole company</div></label>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-6 mb-4">
                                                                <label class="font-weight-bold text-muted mb-3">How does this impede work? (Urgency) <span class="text-danger">*</span></label>
                                                                <div class="radio-tile-group flex-column">
                                                                    <label class="radio-tile-label"><input type="radio" name="urgency" value="3" class="inc-req"><div class="radio-tile">I have a workaround</div></label>
                                                                    <label class="radio-tile-label"><input type="radio" name="urgency" value="2" class="inc-req"><div class="radio-tile">My work is partially impeded</div></label>
                                                                    <label class="radio-tile-label"><input type="radio" name="urgency" value="1" class="inc-req"><div class="radio-tile">I cannot work at all</div></label>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="text-right mt-5 pt-4 border-top">
                                                        <button type="submit" class="btn btn-primary btn-lg shadow-sm px-5"><i class="feather icon-send"></i> Submit Request</button>
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
        </div>

        <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>

       <script>
            // 1. Dữ liệu nạp từ Database
            var categories = [
            <c:forEach items="${categoryList}" var="cat" varStatus="loop">
                { 
                    id: ${cat.id}, 
                    name: "${cat.name}", 
                    parentId: <c:out value="${cat.parentId}" default="null" />, 
                    level: ${cat.level} 
                }${!loop.last ? ',' : ''}
            </c:forEach>
            ];

            var services = [
            <c:forEach items="${serviceList}" var="svc" varStatus="loop">
                { 
                    id: ${svc.id}, 
                    name: "${svc.name}", 
                    categoryId: ${svc.categoryId}, 
                    isActive: ${svc.isActive} 
                }${!loop.last ? ',' : ''}
            </c:forEach>
            ];

            var currentRootId = null;
            var currentRootName = null;

            // Map UI Icon & Text cho 6 Root Categories
            const uiMap = {
                1: {icon: 'icon-wifi', desc: 'Internet, Wi-Fi, VPN, Firewall...'},
                2: {icon: 'icon-cpu', desc: 'OS, Office Apps, ERP, CRM...'},
                3: {icon: 'icon-monitor', desc: 'Laptops, Peripherals, Servers...'},
                50: {icon: 'icon-shopping-cart', desc: 'Request new devices and accessories'},
                51: {icon: 'icon-download', desc: 'Request software installations and licenses'},
                52: {icon: 'icon-user-plus', desc: 'Request account creation and permissions'}
            };

            window.onload = function () {
                renderStep1();
            };

            // ==========================================
            // STEP 1: RENDER LƯỚI THẺ (ROOT CARDS)
            // ==========================================
            function renderStep1() {
                let container = document.getElementById("rootCardsContainer");
                container.innerHTML = "";

                let roots = categories.filter(function(c) { return c.level === 1; });

                roots.forEach(function(root) {
                    let ui = uiMap[root.id] || {icon: 'icon-grid', desc: 'Other IT Services'};

                    // Fix lỗi JSP EL bằng cách dùng phép cộng chuỗi truyền thống
                    let html = '<div class="col-md-6 col-lg-4 mb-4 root-card-item">' +
                               '<div class="category-card" onclick="goToStep2(' + root.id + ', \'' + root.name + '\')">' +
                               '<div class="category-icon"><i class="feather ' + ui.icon + '"></i></div>' +
                               '<h4 class="category-title">' + root.name + '</h4>' +
                               '<p class="category-desc">' + ui.desc + '</p>' +
                               '</div></div>';
                    
                    container.innerHTML += html;
                });
            }

            // ==========================================
            // STEP 2: RENDER HÀNH ĐỘNG CHI TIẾT
            // ==========================================
            function goToStep2(rootId, rootName) {
                currentRootId = rootId;
                currentRootName = rootName;

                document.getElementById("step1-root").style.display = "none";
                document.getElementById("step2-drilldown").style.display = "block";
                document.getElementById("drilldownTitle").innerText = rootName;

                let container = document.getElementById("subItemsContainer");
                container.innerHTML = "";

                let l2Cats = categories.filter(function(c) { return c.parentId === rootId; });
                let rootServices = services.filter(function(s) { return s.categoryId === rootId && s.isActive; });

                if (l2Cats.length > 0) {
                    container.innerHTML += '<div class="group-title mt-4"><i class="feather icon-alert-triangle mr-1"></i> Report an Issue</div>';
                    l2Cats.forEach(function(l2) {
                        let html = '<div class="action-item" onclick="goToStep3(\'Incident\', ' + l2.id + ', \'' + l2.name + '\')">' +
                                   '<i class="feather icon-alert-octagon text-danger"></i>' +
                                   '<div class="action-item-text">' + l2.name + '</div>' +
                                   '<i class="feather icon-chevron-right action-item-arrow"></i>' +
                                   '</div>';
                        container.innerHTML += html;
                    });
                } 
                else if (rootServices.length > 0) {
                    container.innerHTML += '<div class="group-title mt-4"><i class="feather icon-shopping-cart mr-1"></i> Request a Service</div>';
                    rootServices.forEach(function(svc) {
                        let html = '<div class="action-item" onclick="goToStep3(\'ServiceRequest\', ' + svc.id + ', \'' + svc.name + '\')">' +
                                   '<i class="feather icon-monitor text-primary"></i>' +
                                   '<div class="action-item-text">' + svc.name + '</div>' +
                                   '<i class="feather icon-chevron-right action-item-arrow"></i>' +
                                   '</div>';
                        container.innerHTML += html;
                    });
                } 
                else {
                    container.innerHTML = '<div class="text-center text-muted my-4">No categories or services available here.</div>';
                }
            }

            // ==========================================
            // STEP 3: MỞ FORM NHẬP LIỆU
            // ==========================================
            function goToStep3(type, itemId, itemName) {
                document.getElementById("step2-drilldown").style.display = "none";
                document.getElementById("step3-form").style.display = "block";

                document.getElementById("selectedActionLabel").innerHTML = '<i class="feather icon-check-circle"></i> ' + currentRootName + ' ➝ ' + itemName;

                document.getElementById("payload_ticketType").value = type;
                let incFields = document.querySelectorAll(".inc-req");

                if (type === 'Incident') {
                    document.getElementById("payload_categoryId").value = itemId;
                    document.getElementById("payload_serviceCatalogId").value = "";
                    document.getElementById("incidentQuestions").style.display = "block";
                    incFields.forEach(function(f) { f.required = true; });
                } else {
                    document.getElementById("payload_serviceCatalogId").value = itemId;
                    document.getElementById("payload_categoryId").value = "";
                    document.getElementById("incidentQuestions").style.display = "none";
                    incFields.forEach(function(f) { 
                        f.required = false; 
                        f.checked = false; 
                    });
                }
            }

            function goBackToStep1() {
                document.getElementById("step2-drilldown").style.display = "none";
                document.getElementById("step1-root").style.display = "block";
            }

            function goBackToStep2() {
                document.getElementById("step3-form").style.display = "none";
                goToStep2(currentRootId, currentRootName); 
            }

            function filterCards() {
                let filter = document.getElementById("searchInput").value.toLowerCase();
                let cards = document.getElementsByClassName("root-card-item");
                for (let i = 0; i < cards.length; i++) {
                    let title = cards[i].innerText.toLowerCase();
                    if (title.indexOf(filter) > -1) {
                        cards[i].style.display = "";
                    } else {
                        cards[i].style.display = "none";
                    }
                }
            }
        </script>
    </body>
</html>