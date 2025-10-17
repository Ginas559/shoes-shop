<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:choose>
  <c:when test="${not empty product}">
    <div class="row g-3">
      <!-- GALLERY -->
      <div class="col-12 col-md-6">
        <img id="mainImage" class="img-fluid rounded border"
             src="${empty images ? (ctx.concat('/assets/img/placeholder.png')) : images[0]}"
             alt="<c:out value='${product.productName}'/>"
             style="aspect-ratio:1/1;object-fit:cover">

        <c:if test="${not empty images}">
          <div class="d-flex gap-2 mt-2 flex-wrap">
            <c:forEach var="img" items="${images}" varStatus="st">
              <img src="${empty img ? (ctx.concat('/assets/img/placeholder.png')) : img}"
                   data-src="${empty img ? (ctx.concat('/assets/img/placeholder.png')) : img}"
                   style="width:80px;height:80px;object-fit:cover;cursor:pointer"
                   class="rounded ${st.first ? 'border border-primary' : 'border'} thumb">
            </c:forEach>
          </div>
        </c:if>
      </div>

      <!-- INFO -->
      <div class="col-12 col-md-6">
        <h1 class="h5"><c:out value="${product.productName}"/></h1>

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
          <div class="col">
            <div class="card h-100">
              <a href="${ctx}/product/${rp.id}">
                <img class="card-img-top"
                     style="aspect-ratio:1/1;object-fit:cover"
                     src="${empty rp.coverUrl ? (ctx.concat('/assets/img/placeholder.png')) : rp.coverUrl}"
                     alt="<c:out value='${rp.productName}'/>">
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

<!-- Tiny gallery script (giữ nguyên) -->
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

<!-- ✅ AJAX + Toast (không ảnh hưởng script trên) -->
<script>
  (function () {
    var form  = document.getElementById('addToCartForm');
    if (!form) return;

    var toastEl   = document.getElementById('cartToast');
    var toastBody = toastEl ? toastEl.querySelector('.toast-body') : null;

    form.addEventListener('submit', function (e) {
      e.preventDefault(); // ở lại trang

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
          // Xanh khi thành công
          cls.remove('text-bg-danger');
          cls.add('text-bg-success');
          if (toastBody) {
            toastBody.textContent = "Đã thêm \"" + "${product.productName}".replace(/"/g,'\\"') + "\" vào giỏ hàng.";
          }
        } else {
          // Đỏ khi lỗi
          cls.remove('text-bg-success');
          cls.add('text-bg-danger');
          if (toastBody) toastBody.textContent = "Lỗi khi thêm vào giỏ (HTTP " + res.status + ").";
        }

        // Hiển thị toast
        if (typeof bootstrap !== "undefined") {
          var t = bootstrap.Toast.getOrCreateInstance(toastEl);
          t.show();
        } else {
          // Fallback nếu thiếu bootstrap.js: dùng alert
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
