<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<fmt:setLocale value="vi_VN" scope="page"/>

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

  /* Card hover nhẹ cho related & viewed */
  .card:hover{
    transform: translateY(-2px);
    transition: transform .15s ease;
  }

  /* FAVORITE button tweak */
  .fav-wrap { display:flex; align-items:center; gap:.5rem; margin-top:.5rem; }
  .fav-wrap .btn { line-height: 1.1; }
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
            <!-- ✅ đổi /assets/products/ -> /assets/img/products/ -->
            <c:set var="resolvedMain" value="${ctx.concat('/assets/img/products/').concat(mainFixed)}"/>
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
                  <!-- ✅ đổi /assets/products/ -> /assets/img/products/ -->
                  <c:set var="resolvedThumb" value="${ctx.concat('/assets/img/products/').concat(tFixed)}"/>
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
              <img src="${ctx}${product.shop.logoUrl}"
                   alt="<c:out value='${product.shop.shopName}'/>"
                   class="rounded border"
                   style="width:172px;height:172px;object-fit:cover"
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

        <%-- ======= GIÁ CHÍNH: format VNĐ + rút gọn k/triệu ======= --%>
        <c:set var="priceMain" value="${not empty product.discountPrice ? product.discountPrice : product.price}"/>
        <div class="fs-4 fw-bold">
          <fmt:formatNumber value="${priceMain}" type="number" maxFractionDigits="0"/> ₫
          <span class="text-muted small">
            (
            <c:choose>
              <c:when test="${priceMain >= 1000000}">
                <fmt:formatNumber value="${priceMain / 1000000.0}" maxFractionDigits="1"/> triệu
              </c:when>
              <c:otherwise>
                <fmt:formatNumber value="${priceMain / 1000.0}" maxFractionDigits="0"/>k
              </c:otherwise>
            </c:choose>
            )
          </span>
        </div>

        <!-- ✅ FAVORITE: nút ❤️ + count -->
        <c:set var="isFavSafe" value="${isFav == true}"/>
        <c:set var="favCountSafe" value="${empty favoriteCount ? 0 : favoriteCount}"/>
        <div class="fav-wrap">
          <button id="btn-fav"
                  type="button"
                  class="btn btn-outline-danger btn-sm"
                  data-product="${product.productId}"
                  aria-pressed="${isFavSafe}">
            <span id="fav-icon">${isFavSafe ? '❤️' : '🤍'}</span>
            <span id="fav-text">${isFavSafe ? 'Đã thích' : 'Thêm Yêu thích'}</span>
          </button>
          <small class="text-muted">(<span id="fav-count">${favCountSafe}</span>)</small>
        </div>
        <!-- ✅ END FAVORITE -->

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

        <%-- (ĐÃ GỠ) DEBUG Viewed --%>
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
              <!-- ✅ đổi /assets/products/ -> /assets/img/products/ -->
              <c:set var="rpCover" value="${ctx.concat('/assets/img/products/').concat(rpFixed)}"/>
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

                <%-- Giá liên quan: chỉ hiển thị VNĐ gọn --%>
                <c:set var="rpMain" value="${not empty rp.discountPrice ? rp.discountPrice : rp.price}"/>
                <div class="fw-bold">
                  <fmt:formatNumber value="${rpMain}" type="number" maxFractionDigits="0"/> ₫
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:if>

    <!-- ✅ RECENTLY VIEWED -->
    <div class="mt-4">
      <div class="d-flex align-items-center justify-content-between mb-2">
        <!-- (TO HƠN) -->
        <h2 class="h4 m-0 fw-semibold">Bạn đã xem gần đây</h2>
        <a class="btn btn-sm btn-outline-secondary" href="${ctx}/recent">Xem tất cả</a>
      </div>

      <c:choose>
        <c:when test="${not empty recentViewed}">
          <div class="row row-cols-2 row-cols-md-6 g-3">
            <c:forEach var="rv" items="${recentViewed}">
              <%-- Resolve cover --%>
              <c:set var="rvRaw"   value="${empty rv.coverUrl ? '' : rv.coverUrl}"/>
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
                  <!-- ✅ đổi /assets/products/ -> /assets/img/products/ -->
                  <c:set var="rvCover" value="${ctx.concat('/assets/img/products/').concat(rvFixed)}"/>
                </c:otherwise>
              </c:choose>

              <div class="col">
                <div class="card h-100">
                  <a href="${ctx}/product/${rv.productId}">
                    <img class="card-img-top"
                         style="aspect-ratio:1/1;object-fit:cover"
                         src="${empty rvCover ? (ctx.concat('/assets/img/placeholder.png')) : rvCover}"
                         alt="<c:out value='${rv.productName}'/>"
                         onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
                  </a>
                  <div class="card-body p-2">
                    <div class="fw-semibold text-truncate" title="${rv.productName}">
                      <c:out value="${rv.productName}"/>
                    </div>

                    <%-- Giá viewed: hiển thị VNĐ gọn --%>
                    <c:set var="rvMain" value="${not empty rv.discountPrice ? rv.discountPrice : rv.price}"/>
                    <div class="fw-bold small">
                      <fmt:formatNumber value="${rvMain}" type="number" maxFractionDigits="0"/> ₫
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>

        <c:otherwise>
          <!-- Empty state đẹp hơn -->
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

<!-- ✅ FAVORITE toggle AJAX (robust) -->
<script>
  (function () {
    var btn = document.getElementById('btn-fav');
    if (!btn) return;

    btn.addEventListener('click', function () {
      var pid = btn.getAttribute('data-product');
      fetch('${ctx}/favorite/toggle', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
        body: 'productId=' + encodeURIComponent(pid),
        credentials: 'same-origin'
      })
      .then(async function (res) {
        if (res.status === 401) {
          window.location.href = '${ctx}/login';
          return null;
        }
        var text = await res.text();
        if (!res.ok) {
          // nếu server trả HTML (VD: redirect), show ngắn gọn
          var hint = text ? (': ' + text.slice(0, 120)) : '';
          throw new Error('HTTP ' + res.status + hint);
        }
        var json;
        try { json = text ? JSON.parse(text) : null; } catch(e) { json = null; }
        if (!json || json.ok !== true) {
          if (text && /<\s*html[^>]*>/i.test(text)) {
            window.location.href = '${ctx}/login';
            return null;
          }
          throw new Error('Phản hồi không phải JSON hợp lệ.');
        }
        return json;
      })
      .then(function (json) {
        if (!json) return;
        var nowFav = !!json.fav;
        var iconEl = document.getElementById('fav-icon');
        var textEl = document.getElementById('fav-text');
        var cntEl  = document.getElementById('fav-count');

        btn.setAttribute('aria-pressed', nowFav ? 'true' : 'false');
        if (iconEl) iconEl.textContent = nowFav ? '❤️' : '🤍';
        if (textEl) textEl.textContent = nowFav ? 'Đã thích' : 'Thêm Yêu thích';
        if (cntEl)  cntEl.textContent  = (json.count != null ? json.count : 0);
      })
      .catch(function (err) {
        alert('Không thể cập nhật yêu thích: ' + err.message);
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
          alert(toastBody ? toastBody.textContent : "Lỗi kết nối.";
        }
      });
    });
  })();
</script>
