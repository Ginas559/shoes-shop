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
    max-width: 640px;
    aspect-ratio: 1 / 1;
    object-fit: cover;
  }
  .product-detail .thumb{
    width: 96px; height: 96px; object-fit: cover; cursor: pointer;
  }
  @media (max-width: 576px){
    .product-detail .main-img{ max-width: 100%; }
    .product-detail .thumb{ width: 72px; height: 72px; }
  }
  .card:hover{ transform: translateY(-2px); transition: transform .15s ease; }
  .fav-wrap { display:flex; align-items:center; gap:.5rem; margin-top:.5rem; }
  .fav-wrap .btn { line-height: 1.1; }

  /* ===== Reviews / Comments ===== */
  .stars{ color:#f59e0b; } /* amber */
  .star-btn{ cursor:pointer; font-size:1.25rem; line-height:1; }
  .star-btn.inactive{ color:#ddd; }
  .rv-item{ border-bottom:1px solid #eee; padding:12px 0; }
  .rv-meta{ font-size:.9rem; color:#666; }
  .rv-media img, .rv-media video{ max-width:160px; max-height:160px; border-radius:8px; object-fit:cover; }
  .cm-item{ border-bottom:1px dashed #eee; padding:10px 0; }

  /* >>> added for threaded comments >>> */
  .cm-row { padding: 10px 0; border-bottom: 1px dashed #eee; }
  .cm-head { display:flex; align-items:center; gap:.5rem; }
  .cm-meta { color:#6c757d; font-size: .875rem; }
  .cm-actions { display:flex; gap:.5rem; margin-top:.25rem; }
  .cm-actions .btn-link { padding: 0; font-size: .875rem; text-decoration: none; }
  .cm-indent { border-left: 2px solid #f1f1f1; padding-left: 10px; }
  .cm-reply-form { margin-top: .5rem; }
  .cm-reply-form textarea { resize: vertical; }
  /* <<< end added */
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

        <!-- ⭐ Shop -->
        <c:if test="${not empty product.shop}">
          <div class="d-flex align-items-center gap-2 mb-2">
            <c:if test="${not empty product.shop.logoUrl}">
              <img src="${ctx}${product.shop.logoUrl}" alt="<c:out value='${product.shop.shopName}'/>"
                   class="rounded border" style="width:172px;height:172px;object-fit:cover"
                   onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
            </c:if>
            <div>
              <div class="small text-muted">Của shop</div>
              <a class="badge bg-secondary-subtle border text-secondary text-decoration-none"
                 href="<c:url value='/products'><c:param name='shopId' value='${product.shop.shopId}'/></c:url>">
                <c:out value="${product.shop.shopName}"/>
              </a>
            </div>
          </div>
        </c:if>

        <div class="text-muted mb-2">
          <c:out value="${product.category != null ? product.category.categoryName : ''}"/>
        </div>

        <%-- Giá --%>
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

        <!-- FAVORITE -->
        <c:set var="isFavSafe" value="${isFav == true}"/>
        <c:set var="favCountSafe" value="${empty favoriteCount ? 0 : favoriteCount}"/>
        <div class="fav-wrap">
          <button id="btn-fav" type="button" class="btn btn-outline-danger btn-sm"
                  data-product="${product.productId}" aria-pressed="${isFavSafe}">
            <span id="fav-icon">${isFavSafe ? '❤️' : '🤍'}</span>
            <span id="fav-text">${isFavSafe ? 'Đã thích' : 'Thêm Yêu thích'}</span>
          </button>
          <small class="text-muted">(<span id="fav-count">${favCountSafe}</span>)</small>
        </div>

        <p class="mt-3"><c:out value="${product.description}"/></p>

        <!-- Add to cart -->
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

    <!-- RELATED -->
    <c:if test="${not empty relatedProducts}">
      <h2 class="h6 mt-4 mb-2">Sản phẩm liên quan</h2>
      <div class="row row-cols-2 row-cols-md-4 g-3">
        <c:forEach var="rp" items="${relatedProducts}">
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
              <c:set var="rpCover" value="${ctx.concat('/assets/img/products/').concat(rpFixed)}"/>
            </c:otherwise>
          </c:choose>

          <div class="col">
            <div class="card h-100">
              <a href="${ctx}/product/${rp.id}">
                <img class="card-img-top" style="aspect-ratio:1/1;object-fit:cover"
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

    <!-- RECENTLY VIEWED -->
    <div class="mt-4">
      <div class="d-flex align-items-center justify-content-between mb-2">
        <h2 class="h4 m-0 fw-semibold">Bạn đã xem gần đây</h2>
        <a class="btn btn-sm btn-outline-secondary" href="${ctx}/recent">Xem tất cả</a>
      </div>

      <c:choose>
        <c:when test="${not empty recentViewed}">
          <div class="row row-cols-2 row-cols-md-6 g-3">
            <c:forEach var="rv" items="${recentViewed}">
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
                  <c:set var="rvCover" value="${ctx.concat('/assets/img/products/').concat(rvFixed)}"/>
                </c:otherwise>
              </c:choose>

              <div class="col">
                <div class="card h-100">
                  <a href="${ctx}/product/${rv.productId}">
                    <img class="card-img-top" style="aspect-ratio:1/1;object-fit:cover"
                         src="${empty rvCover ? (ctx.concat('/assets/img/placeholder.png')) : rvCover}"
                         alt="<c:out value='${rv.productName}'/>"
                         onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
                  </a>
                  <div class="card-body p-2">
                    <div class="fw-semibold text-truncate" title="${rv.productName}">
                      <c:out value="${rv.productName}"/>
                    </div>
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

    <!-- ========================================================= -->
    <!-- =================== (G1) REVIEWS ======================== -->
    <!-- ========================================================= -->
    <div class="mt-5">
      <h2 class="h5 mb-3">Đánh giá sản phẩm</h2>

      <!-- Summary -->
      <c:set var="avgStar" value="${empty reviewStats ? 0 : reviewStats.avg}"/>
      <c:set var="countStar" value="${empty reviewStats ? 0 : reviewStats.count}"/>
      <div class="d-flex align-items-center gap-2 mb-3">
        <div class="fs-4 fw-bold">${avgStar}</div>
        <div class="stars" aria-label="${avgStar} trên 5 sao">
          <c:forEach var="i" begin="1" end="5">
            <span>${i <= (avgStar+0.5) ? '★' : '☆'}</span>
          </c:forEach>
        </div>
        <div class="text-muted">(${countStar} đánh giá)</div>
      </div>

      <!-- Form add/update review -->
      <c:if test="${canReview == true}">
        <div class="border rounded p-3 mb-3">
          <form id="reviewForm" method="post" action="${ctx}/review/save">
            <input type="hidden" name="productId" value="${product.productId}"/>

            <div class="mb-2">
              <label class="form-label">Chấm điểm</label>
              <div id="starPicker" class="stars">
                <c:set var="myRating" value="${empty userReview ? 0 : userReview.rating}"/>
                <c:forEach var="i" begin="1" end="5">
                  <span class="star-btn ${i <= myRating ? '' : 'inactive'}" data-v="${i}">★</span>
                </c:forEach>
              </div>
              <input type="hidden" name="rating" id="rvRating" value="${myRating}"/>
            </div>

            <div class="mb-2">
              <label class="form-label">Nội dung</label>
              <textarea class="form-control" name="comment" rows="3"
                        placeholder="Cảm nhận của bạn...">${empty userReview ? '' : userReview.commentText}</textarea>
            </div>

            <div class="row g-2">
              <div class="col-12 col-md-6">
                <label class="form-label">Ảnh (URL)</label>
                <input class="form-control" type="url" name="imageUrl" value="${empty userReview ? '' : userReview.imageUrl}"
                       placeholder="https://... (Cloudinary được hỗ trợ)"/>
              </div>
              <div class="col-12 col-md-6">
                <label class="form-label">Video (URL)</label>
                <input class="form-control" type="url" name="videoUrl" value="${empty userReview ? '' : userReview.videoUrl}"
                       placeholder="https://..."/>
              </div>
            </div>

            <div class="mt-3 d-flex gap-2">
              <button class="btn btn-primary" type="submit">${empty userReview ? 'Gửi đánh giá' : 'Cập nhật đánh giá'}</button>
              <c:if test="${not empty userReview}">
                <button class="btn btn-outline-danger" type="button" id="btnDelReview">Xoá đánh giá</button>
              </c:if>
            </div>
          </form>
        </div>
      </c:if>
      <c:if test="${canReview != true}">
        <div class="alert alert-info">Bạn cần đăng nhập và/hoặc đã mua hàng để đánh giá.</div>
      </c:if>

      <!-- List reviews -->
      <c:if test="${not empty reviews}">
        <div class="mt-3">
          <c:forEach var="rv" items="${reviews}">
            <div class="rv-item">
              <div class="d-flex align-items-center gap-2">
                <strong><c:out value="${rv.userName}"/></strong>
                <span class="rv-meta">• <fmt:formatDate value="${rv.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
              </div>
              <div class="stars">
                <c:forEach var="i" begin="1" end="5">
                  <span>${i <= rv.rating ? '★' : '☆'}</span>
                </c:forEach>
              </div>
              <div class="mt-1"><c:out value="${rv.commentText}"/></div>
              <div class="rv-media d-flex gap-2 mt-2">
                <c:if test="${not empty rv.imageUrl}">
                  <img src="<c:url value='${rv.imageUrl}'/>" alt="review image"
                       onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
                </c:if>
                <c:if test="${not empty rv.videoUrl}">
                  <video src="<c:url value='${rv.videoUrl}'/>" controls></video>
                </c:if>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:if>
      <c:if test="${empty reviews}">
        <div class="text-muted">Chưa có đánh giá nào.</div>
      </c:if>
    </div>

    <!-- ========================================================= -->
    <!-- ================== (G2) COMMENTS ======================== -->
    <!-- ========================================================= -->
    <div class="mt-5">
      <h2 class="h6 mb-3">Bình luận</h2>

      <!-- Form comment -->
      <div class="border rounded p-3 mb-3">
        <form id="commentForm" method="post" action="${ctx}/comment/add">
          <input type="hidden" name="productId" value="${product.productId}"/>
          <div class="mb-2">
            <textarea class="form-control" name="content" rows="2" maxlength="500"
                      placeholder="Viết bình luận..."></textarea>
          </div>
          <button class="btn btn-outline-primary btn-sm" type="submit" id="btnComment">Gửi bình luận</button>
          <small id="cmHint" class="text-muted ms-2 d-none"></small>
        </form>
      </div>

      <!-- List comments (server-side fallback; JS sẽ load thread và render lại) -->
      <c:if test="${not empty comments}">
        <div id="cmList" data-productid="${product.productId}">
          <c:forEach var="cm" items="${comments}">
            <div class="cm-item">
              <div class="d-flex align-items-center gap-2">
                <strong><c:out value="${cm.userName}"/></strong>
                <span class="text-muted small"><fmt:formatDate value="${cm.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
              </div>
              <div class="mt-1"><c:out value="${cm.content}"/></div>
            </div>
          </c:forEach>
        </div>
      </c:if>
      <c:if test="${empty comments}">
        <div id="cmList" data-productid="${product.productId}">
          <div class="text-muted">Chưa có bình luận.</div>
        </div>
      </c:if>
    </div>

  </c:when>
  <c:otherwise>
    <div class="text-center text-muted py-5">Không tìm thấy sản phẩm.</div>
  </c:otherwise>
</c:choose>

<!-- Toast container -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1080">
  <div id="cartToast" class="toast align-items-center text-bg-success border-0" role="status"
       aria-live="polite" aria-atomic="true" data-bs-autohide="true" data-bs-delay="2500">
    <div class="d-flex">
      <div class="toast-body">Đã thêm sản phẩm vào giỏ hàng!</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
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

<!-- FAVORITE toggle AJAX -->
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
        if (res.status === 401) { window.location.href = '${ctx}/login'; return null; }
        var text = await res.text();
        if (!res.ok) { throw new Error('HTTP ' + res.status + (text?': '+text.slice(0,120):'')); }
        var json; try { json = text ? JSON.parse(text) : null; } catch(e) { json = null; }
        if (!json || json.ok !== true) { throw new Error('Phản hồi không hợp lệ.'); }
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
      .catch(function (err) { alert('Không thể cập nhật yêu thích: ' + err.message); });
    });
  })();
</script>

<!-- AJAX + Toast (cart) -->
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
          cls.remove('text-bg-danger'); cls.add('text-bg-success');
          if (toastBody) toastBody.textContent = "Đã thêm \"" + "${product.productName}".replace(/\"/g,'\\"') + "\" vào giỏ hàng.";
        } else {
          cls.remove('text-bg-success'); cls.add('text-bg-danger');
          if (toastBody) toastBody.textContent = "Lỗi khi thêm vào giỏ (HTTP " + res.status + ").";
        }
        if (typeof bootstrap !== "undefined") {
          var t = bootstrap.Toast.getOrCreateInstance(toastEl); t.show();
        } else { alert(toastBody ? toastBody.textContent : "Hoàn tất thao tác."); }
      })
      .catch(function (err) {
        if (!toastEl) return;
        var cls = toastEl.classList; cls.remove('text-bg-success'); cls.add('text-bg-danger');
        if (toastBody) toastBody.textContent = "Lỗi kết nối: " + err.message;
        if (typeof bootstrap !== "undefined") {
          var t = bootstrap.Toast.getOrCreateInstance(toastEl); t.show();
        } else { alert(toastBody ? toastBody.textContent : "Lỗi kết nối."); }
      });
    });
  })();
</script>

<!-- Review stars + delete -->
<script>
  (function () {
    // Star picker
    var holder = document.getElementById('starPicker');
    var ratingInput = document.getElementById('rvRating');
    if (holder && ratingInput) {
      holder.querySelectorAll('.star-btn').forEach(function (el) {
        el.addEventListener('click', function(){
          var v = parseInt(el.getAttribute('data-v') || '0', 10);
          ratingInput.value = v;
          holder.querySelectorAll('.star-btn').forEach(function(s, idx){
            if (idx < v) s.classList.remove('inactive'); else s.classList.add('inactive');
          });
        });
      });
    }

    // Delete review
    var delBtn = document.getElementById('btnDelReview');
    if (delBtn) {
      delBtn.addEventListener('click', function(){
        if (!confirm('Xoá đánh giá của bạn?')) return;
        fetch('${ctx}/review/delete', { method:'POST',
          headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
          body:'productId=' + encodeURIComponent('${product.productId}')
        })
        .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); location.reload(); })
        .catch(function(e){ alert('Không thể xoá: '+e.message); });
      });
    }
  })();
</script>

<!-- ======= AJAX COMMENT (thêm mới, không reload) ======= -->
<script>
  (function () {
    var form = document.getElementById('commentForm');
    if (!form) return;

    var btn  = document.getElementById('btnComment');
    var hint = document.getElementById('cmHint');
    var list = document.getElementById('cmList');

    function esc(s){
      if (s == null) return "";
      return String(s)
        .replaceAll("&","&amp;")
        .replaceAll("<","&lt;")
        .replaceAll(">","&gt;")
        .replaceAll('"',"&quot;")
        .replaceAll("'","&#39;");
    }

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var fd = new FormData(form);
      var productId = fd.get('productId');
      var content   = (fd.get('content') || '').trim();
      if (!content) {
        hint && (hint.textContent = "Nội dung trống."); hint && hint.classList.remove('d-none');
        return;
      }
      hint && hint.classList.add('d-none');
      btn && (btn.disabled = true);

      fetch(form.action, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest',
                   'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: new URLSearchParams({ productId: productId, content: content })
      })
      .then(async function (res) {
        var text = await res.text();
        var data = {};
        try { data = text ? JSON.parse(text) : {}; } catch(e) {}

        if (res.status === 401 || data.error === 'unauthenticated') {
          window.location.href = '${ctx}/login';
          return null;
        }
        if (!res.ok || data.ok !== true) {
          throw new Error((data && data.error) ? data.error : ('HTTP ' + res.status));
        }
        return data;
      })
      .then(function (data) {
        if (!data) return;

        // Reset textarea
        form.querySelector('textarea[name="content"]').value = '';

        // Nếu list đang có "Chưa có bình luận." thì xoá
        if (list && list.children.length === 1 && list.firstElementChild && list.firstElementChild.classList.contains('text-muted')) {
          list.innerHTML = '';
        }

        // (Giữ hành vi cũ) Tạo node mới và prepend
        var wrap = document.createElement('div');
        wrap.className = 'cm-item';
        wrap.innerHTML =
          '<div class="d-flex align-items-center gap-2">' +
            '<strong>' + esc(data.userName || 'Bạn') + '</strong>' +
            '<span class="text-muted small">' + esc(data.createdAt || '') + '</span>' +
          '</div>' +
          '<div class="mt-1">' + esc(data.content || '') + '</div>';
        list && list.prepend(wrap);

        // >>> added: sau khi thêm thành công, reload thread để đồng bộ dạng cây
        try {
          var pid = document.getElementById('cmList')?.getAttribute('data-productid');
          if (pid) window.loadThread && window.loadThread(pid);
        } catch(e) {}
        // <<< end added

        hint && (hint.textContent = "Đã đăng bình luận!"); hint && hint.classList.remove('d-none');
        setTimeout(function(){ hint && hint.classList.add('d-none'); }, 1800);
      })
      .catch(function (err) {
        hint && (hint.textContent = "Không thể gửi bình luận: " + err.message);
        hint && hint.classList.remove('d-none');
      })
      .finally(function () {
        btn && (btn.disabled = false);
      });
    });
  })();
</script>

<!-- >>> added for threaded comments: loader, render, reply & delete handlers >>> -->
<script>
  (function(){
    var cmList = document.getElementById('cmList');
    if (!cmList) return;
    var productId = cmList.getAttribute('data-productid') || '';

    function esc(s){
      if (s == null) return "";
      return String(s)
        .replaceAll("&","&amp;")
        .replaceAll("<","&lt;")
        .replaceAll(">","&gt;")
        .replaceAll('"',"&quot;")
        .replaceAll("'","&#39;");
    }

    function makeRow(item){
      var depth = item.depth || 0;
      var left = Math.min(depth * 16, 160); // hạn chế indent tối đa
      var canDel = !!item.canDelete;

      var row = document.createElement('div');
      row.className = 'cm-row';
      row.setAttribute('data-id', item.commentId);

      var inner = document.createElement('div');
      inner.className = depth > 0 ? 'cm-indent' : '';
      inner.style.marginLeft = left + 'px';

      inner.innerHTML =
        '<div class="cm-head">' +
          '<strong>' + esc(item.userName || 'Ẩn danh') + '</strong>' +
          '<span class="cm-meta">' + (item.createdAt ? '• ' + esc(item.createdAt) : '') + '</span>' +
        '</div>' +
        '<div class="cm-body mt-1">' + esc(item.content || '') + '</div>' +
        '<div class="cm-actions">' +
          '<button type="button" class="btn btn-link p-0 cm-reply-btn">Trả lời</button>' +
          (canDel ? '<button type="button" class="btn btn-link text-danger p-0 ms-2 cm-del-btn">Xoá</button>' : '') +
        '</div>' +
        '<div class="cm-reply-form d-none">' +
          '<textarea class="form-control form-control-sm" rows="2" maxlength="500" placeholder="Phản hồi của bạn..."></textarea>' +
          '<div class="mt-1 d-flex gap-2">' +
            '<button type="button" class="btn btn-primary btn-sm cm-reply-send">Gửi</button>' +
            '<button type="button" class="btn btn-outline-secondary btn-sm cm-reply-cancel">Huỷ</button>' +
          '</div>' +
        '</div>';

      row.appendChild(inner);
      return row;
    }

    function attachRowEvents(row){
      var replyBtn = row.querySelector('.cm-reply-btn');
      var delBtn   = row.querySelector('.cm-del-btn');
      var formWrap = row.querySelector('.cm-reply-form');
      var sendBtn  = row.querySelector('.cm-reply-send');
      var cancelBtn= row.querySelector('.cm-reply-cancel');
      var textarea = row.querySelector('textarea');

      if (replyBtn) {
        replyBtn.addEventListener('click', function(){
          if (formWrap.classList.contains('d-none')) {
            // Ẩn các form khác đang mở
            document.querySelectorAll('#cmList .cm-reply-form').forEach(function(f){
              f.classList.add('d-none');
            });
            formWrap.classList.remove('d-none');
            textarea && textarea.focus();
          } else {
            formWrap.classList.add('d-none');
          }
        });
      }

      if (cancelBtn) {
        cancelBtn.addEventListener('click', function(){
          formWrap.classList.add('d-none');
        });
      }

      if (sendBtn) {
        sendBtn.addEventListener('click', function(){
          var content = (textarea && textarea.value ? textarea.value.trim() : '');
          if (!content) { alert('Nội dung trống.'); return; }
          var cid = row.getAttribute('data-id');

          fetch('${ctx}/comment/add', {
            method: 'POST',
            headers: {
              'X-Requested-With': 'XMLHttpRequest',
              'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: new URLSearchParams({
              productId: productId,
              content: content,
              parentId: cid
            })
          })
          .then(async function(res){
            var text = await res.text();
            var data = {};
            try { data = text ? JSON.parse(text) : {}; } catch(e){}
            if (res.status === 401 || data.error === 'unauthenticated') {
              window.location.href = '${ctx}/login';
              return null;
            }
            if (!res.ok || data.ok !== true) {
              var msg = (data && data.error) ? data.error : ('HTTP ' + res.status);
              throw new Error(msg);
            }
            return data;
          })
          .then(function(){
            textarea && (textarea.value = '');
            formWrap.classList.add('d-none');
            window.loadThread && window.loadThread(productId);
          })
          .catch(function(err){
            if (err && String(err).includes('invalid_parent')) {
              alert('Không thể trả lời: comment gốc không hợp lệ.');
            } else {
              alert('Không thể gửi trả lời: ' + err.message);
            }
          });
        });
      }

      if (delBtn) {
        delBtn.addEventListener('click', function(){
          if (!confirm('Xoá bình luận này? (Chỉ xoá được trong vòng 24h và nếu chưa có trả lời)')) return;
          var cid = row.getAttribute('data-id');
          fetch('${ctx}/comment/delete', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                       'X-Requested-With': 'XMLHttpRequest' },
            body: new URLSearchParams({ productId: productId, commentId: cid })
          })
          .then(async function(res){
            var text = await res.text();
            var data = {};
            try { data = text ? JSON.parse(text) : {}; } catch(e){}
            if (res.status === 401 || data.error === 'unauthenticated') {
              window.location.href='${ctx}/login'; return null;
            }
            if (!res.ok || (data && data.ok !== true)) {
              throw new Error((data && data.error) ? data.error : ('HTTP ' + res.status));
            }
            return data;
          })
          .then(function(){
            window.loadThread && window.loadThread(productId);
          })
          .catch(function(err){
            if (String(err.message).includes('too_late')) {
              alert('Không thể xoá: quá 24h, không phải chủ sở hữu hoặc bình luận đã có trả lời.');
            } else {
              alert('Không thể xoá: ' + err.message);
            }
          });
        });
      }
    }

    function renderThread(items){
      if (!cmList) return;
      cmList.innerHTML = '';
      if (!items || !items.length) {
        cmList.innerHTML = '<div class="text-muted">Chưa có bình luận.</div>';
        return;
      }
      items.forEach(function(it){
        var row = makeRow(it);
        cmList.appendChild(row);
        attachRowEvents(row);
      });
    }

    function loadThread(pid){
      fetch('${ctx}/comment/thread?productId=' + encodeURIComponent(pid), {
        headers: { 'Accept': 'application/json' }
      })
      .then(async function(res){
        var text = await res.text();
        var json = {};
        try { json = text ? JSON.parse(text) : {}; } catch(e){}
        if (!res.ok || json.ok !== true) throw new Error('HTTP ' + res.status);
        return json;
      })
      .then(function(json){
        renderThread(json.items || []);
      })
      .catch(function(e){
        // Không làm vỡ trang nếu lỗi; vẫn hiển thị fallback server-side
        // console.warn('Load thread failed:', e);
      });
    }

    // public for other blocks
    window.loadThread = loadThread;

    // initial load
    if (productId) loadThread(productId);
  })();
</script>
<!-- <<< end added -->
