<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
  .fav-grid .card-img-top{
    aspect-ratio: 1 / 1;
    object-fit: cover;
  }
  .fav-header{
    display:flex;align-items:center;justify-content:space-between;gap:12px;
  }
  .fav-title{
    font-weight:600;
    color:#222;
    min-height:2.6em; /* giữ 2 dòng đều nhau */
    line-height:1.3;
  }
  .price-block .old{
    text-decoration: line-through;
    opacity:.65;
    font-size:.9rem;
    margin-left:.25rem;
  }
  .price-block .new{
    font-weight:700;
  }
</style>

<div class="container py-3">
  <div class="fav-header">
    <h3 class="m-0">Yêu thích của bạn</h3>
    <div class="d-flex gap-2">
      <a class="btn btn-outline-secondary" href="${ctx}/">Trang chủ</a>
      <a class="btn btn-outline-primary"  href="${ctx}/recent">Đã xem gần đây</a>
    </div>
  </div>

  <c:choose>
    <c:when test="${empty favorites}">
      <div class="alert alert-info mt-3">
        Chưa có sản phẩm yêu thích. Hãy nhấn ❤️ tại trang chi tiết sản phẩm để thêm vào danh sách.
      </div>
    </c:when>
    <c:otherwise>
      <div class="row row-cols-2 row-cols-md-6 g-3 fav-grid mt-2">
        <c:forEach var="it" items="${favorites}">
          <div class="col">
            <a class="card h-100 text-decoration-none" href="${ctx}/product/${it.productId}">
              <%-- Tạo URL ảnh an toàn với context-path + fallback --%>
              <c:set var="rawImg" value="${empty it.imageUrl ? '/assets/img/placeholder.png' : it.imageUrl}"/>
              <c:url value="${rawImg}" var="imgUrl"/>
              <img class="card-img-top" src="${imgUrl}" alt="${fn:escapeXml(it.productName)}">

              <div class="card-body">
                <div class="fav-title">${fn:escapeXml(it.productName)}</div>

                <div class="price-block mt-1">
                  <c:choose>
                    <c:when test="${it.discountPrice != null}">
                      <span class="new text-danger">
                        <fmt:formatNumber value="${it.discountPrice}" type="number" pattern="#,##0"/> ₫
                      </span>
                      <span class="old">
                        <fmt:formatNumber value="${it.price}" type="number" pattern="#,##0"/> ₫
                      </span>
                    </c:when>
                    <c:otherwise>
                      <span class="new">
                        <fmt:formatNumber value="${it.price}" type="number" pattern="#,##0"/> ₫
                      </span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </a>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>