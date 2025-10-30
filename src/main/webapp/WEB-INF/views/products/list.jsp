<%-- filepath: src/main/webapp/WEB-INF/views/products/list.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="brand" value="${param.brand}"/>
<c:set var="gender" value="${param.gender}"/>
<c:set var="style" value="${param.style}"/>

<h1 class="h5 mb-3">${empty pageTitle ? 'Sản phẩm' : pageTitle}</h1>

<form class="row g-2 mb-3" method="get" action="" id="filterForm">
  <div class="col-12 col-md-4">
    <input class="form-control" name="q" value="${param.q}" placeholder="Tìm kiếm...">
  </div>

  <div class="col-6 col-md-3">
    <input class="form-control" name="shopQ" list="shopList" value="${shopQ}" placeholder="Shop...">
    <datalist id="shopList">
      <c:forEach var="s" items="${shops}">
        <option value="${s.name}" data-id="${s.id}"></option>
      </c:forEach>
    </datalist>
    <input type="hidden" name="shopId" id="shopIdInput" value="${param.shopId}">
  </div>

  <div class="col-6 col-md-3">
    <select class="form-select" name="catId">
      <option value="">Danh mục</option>
      <c:forEach var="c" items="${categories}">
        <option value="${c.categoryId}" ${c.categoryId==param.catId?'selected':''}>${c.categoryName}</option>
      </c:forEach>
    </select>
  </div>

  <%-- Gộp Giá từ + Giá đến thành một nhóm nằm cùng hàng --%>
  <div class="col-12 col-md-4">
    <div class="input-group">
      <span class="input-group-text">Giá</span>
      <input class="form-control" type="number" min="0" name="minPrice"
             value="${param.minPrice}" placeholder="Từ">
      <span class="input-group-text">→</span>
      <input class="form-control" type="number" min="0" name="maxPrice"
             value="${param.maxPrice}" placeholder="Đến">
    </div>
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

  <div class="col-6 col-md-2">
    <select class="form-select" name="size">
      <c:set var="currSize" value="${empty param.size ? (empty page.size ? 12 : page.size) : param.size}"/>
      <option value="12" ${currSize==12?'selected':''}>12 / trang</option>
      <option value="24" ${currSize==24?'selected':''}>24 / trang</option>
      <option value="36" ${currSize==36?'selected':''}>36 / trang</option>
    </select>
  </div>

  <input type="hidden" name="brand"  value="${brand}">
  <input type="hidden" name="gender" value="${gender}">
  <input type="hidden" name="style"  value="${style}">

  <div class="col-12 col-md-auto d-flex gap-2">
    <button class="btn btn-primary">Lọc</button>
    <a class="btn btn-outline-secondary" href="<c:url value='/products'/>">Xóa lọc</a>
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
              <%-- Resolve cover image robustly --%>
              <c:set var="coverRaw" value="${empty p.coverUrl ? '' : p.coverUrl}"/>
              <%-- Sửa nhầm thư mục /assset -> /assets --%>
              <c:set var="coverFixed" value="${fn:replace(coverRaw, '/assset/', '/assets/')}"/>

              <c:choose>
                <%-- URL tuyệt đối http/https: giữ nguyên --%>
                <c:when test="${fn:startsWith(coverFixed,'http://') or fn:startsWith(coverFixed,'https://')}">
                  <c:set var="resolvedCover" value="${coverFixed}"/>
                </c:when>

                <%-- Đường dẫn bắt đầu bằng /assets/... : tự ghép ctx --%>
                <c:when test="${fn:startsWith(coverFixed,'/assets/')}">
                  <c:set var="resolvedCover" value="${ctx.concat(coverFixed)}"/>
                </c:when>

                <%-- Đường dẫn bắt đầu bằng / (nhưng không phải /assets): dùng nguyên như đã lưu --%>
                <c:when test="${fn:startsWith(coverFixed,'/')}">
                  <c:set var="resolvedCover" value="${coverFixed}"/>
                </c:when>

                <%-- Chỉ là tên file: trỏ về /assets/products/ --%>
                <c:otherwise>
                  <c:set var="resolvedCover" value="${ctx.concat('/assets/products/').concat(coverFixed)}"/>
                </c:otherwise>
              </c:choose>

              <img class="card-img-top" style="aspect-ratio:1/1;object-fit:cover"
                   src="${empty resolvedCover ? (ctx.concat('/assets/img/placeholder.png')) : resolvedCover}"
                   alt="${p.name}"
                   onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
            </a>

            <div class="card-body p-2 d-flex flex-column">
              <div class="small text-muted text-truncate" title="${p.categoryName}">${p.categoryName}</div>
              <div class="fw-semibold text-truncate mb-1" title="${p.name}">${p.name}</div>

              <div class="d-flex flex-wrap gap-1 small mb-1">
                <c:if test="${not empty p.brand}">
                  <span class="badge bg-light border text-secondary">Brand: ${p.brand}</span>
                </c:if>
                <c:if test="${not empty p.gender}">
                  <span class="badge bg-light border text-secondary">Gender: ${p.gender}</span>
                </c:if>
                <c:if test="${not empty p.style}">
                  <span class="badge bg-light border text-secondary">Style: ${p.style}</span>
                </c:if>
              </div>

              <div class="small text-muted mb-1">
                Tồn: <span class="fw-semibold">${empty p.stockTotal ? 0 : p.stockTotal}</span>
              </div>

              <c:if test="${not empty p.shopName}">
                <div class="d-flex align-items-center gap-2 small text-truncate mb-1" title="${p.shopName}">
                  <c:if test="${not empty p.shopLogoUrl}">
                    <img src="${ctx}${p.shopLogoUrl}" alt="${p.shopName}"
                         width="18" height="18" class="rounded"
                         onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
                  </c:if>
                  <a class="badge bg-secondary-subtle border text-secondary text-decoration-none"
                     href="<c:url value='/products'>
                              <c:param name='q'         value='${param.q}'/>
                              <c:param name='shopQ'     value='${p.shopName}'/>
                              <c:param name='catId'     value='${param.catId}'/>
                              <c:param name='minPrice'  value='${param.minPrice}'/>
                              <c:param name='maxPrice'  value='${param.maxPrice}'/>
                              <c:param name='minRating' value='${param.minRating}'/>
                              <c:param name='sort'      value='${param.sort}'/>
                              <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                              <c:param name='page'      value='1'/>
                              <c:param name='shopId'    value='${p.shopId}'/>
                              <c:param name="brand"     value="${brand}"/>
                              <c:param name="gender"    value="${gender}"/>
                              <c:param name="style"     value="${style}"/>
                           </c:url>">
                    ${p.shopName}
                  </a>
                </div>
              </c:if>

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
                        <c:param name='shopQ'     value='${shopQ}'/>
                        <c:param name='catId'     value='${param.catId}'/>
                        <c:param name='minPrice'  value='${param.minPrice}'/>
                        <c:param name='maxPrice'  value='${param.maxPrice}'/>
                        <c:param name='minRating' value='${param.minRating}'/>
                        <c:param name='sort'      value='${param.sort}'/>
                        <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                        <c:param name='page'      value='${page.number-1}'/>
                        <c:param name='shopId'    value='${param.shopId}'/>
                        <c:param name="brand"     value="${brand}"/>
                        <c:param name="gender"    value="${gender}"/>
                        <c:param name="style"     value="${style}"/>
                    </c:url>">«</a>
          </li>

          <c:forEach var="i" begin="1" end="${page.totalPages}">
            <li class="page-item ${i==page.number?'active':''}">
              <a class="page-link"
                 href="<c:url value='/products'>
                          <c:param name='q'         value='${param.q}'/>
                          <c:param name='shopQ'     value='${shopQ}'/>
                          <c:param name='catId'     value='${param.catId}'/>
                          <c:param name='minPrice'  value='${param.minPrice}'/>
                          <c:param name='maxPrice'  value='${param.maxPrice}'/>
                          <c:param name='minRating' value='${param.minRating}'/>
                          <c:param name='sort'      value='${param.sort}'/>
                          <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                          <c:param name='page'      value='${i}'/>
                          <c:param name='shopId'    value='${param.shopId}'/>
                          <c:param name="brand"     value="${brand}"/>
                          <c:param name="gender"    value="${gender}"/>
                          <c:param name="style"     value="${style}"/>
                      </c:url>">${i}</a>
            </li>
          </c:forEach>

          <li class="page-item ${page.hasNext ? '' : 'disabled'}">
            <a class="page-link"
               href="<c:url value='/products'>
                        <c:param name='q'         value='${param.q}'/>
                        <c:param name='shopQ'     value='${shopQ}'/>
                        <c:param name='catId'     value='${param.catId}'/>
                        <c:param name='minPrice'  value='${param.minPrice}'/>
                        <c:param name='maxPrice'  value='${param.maxPrice}'/>
                        <c:param name='minRating' value='${param.minRating}'/>
                        <c:param name='sort'      value='${param.sort}'/>
                        <c:param name='size'      value='${empty param.size ? (empty page.size ? 12 : page.size) : param.size}'/>
                        <c:param name='page'      value='${page.number+1}'/>
                        <c:param name='shopId'    value='${param.shopId}'/>
                        <c:param name="brand"     value="${brand}"/>
                        <c:param name="gender"    value="${gender}"/>
                        <c:param name="style"     value="${style}"/>
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

<script>
  (function () {
    var form   = document.getElementById('filterForm');
    var input  = document.querySelector('input[name="shopQ"]');
    var hidden = document.getElementById('shopIdInput');
    var list   = document.getElementById('shopList');
    if (!form || !input || !hidden || !list) return;

    function stripVN(s) {
      return (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    function norm(s) {
      return stripVN(s).trim().toLowerCase().replace(/\s+/g, ' ');
    }

    function sync() {
      var nv = norm(input.value);
      var id = '';
      var opts = list.querySelectorAll('option');

      if (nv) {
        for (var i = 0; i < opts.length; i++) {
          if (norm(opts[i].value) === nv) { id = opts[i].dataset.id || ''; break; }
        }
        if (!id) {
          var candidates = [];
          for (var j = 0; j < opts.length; j++) {
            if (norm(opts[j].value).indexOf(nv) === 0) candidates.push(opts[j]);
          }
          if (candidates.length === 1) id = candidates[0].dataset.id || '';
        }
      }
      hidden.value = id;
    }

    input.addEventListener('input', function(){
      if (!input.value) hidden.value = '';
      else sync();
    });
    input.addEventListener('change', sync);
    input.addEventListener('blur', sync);
    input.addEventListener('keydown', function(e){ if (e.key === 'Enter') sync(); });
    form.addEventListener('submit', function(){ sync(); }, true);
    sync();
  })();
</script>