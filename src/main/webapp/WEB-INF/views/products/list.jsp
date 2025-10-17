<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h1 class="h5 mb-3">${empty pageTitle ? 'Sản phẩm' : pageTitle}</h1>

<form class="row g-2 mb-3" method="get" action="">
  <div class="col-12 col-md-4">
    <input class="form-control" name="q" value="${param.q}" placeholder="Tìm kiếm...">
  </div>

  <div class="col-6 col-md-3">
    <select class="form-select" name="catId">
      <option value="">Danh mục</option>
      <c:forEach var="c" items="${categories}">
        <option value="${c.categoryId}" ${c.categoryId==param.catId?'selected':''}>${c.categoryName}</option>
      </c:forEach>
    </select>
  </div>

  <div class="col-6 col-md-2">
    <input class="form-control" type="number" min="0" name="minPrice" value="${param.minPrice}" placeholder="Giá từ">
  </div>

  <div class="col-6 col-md-2">
    <input class="form-control" type="number" min="0" name="maxPrice" value="${param.maxPrice}" placeholder="Giá đến">
  </div>

  <div class="col-6 col-md-2">
    <select class="form-select" name="minRating">
      <option value="">Đánh giá</option>
      <c:forEach var="r" begin="1" end="5">
        <option value="${r}" ${param.minRating==r?'selected':''}>≥ ${r}★</option>
      </c:forEach>
    </select>
  </div>

  <div class="col-6 col-md-2">
    <select class="form-select" name="sort">
      <option value="">Sắp xếp</option>
      <option value="new_desc"    ${param.sort=='new_desc'?'selected':''}>Mới nhất</option>
      <option value="price_asc"   ${param.sort=='price_asc'?'selected':''}>Giá ↑</option>
      <option value="price_desc"  ${param.sort=='price_desc'?'selected':''}>Giá ↓</option>
      <option value="rating_desc" ${param.sort=='rating_desc'?'selected':''}>Đánh giá ↓</option>
    </select>
  </div>

  <!-- Page size (giữ nguyên backend hiện có: nếu không dùng, tham số này sẽ bị bỏ qua an toàn) -->
  <div class="col-6 col-md-2">
    <select class="form-select" name="size">
      <c:set var="currSize" value="${empty param.size ? (empty page.size ? 12 : page.size) : param.size}"/>
      <option value="12" ${currSize==12?'selected':''}>12 / trang</option>
      <option value="24" ${currSize==24?'selected':''}>24 / trang</option>
      <option value="36" ${currSize==36?'selected':''}>36 / trang</option>
    </select>
  </div>

  <div class="col-12 col-md-auto d-flex gap-2">
    <button class="btn btn-primary">Lọc</button>
    <a class="btn btn-outline-secondary"
       href="<c:url value='/products'/>">Xóa lọc</a>
  </div>
</form>

<c:set var="items" value="${empty page ? null : page.items}"/>

<c:choose>
  <c:when test="${not empty items}">
    <div class="row row-cols-2 row-cols-md-4 g-3">
      <c:forEach var="p" items="${items}">
        <div class="col">
          <div class="card h-100">
            <a href="${ctx}/product/${p.id}">
              <img class="card-img-top" style="aspect-ratio:1/1;object-fit:cover"
                   src="${empty p.coverUrl ? (ctx.concat('/assets/img/placeholder.png')) : p.coverUrl}"
                   alt="${p.name}">
            </a>

            <div class="card-body p-2 d-flex flex-column">
              <div class="small text-muted text-truncate" title="${p.categoryName}">${p.categoryName}</div>

              <div class="fw-semibold text-truncate mb-1" title="${p.name}">${p.name}</div>

              <div class="d-flex justify-content-between align-items-center mb-1">
                <div class="fw-bold">
                  <c:choose>
                    <c:when test="${not empty p.discountPrice}">
                      <span class="text-danger">
                        <fmt:formatNumber value="${p.discountPrice}" type="number" groupingUsed="true"/> ₫
                      </span>
                      <c:if test="${not empty p.price}">
                        <small class="text-muted text-decoration-line-through ms-2">
                          <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/> ₫
                        </small>
                      </c:if>
                    </c:when>
                    <c:when test="${not empty p.price}">
                      <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/> ₫
                    </c:when>
                    <c:otherwise>—</c:otherwise>
                  </c:choose>
                </div>

                <span class="small">
                  <c:set var="rAvg" value="${empty p.ratingAvg ? 0 : p.ratingAvg}"/>
                  <c:forEach var="i" begin="1" end="5">
                    <c:choose>
                      <c:when test="${i <= rAvg}"><span class="text-warning">★</span></c:when>
                      <c:otherwise><span class="text-secondary">☆</span></c:otherwise>
                    </c:choose>
                  </c:forEach>
                </span>
              </div>

              <a href="${ctx}/product/${p.id}" class="btn btn-outline-primary btn-sm mt-auto">Xem chi tiết</a>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>

    <c:if test="${page.totalPages > 1}">
      <nav class="mt-3">
        <ul class="pagination justify-content-center">
          <li class="page-item ${page.hasPrev ? '' : 'disabled'}">
            <a class="page-link"
               href="<c:url value='/products'>
                        <c:param name='q'         value='${param.q}'/>
                        <c:param name='catId'     value='${param.catId}'/>
                        <c:param name='minPrice'  value='${param.minPrice}'/>
                        <c:param name='maxPrice'  value='${param.maxPrice}'/>
                        <c:param name='minRating' value='${param.minRating}'/>
                        <c:param name='sort'      value='${param.sort}'/>
                        <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                        <c:param name='page'      value='${page.number-1}'/>
                    </c:url>">«</a>
          </li>

          <c:forEach var="i" begin="1" end="${page.totalPages}">
            <li class="page-item ${i==page.number?'active':''}">
              <a class="page-link"
                 href="<c:url value='/products'>
                          <c:param name='q'         value='${param.q}'/>
                          <c:param name='catId'     value='${param.catId}'/>
                          <c:param name='minPrice'  value='${param.minPrice}'/>
                          <c:param name='maxPrice'  value='${param.maxPrice}'/>
                          <c:param name='minRating' value='${param.minRating}'/>
                          <c:param name='sort'      value='${param.sort}'/>
                          <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                          <c:param name='page'      value='${i}'/>
                      </c:url>">${i}</a>
            </li>
          </c:forEach>

          <li class="page-item ${page.hasNext ? '' : 'disabled'}">
            <a class="page-link"
               href="<c:url value='/products'>
                        <c:param name='q'         value='${param.q}'/>
                        <c:param name='catId'     value='${param.catId}'/>
                        <c:param name='minPrice'  value='${param.minPrice}'/>
                        <c:param name='maxPrice'  value='${param.maxPrice}'/>
                        <c:param name='minRating' value='${param.minRating}'/>
                        <c:param name='sort'      value='${param.sort}'/>
                        <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                        <c:param name='page'      value='${page.number+1}'/>
                    </c:url>">»</a>
          </li>
        </ul>
      </nav>
    </c:if>
  </c:when>

  <c:otherwise>
    <div class="text-center text-muted py-5">Chưa có sản phẩm để hiển thị.</div>
  </c:otherwise>
</c:choose>
