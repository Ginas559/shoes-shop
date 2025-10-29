<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:set var="items"      value="${empty page ? null : page.items}"/>
<c:set var="currPage"   value="${empty page ? 1 : page.page}"/>
<c:set var="currSize"   value="${empty page ? 12 : page.size}"/>
<c:set var="totalPages" value="${empty page ? 1 : page.totalPages}"/>

<style>
  .hero { position: relative; border-radius: .5rem; overflow: hidden; background: #f8f9fa; }
  .hero .cover { width: 100%; aspect-ratio: 16/5; object-fit: cover; opacity: .9; }
  .hero .mask  { position:absolute; inset:0; background:linear-gradient(to bottom, rgba(0,0,0,.2), rgba(0,0,0,.45)); }
  .hero .body  { position:absolute; left:0; right:0; bottom:0; padding:1rem 1.25rem; color:#fff; }
  .hero .logo  { width:92px; height:92px; border-radius:50%; object-fit:cover; border:3px solid #fff; background:#fff; }
  .line-clamp-2 { display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
</style>

<c:set var="coverRaw" value="${empty shop.coverUrl ? '' : shop.coverUrl}"/>
<c:set var="logoRaw"  value="${empty shop.logoUrl  ? '' : shop.logoUrl }"/>

<c:set var="cover"
       value="${fn:startsWith(coverRaw,'http') ? coverRaw : (fn:startsWith(coverRaw,'/') ? coverRaw : (ctx.concat('/assets/img/').concat(coverRaw)))}"/>
<c:set var="logo"
       value="${fn:startsWith(logoRaw,'http') ? logoRaw : (fn:startsWith(logoRaw,'/') ? (ctx.concat(logoRaw)) : (ctx.concat('/assets/img/').concat(logoRaw)))}"/>

<!-- HERO SHOP -->
<div class="hero mb-3">
  <img class="cover" src="${empty cover ? (ctx.concat('/assets/img/placeholder.png')) : cover}"
       alt="<c:out value='${shop.shopName}'/>"
       onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
  <div class="mask"></div>
  <div class="body">
    <div class="d-flex align-items-end gap-3">
      <img class="logo"
           src="${empty logo ? (ctx.concat('/assets/img/placeholder.png')) : logo}"
           alt="<c:out value='${shop.shopName}'/>"
           onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
      <div class="pb-2">
        <h1 class="h5 m-0"><c:out value="${shop.shopName}"/></h1>
        <div class="small line-clamp-2">
          <c:out value="${empty shop.description ? 'Chưa có mô tả.' : shop.description}"/>
        </div>
      </div>
    </div>
  </div>
</div>
	
<!-- FORM LỌC (giữ như /products, nhưng cố định shop) -->
<form class="row g-2 mb-3" method="get" action="<c:url value='/products'/>"	 id="filterForm">
  <input type="hidden" name="shopId" value="${shop.shopId}"/>

  <div class="col-12 col-md-4">
    <input class="form-control" name="q" value="${param.q}" placeholder="Tìm kiếm trong shop...">
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
    <select class="form-select" name="sort">
      <option value="">Sắp xếp</option>
      <option value="new_desc"    ${param.sort=='new_desc'?'selected':''}>Mới nhất</option>
      <option value="price_asc"   ${param.sort=='price_asc'?'selected':''}>Giá ↑</option>
      <option value="price_desc"  ${param.sort=='price_desc'?'selected':''}>Giá ↓</option>
    </select>
  </div>

  <div class="col-6 col-md-2">
    <select class="form-select" name="size">
      <option value="12" ${currSize==12?'selected':''}>12 / trang</option>
      <option value="24" ${currSize==24?'selected':''}>24 / trang</option>
      <option value="36" ${currSize==36?'selected':''}>36 / trang</option>
    </select>
  </div>

  <div class="col-12 col-md-auto d-flex gap-2">
    <button class="btn btn-primary">Lọc</button>
    <a class="btn btn-outline-secondary"
       href="<c:url value='/products'><c:param name='shopId' value='${shop.shopId}'/></c:url>">
      Xóa lọc
    </a>
  </div>
</form>

<!-- GRID SẢN PHẨM -->
<c:choose>
  <c:when test="${not empty items}">
    <div class="row row-cols-2 row-cols-md-4 g-3">
      <c:forEach var="p" items="${items}">
        <c:set var="coverRaw" value="${empty p.coverUrl ? '' : p.coverUrl}"/>
        <c:set var="resolvedCover"
               value="${fn:startsWith(coverRaw,'http') ? coverRaw : (fn:startsWith(coverRaw,'/') ? (ctx.concat(coverRaw)) : (ctx.concat('/assets/img/products/').concat(coverRaw)))}"/>

        <div class="col">
          <div class="card h-100">
            <a href="${ctx}/product/${p.productId}">
              <img class="card-img-top" style="aspect-ratio:1/1;object-fit:cover"
                   src="${empty resolvedCover ? (ctx.concat('/assets/img/placeholder.png')) : resolvedCover}"
                   alt="<c:out value='${p.productName}'/>"
                   onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
            </a>

            <div class="card-body p-2 d-flex flex-column">
              <div class="small text-muted text-truncate" title="${empty p.category ? '' : p.category.categoryName}">
                <c:out value="${empty p.category ? '' : p.category.categoryName}"/>
              </div>
              <div class="fw-semibold text-truncate mb-1" title="${p.productName}">
                <c:out value="${p.productName}"/>
              </div>

              <div class="d-flex justify-content-between align-items-center mb-1">
                <div class="fw-bold">
                  <c:choose>
                    <c:when test="${not empty p.discountPrice}">
                      <span class="text-danger"><fmt:formatNumber value="${p.discountPrice}" type="number" groupingUsed="true"/> ₫</span>
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
              </div>

              <a href="${ctx}/product/${p.productId}" class="btn btn-outline-primary btn-sm mt-auto">Xem chi tiết</a>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>

    <c:if test="${totalPages > 1}">
      <nav class="mt-3">
        <ul class="pagination justify-content-center">
          <li class="page-item ${currPage>1 ? '' : 'disabled'}">
            <a class="page-link"
               href="<c:url value='/vendor'>
                        <c:param name='shopId' value='${shop.shopId}'/>
                        <c:param name='q' value='${param.q}'/>
                        <c:param name='catId' value='${param.catId}'/>
                        <c:param name='sort' value='${param.sort}'/>
                        <c:param name='size' value='${currSize}'/>
                        <c:param name='page' value='${currPage-1}'/>
                    </c:url>">«</a>
          </li>

          <c:forEach var="i" begin="1" end="${totalPages}">
            <li class="page-item ${i==currPage?'active':''}">
              <a class="page-link"
                 href="<c:url value='/vendor'>
                          <c:param name='shopId' value='${shop.shopId}'/>
                          <c:param name='q' value='${param.q}'/>
                          <c:param name='catId' value='${param.catId}'/>
                          <c:param name='sort' value='${param.sort}'/>
                          <c:param name='size' value='${currSize}'/>
                          <c:param name='page' value='${i}'/>
                      </c:url>">${i}</a>
            </li>
          </c:forEach>

          <li class="page-item ${currPage<totalPages ? '' : 'disabled'}">
            <a class="page-link"
               href="<c:url value='/vendor'>
                        <c:param name='shopId' value='${shop.shopId}'/>
                        <c:param name='q' value='${param.q}'/>
                        <c:param name='catId' value='${param.catId}'/>
                        <c:param name='sort' value='${param.sort}'/>
                        <c:param name='size' value='${currSize}'/>
                        <c:param name='page' value='${currPage+1}'/>
                    </c:url>">»</a>
          </li>
        </ul>
      </nav>
    </c:if>
  </c:when>

  <c:otherwise>
    <div class="border rounded p-4 bg-light-subtle text-center">
      <div class="fw-semibold mb-1">Shop chưa có sản phẩm hiển thị</div>
      <div class="text-muted small">Hãy quay lại sau nhé.</div>
    </div>
  </c:otherwise>
</c:choose>

<!-- Lối thoát nhanh -->
<div class="mt-3 d-flex gap-2">
  <a class="btn btn-outline-secondary" href="${ctx}/vendors">← Danh bạ vendor</a>
  <a class="btn btn-outline-secondary"
     href="<c:url value='/vendor'><c:param name='shopId' value='${shop.shopId}'/></c:url>">
    Về trang shop
  </a>
</div>
