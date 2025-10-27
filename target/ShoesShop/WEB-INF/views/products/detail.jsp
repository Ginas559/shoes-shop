<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!-- Styles: chuẩn hoá kích thước ảnh trang chi tiết -->
<style>
  .product-detail .main-img{
    width: 100%;
    max-width: 640px;      /* desktop cap */
    aspect-ratio: 1 / 1;   /* luôn vuông */
    object-fit: cover;     /* cắt gọn, không méo */
  }
  .product-detail .thumb{
    width: 96px;
    height: 96px;
    object-fit: cover;
    cursor: pointer;
  }
  @media (max-width: 576px){
    .product-detail .main-img{ max-width: 100%; }
    .product-detail .thumb{ width: 72px; height: 72px; }
  }
</style>

<c:choose>
  <c:when test="${not empty product}">
    <div class="row g-3 product-detail">
      <!-- GALLERY -->
      <div class="col-12 col-md-6">
        <%-- === Resolve main image from images[0] === --%>
        <c:set var="mainRaw"   value="${empty images ? '' : images[0]}"/>
        <c:set var="mainFixed" value="${fn:replace(mainRaw, '/assset/', '/assets/')}"/>
        <c:choose>
          <c:when test="${fn:startsWith(mainFixed,'http://') or fn:startsWith(mainFixed,'https://')}">
            <c:set var="resolvedMain" value="${mainFixed}"/>
          </c:when>
          <c:when test="${fn:startsWith(mainFixed,'/assets/')}">
            <c:set var="resolvedMain" value="${ctx.concat(mainFixed)}"/>
          </c:when>
          <c:when test="${fn:startsWith(mainFixed,'/')}">
            <c:set var="resolvedMain" value="${mainFixed}"/>
          </c:when>
          <c:otherwise>
            <c:set var="resolvedMain" value="${ctx.concat('/assets/products/').concat(mainFixed)}"/>
          </c:otherwise>
        </c:choose>

        <img id="mainImage" class="img-fluid rounded border d-block mx-auto main-img"
             src="${empty resolvedMain ? (ctx.concat('/assets/img/placeholder.png')) : resolvedMain}"
             alt="<c:out value='${product.productName}'/>"
             onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">

        <c:if test="${not empty images}">
          <div class="d-flex gap-2 mt-2 flex-wrap">
            <c:forEach var="img" items="${images}" varStatus="st">
              <%-- Resolve each thumb --%>
              <c:set var="tRaw"   value="${empty img ? '' : img}"/>
              <c:set var="tFixed" value="${fn:replace(tRaw, '/assset/', '/assets/')}"/>
              <c:choose>
                <c:when test="${fn:startsWith(tFixed,'http://') or fn:startsWith(tFixed,'https://')}">
                  <c:set var="resolvedThumb" value="${tFixed}"/>
                </c:when>
                <c:when test="${fn:startsWith(tFixed,'/assets/')}">
                  <c:set var="resolvedThumb" value="${ctx.concat(tFixed)}"/>
                </c:when>
                <c:when test="${fn:startsWith(tFixed,'/')}">
                  <c:set var="resolvedThumb" value="${tFixed}"/>
                </c:when>
                <c:otherwise>
                  <c:set var="resolvedThumb" value="${ctx.concat('/assets/products/').concat(tFixed)}"/>
                </c:otherwise>
              </c:choose>

              <img src="${empty resolvedThumb ? (ctx.concat('/assets/img/placeholder.png')) : resolvedThumb}"
                   data-src="${empty resolvedThumb ? (ctx.concat('/assets/img/placeholder.png')) : resolvedThumb}"
                   class="rounded ${st.first ? 'border border-primary' : 'border'} thumb"
                   onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
            </c:forEach>
          </div>
        </c:if>
      </div>

      <!-- INFO -->
      <div class="col-12 col-md-6">
        <h1 class="h5"><c:out value="${product.productName}"/></h1>

        <!-- ⭐ Shop: logo + tên + link lọc theo shop -->
        <c:if test="${not empty product.shop}">
          <div class="d-flex align-items-center gap-2 mb-2">
            <c:if test="${not empty product.shop.logoUrl}">
			  <img src="${product.shop.logoUrl}"
			       alt="<c:out value='${product.shop.shopName}'/>"
			       class="rounded-circle border shadow-sm"
			       style="width:172px;height:172px;object-fit:cover;"
			       onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
			</c:if>


            <div>
              <div class="small text-muted">Của shop</div>
              <a class="badge bg-secondary-subtle border text-secondary text-decoration-none"
                 href="<c:url value='/products'>
                          <c:param name='shopId' value='${product.shop.shopId}'/>
                       </c:url>">
                <c:out value="${product.shop.shopName}"/>
              </a>
            </div>
          </div>
        </c:if>

        <div class="text-muted mb-2">
          <c:out value="${product.category != null ? product.category.categoryName : ''}"/>
        </div>

        <div class="fs-4 fw-bold">
          <c:choose>
            <c:when test="${not empty product.discountPrice}">${product.discountPrice}</c:when>
            <c:otherwise>${product.price}</c:otherwise>
          </c:choose>
        </div>

        <p class="mt-3"><c:out value="${product.description}"/></p>

        <!-- ✅ FORM: Thêm vào giỏ (AJAX, không rời trang) -->
        <div class="mt-3">
          <form id="addToCartForm" method="post" action="${ctx}/cart/add" class="d-flex align-items-center gap-2">
            <input type="hidden" name="productId" value="${product.productId}"/>
            <div class="input-group" style="width: 220px;">
              <input type="number" name="quantity" value="1" min="1" class="form-control" />
              <button type="submit" class="btn btn-primary">Thêm vào giỏ</button>
            </div>
          </form>

          <small class="text-muted d-block mt-2">
            Xem giỏ tại <a class="text-decoration-none" href="${ctx}/cart">${ctx}/cart</a>.
          </small>
        </div>

        <div class="mt-3 d-flex gap-2">
          <a class="btn btn-outline-secondary" href="${ctx}/products">← Quay lại danh sách</a>
          <a class="btn btn-primary" href="${ctx}/product/${product.productId}">Tải lại</a>
        </div>
      </div>
    </div>

    <!-- RELATED PRODUCTS (tùy chọn, chỉ hiển thị khi có dữ liệu) -->
    <c:if test="${not empty relatedProducts}">
      <h2 class="h6 mt-4 mb-2">Sản phẩm liên quan</h2>
      <div class="row row-cols-2 row-cols-md-4 g-3">
        <c:forEach var="rp" items="${relatedProducts}">
          <%-- Resolve related cover --%>
          <c:set var="rpRaw"   value="${empty rp.coverUrl ? '' : rp.coverUrl}"/>
          <c:set var="rpFixed" value="${fn:replace(rpRaw, '/assset/', '/assets/')}"/>
          <c:choose>
            <c:when test="${fn:startsWith(rpFixed,'http://') or fn:startsWith(rpFixed,'https://')}">
              <c:set var="rpCover" value="${rpFixed}"/>
            </c:when>
            <c:when test="${fn:startsWith(rpFixed,'/assets/')}">
              <c:set var="rpCover" value="${ctx.concat(rpFixed)}"/>
            </c:when>
            <c:when test="${fn:startsWith(rpFixed,'/')}">
              <c:set var="rpCover" value="${rpFixed}"/>
            </c:when>
            <c:otherwise>
              <c:set var="rpCover" value="${ctx.concat('/assets/products/').concat(rpFixed)}"/>
            </c:otherwise>
          </c:choose>

          <div class="col">
            <div class="card h-100">
              <a href="${ctx}/product/${rp.id}">
                <img class="card-img-top"
                     style="aspect-ratio:1/1;object-fit:cover"
                     src="${empty rpCover ? (ctx.concat('/assets/img/placeholder.png')) : rpCover}"
                     alt="<c:out value='${rp.productName}'/>"
                     onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
              </a>
              <div class="card-body p-2">
                <div class="small text-muted text-truncate">
                  <c:out value="${rp.category != null ? rp.category.categoryName : ''}"/>
                </div>
                <div class="fw-semibold text-truncate" title="${rp.productName}">
                  <c:out value="${rp.productName}"/>
                </div>
                <div class="fw-bold">
                  <c:choose>
                    <c:when test="${not empty rp.discountPrice}">${rp.discountPrice}</c:when>
                    <c:otherwise>${rp.price}</c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:if>

  </c:when>
  <c:otherwise>
    <div class="text-center text-muted py-5">Không tìm thấy sản phẩm.</div>
  </c:otherwise>
</c:choose>

<!-- Toast container (góc phải dưới) -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1080">
  <div id="cartToast" class="toast align-items-center text-bg-success border-0" role="status"
       aria-live="polite" aria-atomic="true" data-bs-autohide="true" data-bs-delay="2500">
    <div class="d-flex">
      <div class="toast-body">
        Đã thêm sản phẩm vào giỏ hàng!
      </div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"
              aria-label="Close"></button>
    </div>
  </div>
</div>

<!-- Tiny gallery script -->
<script>
  (function () {
    var main = document.getElementById('mainImage');
    if (!main) return;
    var thumbs = document.querySelectorAll('.thumb');
    thumbs.forEach(function (img) {
      img.addEventListener('click', function () {
        var src = img.getAttribute('data-src') || img.getAttribute('src');
        if (src) {
          main.setAttribute('src', src);
          thumbs.forEach(function (im) { im.classList.remove('border-primary'); });
          img.classList.add('border-primary');
        }
      });
    });
  })();
</script>

<!-- ✅ AJAX + Toast -->
<script>
  (function () {
    var form  = document.getElementById('addToCartForm');
    if (!form) return;

    var toastEl   = document.getElementById('cartToast');
    var toastBody = toastEl ? toastEl.querySelector('.toast-body') : null;

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var data = new URLSearchParams(new FormData(form));

      fetch(form.action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: data
      })
      .then(function (res) {
        if (!toastEl) return;
        var cls = toastEl.classList;

        if (res.ok) {
          cls.remove('text-bg-danger');
          cls.add('text-bg-success');
          if (toastBody) {
            toastBody.textContent = "Đã thêm \"" + "${product.productName}".replace(/\"/g,'\\"') + "\" vào giỏ hàng.";
          }
        } else {
          cls.remove('text-bg-success');
          cls.add('text-bg-danger');
          if (toastBody) toastBody.textContent = "Lỗi khi thêm vào giỏ (HTTP " + res.status + ").";
        }

        if (typeof bootstrap !== "undefined") {
          var t = bootstrap.Toast.getOrCreateInstance(toastEl);
          t.show();
        } else {
          alert(toastBody ? toastBody.textContent : "Hoàn tất thao tác.");
        }
      })
      .catch(function (err) {
        if (!toastEl) return;
        var cls = toastEl.classList;
        cls.remove('text-bg-success');
        cls.add('text-bg-danger');
        if (toastBody) toastBody.textContent = "Lỗi kết nối: " + err.message;

        if (typeof bootstrap !== "undefined") {
          var t = bootstrap.Toast.getOrCreateInstance(toastEl);
          t.show();
        } else {
          alert(toastBody ? toastBody.textContent : "Lỗi kết nối.");
        }
      });
    });
  })();
</script>
