<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>CI Dependency Map | ITServiceFlow</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        #cy {
            width: 1100px;
            height: 700px;
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
        }
        .map-container {
            position: relative;
        }
        .map-controls {
            position: absolute;
            top: 10px;
            left: 10px;
            z-index: 10;
            background: rgba(255, 255, 255, 0.95);
            padding: 12px;
            border-radius: 6px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.15);
            min-width: 140px;
        }
        .map-controls .btn {
            margin-bottom: 5px;
            width: 100%;
            text-align: left;
        }
        .map-controls .btn:last-child {
            margin-bottom: 0;
        }
        .map-controls hr {
            margin: 8px 0;
        }
        .legend {
            position: absolute;
            bottom: 10px;
            right: 10px;
            z-index: 10;
            background: rgba(255, 255, 255, 0.95);
            padding: 15px;
            border-radius: 6px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.15);
            font-size: 12px;
        }
        .legend h6 {
            margin-bottom: 10px;
            font-weight: 600;
        }
        .legend-item {
            margin-bottom: 8px;
            display: flex;
            align-items: center;
        }
        .legend-color {
            display: inline-block;
            width: 14px;
            height: 14px;
            margin-right: 8px;
            border-radius: 3px;
        }
        .depth-selector {
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #dee2e6;
        }
        .depth-selector label {
            font-size: 11px;
            margin-bottom: 4px;
        }
        .depth-selector select {
            font-size: 12px;
        }
        .info-panel {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 10;
            background: rgba(255, 255, 255, 0.95);
            padding: 15px;
            border-radius: 6px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.15);
            max-width: 280px;
            display: none;
        }
        .info-panel.show {
            display: block;
        }
        .info-panel h6 {
            margin-bottom: 10px;
            color: #007bff;
        }
        .info-panel .info-row {
            margin-bottom: 6px;
            font-size: 12px;
        }
        .info-panel .info-label {
            font-weight: 600;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>

    <nav class="pcoded-navbar menupos-fixed menu-light brand-blue">
        <div class="navbar-wrapper">
            <div class="navbar-brand header-logo">
                <a href="index.jsp" class="b-brand">
                    <img src="assets/images/logo.svg" alt="ITServiceFlow" class="logo images">
                    <span class="b-title">ITServiceFlow</span>
                </a>
            </div>
            <div class="navbar-content scroll-div">
                <ul class="nav pcoded-inner-navbar">
                    <li class="nav-item">
                        <a href="index.jsp" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="ticket-list.jsp" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                            <span class="pcoded-mtext">Tickets</span>
                        </a>
                    </li>
                    <li class="nav-item active">
                        <a href="CIListServlet" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-database"></i></span>
                            <span class="pcoded-mtext">CMDB / Assets</span>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">
                            <div class="page-header">
                                <div class="row align-items-end">
                                    <div class="col-lg-8">
                                        <div class="page-header-title">
                                            <div class="d-inline">
                                                <h4><i class="feather icon-share-2"></i> CI Dependency Map</h4>
                                                <span>Visualize infrastructure dependencies and impact analysis</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 text-right">
                                        <a href="CIListServlet" class="btn btn-secondary btn-sm">
                                            <i class="feather icon-list"></i> Back to List
                                        </a>
                                        <c:if test="${not empty rootCI}">
                                            <a href="CIDetailServlet?id=${rootCI.id}" class="btn btn-primary btn-sm">
                                                <i class="feather icon-info"></i> CI Details
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <div class="page-body">
                                <div class="card">
                                    <div class="card-header">
                                        <div class="row align-items-center">
                                            <div class="col-md-8">
                                                <h5 class="mb-0">
                                                    <c:choose>
                                                        <c:when test="${not empty rootCI}">
                                                            Dependency Map: <strong>${rootCI.name}</strong>
                                                            <span class="text-muted">(${rootCI.assetTag})</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            Full Infrastructure Dependency Map
                                                        </c:otherwise>
                                                    </c:choose>
                                                </h5>
                                            </div>
                                            <div class="col-md-4 text-right">
                                                <span class="badge badge-info" id="nodeCount">0 CIs</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-block">
                                        <div class="map-container">
                                            <div class="map-controls">
                                                <button class="btn btn-outline-secondary btn-sm" onclick="fitToScreen()">
                                                    <i class="feather icon-maximize"></i> Fit
                                                </button>
                                                <button class="btn btn-outline-secondary btn-sm" onclick="zoomIn()">
                                                    <i class="feather icon-zoom-in"></i> Zoom In
                                                </button>
                                                <button class="btn btn-outline-secondary btn-sm" onclick="zoomOut()">
                                                    <i class="feather icon-zoom-out"></i> Zoom Out
                                                </button>
                                                <hr>
                                                <button class="btn btn-primary btn-sm" onclick="runLayout('breadthfirst')">
                                                    <i class="feather icon-layout"></i> Auto Layout
                                                </button>
                                            </div>

                                            <div id="cy"></div>

                                            <div class="legend">
                                                <h6><i class="feather icon-info"></i> Node Types</h6>
                                                <div class="legend-item">
                                                    <span class="legend-color" style="background: #007bff;"></span> Server
                                                </div>
                                                <div class="legend-item">
                                                    <span class="legend-color" style="background: #28a745;"></span> Database
                                                </div>
                                                <div class="legend-item">
                                                    <span class="legend-color" style="background: #ffc107;"></span> Application
                                                </div>
                                                <div class="legend-item">
                                                    <span class="legend-color" style="background: #dc3545;"></span> Network
                                                </div>
                                                <div class="legend-item">
                                                    <span class="legend-color" style="background: #6c757d;"></span> Other
                                                </div>
                                            </div>

                                            <div class="info-panel" id="infoPanel">
                                                <h6><i class="feather icon-server"></i> CI Details</h6>
                                                <div class="info-row">
                                                    <span class="info-label">Name:</span>
                                                    <span id="infoName"></span>
                                                </div>
                                                <div class="info-row">
                                                    <span class="info-label">Asset Tag:</span>
                                                    <span id="infoAssetTag"></span>
                                                </div>
                                                <div class="info-row">
                                                    <span class="info-label">Type:</span>
                                                    <span id="infoType"></span>
                                                </div>
                                                <div class="info-row">
                                                    <span class="info-label">Status:</span>
                                                    <span id="infoStatus"></span>
                                                </div>
                                                <div class="info-row mt-2">
                                                    <a id="infoLink" href="#" class="btn btn-xs btn-primary mr-1">
                                                        <i class="feather icon-eye"></i> Details
                                                    </a>
                                                    <a id="infoMapLink" href="#" class="btn btn-xs btn-info" >
                                                        <i class="feather icon-share-2"></i> Map
                                                    </a>
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
        </div>
    </div>

    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.26.0/cytoscape.min.js"></script>

    <script>
        var cy;
        var rootCIId = '${rootCI != null ? rootCI.id : ""}';

        document.addEventListener('DOMContentLoaded', function() {
            initCytoscape();
            loadData();
        });

        function initCytoscape() {
            cy = cytoscape({
                container: document.getElementById('cy'),
                style: [
                    {
                        selector: 'node',
                        style: {
                            'label': 'data(label)',
                            'text-valign': 'bottom',
                            'text-margin-y': 5,
                            'background-color': function(ele) {
                                var type = (ele.data('type') || '').toLowerCase();
                                switch(type) {
                                    case 'server': return '#007bff';
                                    case 'database': return '#28a745';
                                    case 'application': return '#ffc107';
                                    case 'network': return '#dc3545';
                                    default: return '#6c757d';
                                }
                            },
                            'width': 50,
                            'height': 50,
                            'font-size': '11px',
                            'color': '#333',
                            'text-wrap': 'wrap',
                            'text-max-width': '80px'
                        }
                    },
                    {
                        selector: 'node:selected',
                        style: {
                            'border-width': 3,
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
                layout: { name: 'grid' }
            });

            cy.on('tap', 'node', function(evt) {
                var node = evt.target;
                showNodeInfo(node.data());
            });

            cy.on('tap', function(evt) {
                if (evt.target === cy) {
                    document.getElementById('infoPanel').classList.remove('show');
                }
            });
        }

        function loadData() {
            var url = 'CIRelationshipMapServlet?format=json';
            if (rootCIId) {
                url += '&id=' + rootCIId;
            }

            fetch(url)
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    cy.elements().remove();
                    cy.add(data);
                    document.getElementById('nodeCount').textContent = cy.nodes().length + ' CIs';
                    runLayout('breadthfirst');
                })
                .catch(function(error) {
                    console.error('Error loading graph data:', error);
                });
        }

        function runLayout(name) {
            var layout = cy.layout({
                name: name,
                directed: true,
                padding: 50,
                animate: true,
                animationDuration: 500
            });
            layout.run();
        }

        function fitToScreen() {
            cy.fit(100);
        }

        function zoomIn() {
            cy.zoom({
                level: cy.zoom() * 1.2,
                renderedPosition: { x: cy.width() / 2, y: cy.height() / 2 }
            });
        }

        function zoomOut() {
            cy.zoom({
                level: cy.zoom() * 0.8,
                renderedPosition: { x: cy.width() / 2, y: cy.height() / 2 }
            });
        }

        function showNodeInfo(data) {
            document.getElementById('infoName').textContent = data.label || 'N/A';
            document.getElementById('infoAssetTag').textContent = data.assetTag || 'N/A';
            document.getElementById('infoType').textContent = data.type || 'N/A';

            var statusEl = document.getElementById('infoStatus');
            var status = (data.status || '').toLowerCase();
            statusEl.textContent = data.status || 'N/A';

            if (status === 'active') {
                statusEl.className = 'badge badge-success';
            } else if (status === 'inactive') {
                statusEl.className = 'badge badge-secondary';
            } else if (status === 'maintenance') {
                statusEl.className = 'badge badge-warning';
            } else {
                statusEl.className = 'badge badge-light';
            }

            document.getElementById('infoLink').href = 'CIDetailServlet?id=' + data.id;
            
            // Update "View Relationship Map" link for the specific node
            var mapLink = document.getElementById('infoMapLink');
            if (mapLink) {
                mapLink.href = 'CIRelationshipMapServlet?id=' + data.id;
            }
            
            document.getElementById('infoPanel').classList.add('show');
        }
    </script>
</body>
</html>