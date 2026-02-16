
$path = 'd:\swpEmHoang\Group1_SWP391\ITServiceFlow\web\includes\sidebar.jsp';
$content = Get-Content $path -Encoding UTF8 -Raw;
$search = '<c:if test="${role == ''Admin'' || role == ''Manager''}">'
$insert = '
                <c:if test="${role == ''Admin'' || role == ''Manager''}">
                    <li class="nav-item pcoded-menu-caption">
                        <label>SLA Management</label>
                    </li>
                    <li class="nav-item">
                        <a href="SLAConfig" class="nav-link"><span class="pcoded-micon"><i class="feather icon-settings"></i></span><span class="pcoded-mtext">SLA Configuration</span></a>
                    </li>
                </c:if>
';
$content = $content.Replace($search, $insert + "`r`n" + $search);
Set-Content $path $content -Encoding UTF8;
Write-Output "Sidebar updated successfully"
