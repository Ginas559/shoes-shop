<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<!-- Styles -->
<style>
  .recent-grid .card-img-top{
    aspect-ratio: 1 / 1;
    object-fit: cover;
  }
  .recent-header{
    display:flex;align-items:center;justify-content:space-between;gap:12px;
  }
</style>

<div class="container py-3">
  <div class="recent-header mb-3">
    <h1 class="h4 fw-semibold m-0">Bạn đã xem gần đây</h1>
    <a class="btn btn-sm btn-outline-secondary" href="${ctx}/products">Tiếp tục mua sắm</a>
  </div>

  <c:choose>
    <%-- Ưu tiên dùng recentItems (đã có coverUrl thật) --%>
    <c:when test="${not empty recentItems}">
      <div class="row row-cols-2 row-cols-md-3 row-cols-lg-6 g-3 recent-grid">
        <c:forEach var="item" items="${recentItems}">
          <%-- Resolve coverUrl an toàn --%>
          <c:set var="rvRaw"   value="${empty item.coverUrl ? '' : item.coverUrl}"/>
          <c:set var="rvFixed" value="${fn:replace(rvRaw, '/assset/', '/assets/')}"/>
          <c:choose>
            <c:when test="${fn:startsWith(rvFixed,'http://') or fn:startsWith(rvFixed,'https://')}">
              <c:set var="rvCover" value="${rvFixed}"/>
            </c:when>
            <c:when test="${fn:startsWith(rvFixed,'/assets/')}">
              <c:set var="rvCover" value="${ctx.concat(rvFixed)}"/>
            </c:when>
            <c:when test="${fn:startsWith(rvFixed,'/')}">
              <c:set var="rvCover" value="${rvFixed}"/>
            </c:when>
            <c:otherwise>
              <c:set var="rvCover" value="${ctx.concat('/assets/products/').concat(rvFixed)}"/>
            </c:otherwise>
          </c:choose>

          <div class="col">
            <div class="card h-100">
              <a href="${ctx}/product/${item.productId}">
                <img class="card-img-top"
                     src="${empty rvCover ? (ctx.concat('/assets/img/placeholder.png')) : rvCover}"
                     alt="<c:out value='${item.productName}'/>"
                     onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
              </a>
              <div class="card-body p-2">
                <div class="fw-semibold text-truncate" title="${item.productName}">
                  <c:out value="${item.productName}"/>
                </div>

                <%-- Giá VNĐ + rút gọn k/triệu --%>
                <c:set var="pMain" value="${not empty item.discountPrice ? item.discountPrice : item.price}"/>
                <div class="fw-bold">
                  <fmt:formatNumber value="${pMain}" type="number" maxFractionDigits="0"/> ₫
                  <span class="text-muted small">
                    (
                    <c:choose>
                      <c:when test="${pMain >= 1000000}">
                        <fmt:formatNumber value="${pMain / 1000000.0}" maxFractionDigits="1"/> triệu
                      </c:when>
                      <c:otherwise>
                        <fmt:formatNumber value="${pMain / 1000.0}" maxFractionDigits="0"/>k
                      </c:otherwise>
                    </c:choose>
                    )
                  </span>
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:when>

    <%-- Fallback: dùng recentProducts (không có coverUrl) với placeholder --%>
    <c:when test="${not empty recentProducts}">
      <div class="row row-cols-2 row-cols-md-3 row-cols-lg-6 g-3 recent-grid">
        <c:forEach var="p" items="${recentProducts}">
          <div class="col">
            <div class="card h-100">
              <a href="${ctx}/product/${p.productId}">
                <img class="card-img-top"
                     src="${ctx}/assets/img/placeholder.png"
                     alt="<c:out value='${p.productName}'/>"
                     onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
              </a>
              <div class="card-body p-2">
                <div class="fw-semibold text-truncate" title="${p.productName}">
                  <c:out value="${p.productName}"/>
                </div>

                <%-- Giá VNĐ + rút gọn k/triệu --%>
                <c:set var="pMain2" value="${not empty p.discountPrice ? p.discountPrice : p.price}"/>
                <div class="fw-bold">
                  <fmt:formatNumber value="${pMain2}" type="number" maxFractionDigits="0"/> ₫
                  <span class="text-muted small">
                    (
                    <c:choose>
                      <c:when test="${pMain2 >= 1000000}">
                        <fmt:formatNumber value="${pMain2 / 1000000.0}" maxFractionDigits="1"/> triệu
                      </c:when>
                      <c:otherwise>
                        <fmt:formatNumber value="${pMain2 / 1000.0}" maxFractionDigits="0"/>k
                      </c:otherwise>
                    </c:choose>
                    )
                  </span>
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:when>

    <c:otherwise>
      <!-- Empty state -->
      <div class="border rounded p-3 bg-light-subtle">
        <div class="d-flex align-items-center gap-3">
          <div class="rounded bg-white border d-flex align-items-center justify-content-center" style="width:56px;height:56px;">
            <span class="text-muted">🕘</span>
          </div>
          <div>
            <div class="fw-semibold">Chưa có lịch sử đã xem</div>
            <div class="text-muted small">Hãy duyệt vài sản phẩm — chúng sẽ xuất hiện ở đây để bạn mở lại nhanh.</div>
          </div>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>
