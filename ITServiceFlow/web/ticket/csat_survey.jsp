<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
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
    <title>Feedback Survey - ITServiceFlow</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        body { background-color: #f4f5f7; }

        .survey-wrapper {
            max-width: 640px;
            margin: 30px auto;
            padding: 0 15px 60px;
        }

        /* ── Card ── */
        .survey-card {
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 12px rgba(9,30,66,0.08);
            border: 1px solid #dfe1e6;
            overflow: hidden;
        }

        /* ── Header gradient ── */
        .survey-header {
            background: linear-gradient(135deg, #0052cc 0%, #0065ff 100%);
            color: #fff;
            padding: 28px 32px 22px;
        }
        .survey-header .icon-circle {
            width: 48px; height: 48px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 12px;
        }
        .survey-header .icon-circle i { font-size: 1.4rem; }
        .survey-header h4 { font-weight: 700; font-size: 1.25rem; margin-bottom: 4px; }
        .survey-header p  { opacity: .85; font-size: .875rem; margin: 0; }

        /* ── Ticket reference bar ── */
        .ticket-ref-bar {
            background: #f4f5f7;
            border-left: 3px solid #0052cc;
            padding: 11px 16px;
            font-size: .85rem; color: #5e6c84;
        }
        .ticket-ref-bar strong { color: #172b4d; }

        /* ── Body ── */
        .survey-body { padding: 28px 32px; }

        /* ── Star rating ── */
        .field-label {
            font-size: .75rem; font-weight: 700;
            color: #6b778c; text-transform: uppercase;
            letter-spacing: .5px; margin-bottom: 10px;
        }
        .stars-row { display: flex; gap: 4px; }
        .star-btn {
            font-size: 2.2rem;
            color: #dfe1e6;
            background: none; border: none; padding: 0 2px;
            cursor: pointer; line-height: 1;
            transition: color .1s, transform .1s;
        }
        .star-btn.lit  { color: #f6c90e; }
        .star-btn:active { transform: scale(.88); }
        .star-btn:focus  { outline: none; }
        .rating-hint { font-size: .82rem; color: #6b778c; min-height: 18px; margin-top: 6px; }
        .err-rating  { display: none; font-size: .8rem; color: #de350b; margin-top: 4px; }
        .err-rating.show { display: block; }

        /* ── Textarea ── */
        .comment-area { margin-top: 22px; }
        .comment-area textarea {
            border: 1px solid #c1c7d0; border-radius: 6px;
            font-size: .9rem; color: #172b4d;
            padding: 10px 14px; resize: vertical;
            transition: border-color .15s;
        }
        .comment-area textarea:focus {
            border-color: #0052cc;
            box-shadow: 0 0 0 2px rgba(0,82,204,.15);
            outline: none;
        }

        /* ── Submit button ── */
        .btn-survey-submit {
            background: #0052cc; color: #fff; border: none;
            padding: 11px 30px; border-radius: 6px;
            font-weight: 600; font-size: .9rem; cursor: pointer;
            transition: background .15s;
        }
        .btn-survey-submit:hover    { background: #003d99; }
        .btn-survey-submit:disabled { background: #b3c6e0; cursor: not-allowed; }

        /* ── Success / already submitted view ── */
        .success-circle {
            width: 64px; height: 64px;
            background: #e3fcef; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 16px;
            font-size: 1.8rem; color: #00875a;
        }
        /* Read-only stars */
        .stars-readonly span { font-size: 1.6rem; }
        .stars-readonly .filled { color: #f6c90e; }
        .stars-readonly .empty  { color: #dfe1e6; }

        /* ── Submitted comment box ── */
        .comment-box {
            background: #fafbfc; border: 1px solid #ebecf0;
            border-radius: 6px; padding: 12px 16px;
            font-size: .875rem; color: #172b4d;
            font-style: italic; margin-top: 6px;
        }
    </style>
</head>

<body>
    <jsp:include page="../includes/header.jsp" />
    <jsp:include page="../includes/sidebar.jsp" />

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">

                    <!-- Breadcrumb -->
                    <div class="page-header mb-3">
                        <div class="page-block">
                            <ul class="breadcrumb bg-transparent p-0 m-0">
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/Tickets" class="text-primary">
                                        <i class="feather icon-list mr-1"></i>My Requests
                                    </a>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="text-primary">
                                        ${ticket.ticketNumber}
                                    </a>
                                </li>
                                <li class="breadcrumb-item text-muted">Feedback Survey</li>
                            </ul>
                        </div>
                    </div>

                    <div class="survey-wrapper">
                        <div class="survey-card">

                            <!-- Header -->
                            <div class="survey-header">
                                <div class="icon-circle"><i class="feather icon-star"></i></div>
                                <h4>How did we do?</h4>
                                <p>Your feedback helps us improve IT support quality.</p>
                            </div>

                            <!-- Ticket reference -->
                            <div class="ticket-ref-bar">
                                <strong>${ticket.ticketNumber}</strong>
                                &nbsp;&mdash;&nbsp;
                                <c:out value="${ticket.title}" />
                            </div>

                            <div class="survey-body">

                                <%-- ═══════════════════════════════════
                                     CASE 1: Ticket chưa Closed
                                     ═══════════════════════════════════ --%>
                                <c:if test="${not empty errorMsg}">
                                    <div class="alert alert-warning rounded">
                                        <i class="feather icon-alert-triangle mr-1"></i>
                                        ${errorMsg}
                                    </div>
                                    <div class="mt-3">
                                        <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}"
                                           class="btn btn-outline-secondary btn-sm">
                                            <i class="feather icon-arrow-left mr-1"></i>Back to Ticket
                                        </a>
                                    </div>
                                </c:if>

                                <%-- ═══════════════════════════════════
                                     CASE 2: Đã submit trước đó → hiển thị kết quả
                                     ═══════════════════════════════════ --%>
                                <c:if test="${not empty existingSurvey}">
                                    <div class="text-center mb-4">
                                        <div class="success-circle"><i class="feather icon-check"></i></div>
                                        <h5 class="font-weight-bold text-dark">Thank you for your feedback!</h5>
                                        <p class="text-muted" style="font-size:.875rem;">
                                            You've already submitted a survey for this ticket.
                                        </p>
                                    </div>

                                    <p class="field-label">Your Rating</p>
                                    <div class="stars-readonly mb-1">
                                        <c:forEach begin="1" end="5" var="i">
                                            <c:choose>
                                                <c:when test="${i <= existingSurvey.rating}">
                                                    <span class="filled">&#9733;</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="empty">&#9734;</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                        <span class="ml-2 text-muted" style="font-size:.85rem;">
                                            ${existingSurvey.rating}/5
                                        </span>
                                    </div>

                                    <c:if test="${not empty existingSurvey.comment}">
                                        <p class="field-label mt-3">Your Comment</p>
                                        <div class="comment-box">
                                            "<c:out value='${existingSurvey.comment}' />"
                                        </div>
                                    </c:if>

                                    <p class="text-muted mt-3" style="font-size:.8rem;">
                                        <i class="feather icon-clock mr-1"></i>
                                        Submitted on
                                        <fmt:formatDate value="${existingSurvey.submittedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </p>

                                    <div class="mt-4">
                                        <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}"
                                           class="btn btn-outline-primary btn-sm">
                                            <i class="feather icon-arrow-left mr-1"></i>Back to Ticket
                                        </a>
                                    </div>
                                </c:if>

                                <%-- ═══════════════════════════════════
                                     CASE 3: Submit thành công vừa xong
                                     ═══════════════════════════════════ --%>
                                <c:if test="${param.success == '1' && empty existingSurvey && empty errorMsg}">
                                    <div class="text-center">
                                        <div class="success-circle"><i class="feather icon-check"></i></div>
                                        <h5 class="font-weight-bold text-dark">Feedback submitted!</h5>
                                        <p class="text-muted" style="font-size:.875rem;">
                                            Thank you for taking the time to rate our support.
                                        </p>
                                        <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}"
                                           class="btn btn-outline-primary btn-sm mt-2">
                                            <i class="feather icon-arrow-left mr-1"></i>Back to Ticket
                                        </a>
                                    </div>
                                </c:if>

                                <%-- ═══════════════════════════════════
                                     CASE 4: Form survey (chưa submit)
                                     ═══════════════════════════════════ --%>
                                <c:if test="${empty existingSurvey && empty errorMsg && param.success != '1'}">

                                    <c:if test="${param.error == 'save_failed'}">
                                        <div class="alert alert-danger rounded mb-3">
                                            <i class="feather icon-alert-circle mr-1"></i>
                                            An error occurred, please try again.
                                        </div>
                                    </c:if>
                                    <c:if test="${param.error == 'invalid_rating'}">
                                        <div class="alert alert-warning rounded mb-3">
                                            <i class="feather icon-alert-triangle mr-1"></i>
                                            Please select a valid rating (1–5 stars).
                                        </div>
                                    </c:if>

                                    <form action="${pageContext.request.contextPath}/CsatSurvey"
                                          method="post" id="csatForm" novalidate>

                                        <%-- Hidden fields --%>
                                        <input type="hidden" name="ticketId" value="${ticket.id}">
                                        <input type="hidden" name="rating"   id="ratingInput" value="0">

                                        <%-- Star rating --%>
                                        <p class="field-label">
                                            Overall Satisfaction
                                            <span class="text-danger">*</span>
                                        </p>
                                        <div class="stars-row" id="starRow">
                                            <button type="button" class="star-btn" data-v="1" title="Very Dissatisfied">&#9733;</button>
                                            <button type="button" class="star-btn" data-v="2" title="Dissatisfied">&#9733;</button>
                                            <button type="button" class="star-btn" data-v="3" title="Neutral">&#9733;</button>
                                            <button type="button" class="star-btn" data-v="4" title="Satisfied">&#9733;</button>
                                            <button type="button" class="star-btn" data-v="5" title="Very Satisfied">&#9733;</button>
                                        </div>
                                        <p class="rating-hint" id="ratingHint">Click a star to rate</p>
                                        <p class="err-rating" id="errRating">
                                            <i class="feather icon-alert-circle mr-1"></i>
                                            Please select a rating before submitting.
                                        </p>

                                        <%-- Comment --%>
                                        <div class="comment-area">
                                            <label class="field-label" for="comment">
                                                Additional Comments
                                                <span class="text-muted font-weight-normal text-lowercase">(optional)</span>
                                            </label>
                                            <textarea class="form-control mt-1"
                                                      id="comment" name="comment" rows="4"
                                                      maxlength="1000"
                                                      placeholder="Tell us what went well or how we can improve..."></textarea>
                                            <small class="text-muted float-right" id="charCount">0 / 1000</small>
                                        </div>

                                        <div class="d-flex align-items-center justify-content-between mt-4 pt-2">
                                            <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}"
                                               class="btn btn-outline-secondary">Cancel</a>
                                            <button type="submit" class="btn-survey-submit" id="submitBtn">
                                                <i class="feather icon-send mr-1"></i>Submit Feedback
                                            </button>
                                        </div>
                                    </form>
                                </c:if>

                            </div><%-- /.survey-body --%>
                        </div><%-- /.survey-card --%>
                    </div><%-- /.survey-wrapper --%>

                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>

    <script>
    (function () {
        var stars       = document.querySelectorAll('.star-btn');
        var ratingInput = document.getElementById('ratingInput');
        var ratingHint  = document.getElementById('ratingHint');
        var errRating   = document.getElementById('errRating');
        var form        = document.getElementById('csatForm');
        var textarea    = document.getElementById('comment');
        var charCount   = document.getElementById('charCount');

        if (!stars.length) return; // không có form (already-submitted view)

        var LABELS = {1:'Very Dissatisfied', 2:'Dissatisfied', 3:'Neutral', 4:'Satisfied', 5:'Very Satisfied'};
        var selected = 0;

        function paint(upTo, isHover) {
            stars.forEach(function(s) {
                var v = +s.dataset.v;
                s.classList.toggle('lit', v <= upTo);
            });
        }

        stars.forEach(function(star) {
            star.addEventListener('mouseenter', function() {
                paint(+star.dataset.v, true);
                ratingHint.textContent = LABELS[+star.dataset.v];
            });
            star.addEventListener('mouseleave', function() {
                paint(selected);
                ratingHint.textContent = selected ? LABELS[selected] : 'Click a star to rate';
            });
            star.addEventListener('click', function() {
                selected = +star.dataset.v;
                ratingInput.value = selected;
                paint(selected);
                ratingHint.textContent = LABELS[selected];
                if (errRating) errRating.classList.remove('show');
            });
        });

        // Char counter
        if (textarea && charCount) {
            textarea.addEventListener('input', function() {
                charCount.textContent = textarea.value.length + ' / 1000';
            });
        }

        // Form validation
        if (form) {
            form.addEventListener('submit', function(e) {
                if (selected === 0) {
                    e.preventDefault();
                    errRating.classList.add('show');
                    document.getElementById('starRow').scrollIntoView({behavior:'smooth', block:'center'});
                }
            });
        }
    })();
    </script>
</body>
</html>
