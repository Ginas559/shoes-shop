<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<fmt:setLocale value="vi_VN" scope="page" />

<style>
.product-detail .main-img{width:100%;max-width:640px;aspect-ratio:1/1;object-fit:cover}
.product-detail .thumb{width:96px;height:96px;object-fit:cover;cursor:pointer}
@media(max-width:576px){.product-detail .main-img{max-width:100%}.product-detail .thumb{width:72px;height:72px}}
.card:hover{transform:translateY(-2px);transition:transform .15s ease}
.fav-wrap{display:flex;align-items:center;gap:.5rem;margin-top:.5rem}
.fav-wrap .btn{line-height:1.1}
.stars{color:#f59e0b}
.star-btn{cursor:pointer;font-size:1.25rem;line-height:1}
.star-btn.inactive{color:#ddd}
.rv-item{border-bottom:1px solid #eee;padding:12px 0}
.rv-meta{font-size:.9rem;color:#666}
.rv-media img,.rv-media video{max-width:160px;max-height:160px;border-radius:8px;object-fit:cover}
.cm-item{border-bottom:1px dashed #eee;padding:10px 0}
.cm-row{padding:10px 0;border-bottom:1px dashed #eee}
.cm-head{display:flex;align-items:center;gap:.5rem}
.cm-meta{color:#6c757d;font-size:.875rem}
.cm-actions{display:flex;gap:.5rem;margin-top:.25rem}
.cm-actions .btn-link{padding:0;font-size:.875rem;text-decoration:none}
.cm-indent{border-left:2px solid #f1f1f1;padding-left:10px}
.cm-reply-form{margin-top:.5rem}
.cm-reply-form textarea{resize:vertical}
</style>

<c:choose>
<c:when test="${not empty product}">
  <div class="row g-3 product-detail">
    <div class="col-12 col-md-6">
      <%-- resolve main image --%>
      <c:set var="mainRaw" value="${empty images ? '' : images[0]}"/>
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
            <c:set var="tRaw" value="${empty img ? '' : img}"/>
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

    <div class="col-12 col-md-6">
      <h1 class="h5"><c:out value="${product.productName}"/></h1>

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
            <a href="${ctx}/chat/public?shopId=${product.shop.shopId}" class="btn btn-outline-primary">💬 Chat công khai với cửa hàng</a>
          </div>
        </div>
      </c:if>

      <div class="text-muted mb-2">
        <c:out value="${product.category != null ? product.category.categoryName : ''}"/>
      </div>

      <c:set var="priceMain" value="${not empty product.discountPrice ? product.discountPrice : product.price}"/>
      <div class="fs-4 fw-bold">
        <fmt:formatNumber value="${priceMain}" type="number" maxFractionDigits="0"/> ₫
        <span class="text-muted small">(
          <c:choose>
            <c:when test="${priceMain >= 1000000}">
              <fmt:formatNumber value="${priceMain / 1000000.0}" maxFractionDigits="1"/> triệu
            </c:when>
            <c:otherwise>
              <fmt:formatNumber value="${priceMain / 1000.0}" maxFractionDigits="0"/>k
            </c:otherwise>
          </c:choose>
          )</span>
      </div>

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

      <div class="mt-3">
        <form id="addToCartForm" method="post" action="${ctx}/cart/add" class="d-flex align-items-center gap-2">
          <input type="hidden" name="productId" value="${product.productId}"/>
          <div class="input-group" style="width:220px;">
            <input type="number" name="quantity" value="1" min="1" class="form-control"/>
            <button type="submit" class="btn btn-primary">Thêm vào giỏ</button>
          </div>
        </form>
        <small class="text-muted d-block mt-2">Xem giỏ tại
          <a class="text-decoration-none" href="${ctx}/cart">${ctx}/cart</a>.
        </small>
      </div>

      <div class="mt-3 d-flex gap-2">
        <a class="btn btn-outline-secondary" href="${ctx}/products">← Quay lại danh sách</a>
        <a class="btn btn-primary" href="${ctx}/product/${product.productId}">Tải lại</a>
      </div>
    </div>
  </div>

  <%-- liên quan & đã xem (giữ nguyên) --%>
  <c:if test="${not empty relatedProducts}">
    <h2 class="h6 mt-4 mb-2">Sản phẩm liên quan</h2>
    <div class="row row-cols-2 row-cols-md-4 g-3">
      <c:forEach var="rp" items="${relatedProducts}">
        <c:set var="rpRaw" value="${empty rp.coverUrl ? '' : rp.coverUrl}"/>
        <c:set var="rpFixed" value="${fn:replace(rpRaw, '/assset/', '/assets/')}"/>
        <c:choose>
          <c:when test="${fn:startsWith(rpFixed,'http://') or fn:startsWith(rpFixed,'https://')}"><c:set var="rpCover" value="${rpFixed}"/></c:when>
          <c:when test="${fn:startsWith(rpFixed,'/assets/')}"><c:set var="rpCover" value="${ctx.concat(rpFixed)}"/></c:when>
          <c:when test="${fn:startsWith(rpFixed,'/')}"><c:set var="rpCover" value="${rpFixed}"/></c:when>
          <c:otherwise><c:set var="rpCover" value="${ctx.concat('/assets/img/products/').concat(rpFixed)}"/></c:otherwise>
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
              <div class="small text-muted text-truncate"><c:out value="${rp.category != null ? rp.category.categoryName : ''}"/></div>
              <div class="fw-semibold text-truncate" title="${rp.productName}"><c:out value="${rp.productName}"/></div>
              <c:set var="rpMain" value="${not empty rp.discountPrice ? rp.discountPrice : rp.price}"/>
              <div class="fw-bold"><fmt:formatNumber value="${rpMain}" type="number" maxFractionDigits="0"/> ₫</div>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:if>

  <div class="mt-4">
    <div class="d-flex align-items-center justify-content-between mb-2">
      <h2 class="h4 m-0 fw-semibold">Bạn đã xem gần đây</h2>
      <a class="btn btn-sm btn-outline-secondary" href="${ctx}/recent">Xem tất cả</a>
    </div>
    <c:choose>
      <c:when test="${not empty recentViewed}">
        <div class="row row-cols-2 row-cols-md-6 g-3">
          <c:forEach var="rv" items="${recentViewed}">
            <c:set var="rvRaw" value="${empty rv.coverUrl ? '' : rv.coverUrl}"/>
            <c:set var="rvFixed" value="${fn:replace(rvRaw, '/assset/', '/assets/')}"/>
            <c:choose>
              <c:when test="${fn:startsWith(rvFixed,'http://') or fn:startsWith(rvFixed,'https://')}"><c:set var="rvCover" value="${rvFixed}"/></c:when>
              <c:when test="${fn:startsWith(rvFixed,'/assets/')}"><c:set var="rvCover" value="${ctx.concat(rvFixed)}"/></c:when>
              <c:when test="${fn:startsWith(rvFixed,'/')}"><c:set var="rvCover" value="${rvFixed}"/></c:when>
              <c:otherwise><c:set var="rvCover" value="${ctx.concat('/assets/img/products/').concat(rvFixed)}"/></c:otherwise>
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
                  <div class="fw-semibold text-truncate" title="${rv.productName}"><c:out value="${rv.productName}"/></div>
                  <c:set var="rvMain" value="${not empty rv.discountPrice ? rv.discountPrice : rv.price}"/>
                  <div class="fw-bold small"><fmt:formatNumber value="${rvMain}" type="number" maxFractionDigits="0"/> ₫</div>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="border rounded p-3 bg-light-subtle">
          <div class="d-flex align-items-center gap-3">
            <div class="rounded bg-white border d-flex align-items-center justify-content-center" style="width:56px;height:56px;"><span class="text-muted">🕘</span></div>
            <div>
              <div class="fw-semibold">Chưa có lịch sử đã xem</div>
              <div class="text-muted small">Hãy duyệt vài sản phẩm — chúng sẽ xuất hiện ở đây để bạn mở lại nhanh.</div>
            </div>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <%-- Đánh giá --%>
  <div class="mt-5">
    <div id="reviews"></div>

    <c:set var="canReviewStr" value="${empty canReview ? '' : canReview}"/>
    <c:set var="canReviewStrLower" value="${fn:toLowerCase(canReviewStr)}"/>
    <c:set var="canReviewOK" value="${canReview == true or canReviewStrLower == 'true' or canReviewStrLower == '1'}"/>

    <c:set var="loggedInStr" value="${empty loggedIn ? '' : loggedIn}"/>
    <c:set var="loggedInStrLower" value="${fn:toLowerCase(loggedInStr)}"/>
    <c:set var="loggedInOK" value="${loggedIn == true or loggedInStrLower == 'true' or loggedInStrLower == '1'}"/>

    <c:set var="fromOrderStr" value="${empty fromOrder ? '' : fromOrder}"/>
    <c:set var="fromOrderStrLower" value="${fn:toLowerCase(fromOrderStr)}"/>
    <c:set var="fromOrderOK" value="${fromOrder == true or fromOrderStrLower == 'true' or fromOrderStrLower == '1'}"/>

    <h2 class="h5 mb-3">Đánh giá sản phẩm</h2>
    <c:set var="avgStar" value="${empty reviewStats ? 0 : reviewStats.avg}"/>
    <c:set var="countStar" value="${empty reviewStats ? 0 : reviewStats.count}"/>
    <div class="d-flex align-items-center gap-2 mb-3">
      <div id="rv-avg" class="fs-4 fw-bold">${avgStar}</div>
      <div id="rv-avg-stars" class="stars" aria-label="${avgStar} trên 5 sao">
        <c:forEach var="i" begin="1" end="5"><span>${i <= (avgStar+0.5) ? '★' : '☆'}</span></c:forEach>
      </div>
      <div class="text-muted">(<span id="rv-count">${countStar}</span> đánh giá)</div>
    </div>

    <%-- Form --%>
    <c:if test="${canReviewOK or not empty userReview or (loggedInOK and fromOrderOK)}">
      <div class="border rounded p-3 mb-3">
        <form id="reviewForm" method="post" action="${ctx}/review/save" enctype="multipart/form-data">
          <input type="hidden" name="productId" value="${product.productId}"/>
          <div class="mb-2">
            <label class="form-label">Chấm điểm</label>
            <div id="starPicker" class="stars">
              <c:set var="myRating" value="${empty userReview ? 0 : userReview.rating}"/>
              <c:forEach var="i" begin="1" end="5"><span class="star-btn ${i <= myRating ? '' : 'inactive'}" data-v="${i}">★</span></c:forEach>
            </div>
            <input type="hidden" name="rating" id="rvRating" value="${myRating}"/>
          </div>
          <div class="mb-2">
            <label class="form-label">Nội dung</label>
            <textarea class="form-control" name="comment" rows="3" placeholder="Cảm nhận của bạn...">${empty userReview ? '' : userReview.commentText}</textarea>
          </div>

          <%-- NEW: Upload + URL (song song) --%>
          <div class="row g-2">
            <div class="col-12 col-md-6">
              <label class="form-label">Ảnh thực tế</label>
              <input class="form-control" type="file" name="images" accept="image/*" multiple/>
              <small class="text-muted d-block mt-1">Tối đa 6 ảnh, mỗi ảnh ≤ 5MB. Hoặc dán URL ở dưới.</small>
              <input class="form-control mt-2" type="url" name="imageUrl" value="${empty userReview ? '' : userReview.imageUrl}" placeholder="https://... (tuỳ chọn)"/>
            </div>
            <div class="col-12 col-md-6">
              <label class="form-label">Video minh hoạ</label>
              <input class="form-control" type="file" name="video" accept="video/mp4"/>
              <small class="text-muted d-block mt-1">Tối đa 1 video, ≤ 50MB. Hoặc dán URL ở dưới.</small>
              <input class="form-control mt-2" type="url" name="videoUrl" value="${empty userReview ? '' : userReview.videoUrl}" placeholder="https://... (tuỳ chọn)"/>
            </div>
          </div>

          <div class="mt-3 d-flex gap-2 align-items-center">
            <button class="btn btn-primary" type="submit" id="btnSubmitReview">${empty userReview ? 'Gửi đánh giá' : 'Cập nhật đánh giá'}</button>
            <c:if test="${not empty userReview}"><button class="btn btn-outline-danger" type="button" id="btnDelReview">Xoá đánh giá</button></c:if>
            <small id="rvHint" class="text-muted ms-2 d-none"></small>
          </div>
        </form>
      </div>
    </c:if>

    <c:if test="${not (canReviewOK or not empty userReview or (loggedInOK and fromOrderOK))}}">
      <div class="alert alert-info">Bạn cần đăng nhập và/hoặc đã mua hàng để đánh giá.</div>
    </c:if>

    <%-- Lấy danh sách: ưu tiên reviews, fallback rvList --%>
    <c:set var="rvItems" value="${not empty reviews ? reviews : rvList}"/>

    <c:choose>
      <c:when test="${not empty rvItems}">
        <div id="rv-list" class="mt-3">
          <c:forEach var="rv" items="${rvItems}">
            <div class="rv-item">
              <div class="d-flex align-items-center gap-2">
                <strong><c:out value="${rv.userName}"/></strong>
                <span class="rv-meta">• <c:out value="${rv.createdAt}"/></span>
                <c:set var="__created" value="${rv.createdAt}"/>
                <c:if test="${not empty __created}">
                  <c:catch var="__fmtErr">
                    <fmt:formatDate value="${__created}" pattern="dd/MM/yyyy HH:mm" var="__createdFmt"/>
                  </c:catch>
                  <c:choose>
                    <c:when test="${empty __fmtErr and not empty __createdFmt}">
                      <span class="rv-meta">• ${__createdFmt}</span>
                    </c:when>
                    <c:otherwise>
                      <span class="rv-meta">• <c:out value="${__created}"/></span>
                    </c:otherwise>
                  </c:choose>
                </c:if>
              </div>
              <div class="stars">
                <c:forEach var="i" begin="1" end="5"><span>${i <= rv.rating ? '★' : '☆'}</span></c:forEach>
              </div>
              <div class="mt-1">
                <c:out value="${not empty rv.commentText ? rv.commentText : (not empty rv.comment ? rv.comment : '')}"/>
              </div>
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
      </c:when>
      <c:otherwise>
        <c:choose>
          <c:when test="${countStar == 0}">
            <div class="text-muted" id="rv-empty">Chưa có đánh giá nào.</div>
          </c:when>
          <c:otherwise>
            <div id="rv-list" class="mt-3" data-lazy-reviews="1">
              <div class="text-muted">Đang tải danh sách đánh giá...</div>
            </div>
          </c:otherwise>
        </c:choose>
      </c:otherwise>
    </c:choose>
  </div>

  <%-- BÌNH LUẬN --%>
  <div class="mt-5">
    <h2 class="h6 mb-3">Bình luận</h2>
    <div class="border rounded p-3 mb-3">
      <form id="commentForm" method="post" action="${ctx}/comment/add">
        <input type="hidden" name="productId" value="${product.productId}"/>
        <div class="mb-2">
          <textarea class="form-control" name="content" rows="2" maxlength="500" placeholder="Viết bình luận..."></textarea>
        </div>
        <button class="btn btn-outline-primary btn-sm" type="submit" id="btnComment">Gửi bình luận</button>
        <small id="cmHint" class="text-muted ms-2 d-none"></small>
      </form>
    </div>

    <div id="cmList" data-productid="${product.productId}">
      <div class="text-muted">Đang tải bình luận...</div>
    </div>
  </div>

</c:when>
<c:otherwise>
  <div class="text-center text-muted py-5">Không tìm thấy sản phẩm.</div>
</c:otherwise>
</c:choose>

<%-- Toast cho giỏ (giữ nguyên) --%>
<div class="position-fixed bottom-0 end-0 p-3" style="z-index:1080">
  <div id="cartToast" class="toast align-items-center text-bg-success border-0" role="status" aria-live="polite" aria-atomic="true" data-bs-autohide="true" data-bs-delay="2500">
    <div class="d-flex">
      <div class="toast-body">Đã thêm sản phẩm vào giỏ hàng!</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>

<%-- Toast riêng cho bình luận/đánh giá --%>
<div class="position-fixed bottom-0 end-0 p-3" style="z-index:1080">
  <div id="cmToast" class="toast align-items-center text-bg-primary border-0" role="status" aria-live="polite" aria-atomic="true" data-bs-autohide="true" data-bs-delay="2200">
    <div class="d-flex">
      <div class="toast-body" id="cmToastBody">Đã đăng bình luận.</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>

<%-- Modal xác nhận xoá bình luận --%>
<div class="modal fade" id="cmConfirmModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Xác nhận</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <div class="modal-body" id="cmConfirmMessage">Xóa bình luận này?</div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <button type="button" class="btn btn-danger" id="cmConfirmOk">Xóa</button>
      </div>
    </div>
  </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function(){
  const ctx = "<c:out value='${ctx}'/>";

  /* ===== Helpers: Toast & Confirm Modal ===== */
  function showToast(msg, variant){
    var el = document.getElementById("cmToast");
    var body = document.getElementById("cmToastBody");
    if (!el || !body){ alert(msg); return; }
    body.textContent = msg || "";
    el.classList.remove("text-bg-success","text-bg-danger","text-bg-primary");
    el.classList.add(variant === "success" ? "text-bg-success" : (variant === "danger" ? "text-bg-danger" : "text-bg-primary"));
    try{
      var t = window.bootstrap ? bootstrap.Toast.getOrCreateInstance(el) : null;
      t ? t.show() : (el.style.display="block", setTimeout(function(){el.style.display="none";},2000));
    }catch(e){ console.warn(e); }
  }
  function confirmModal(message){
    return new Promise(function(resolve){
      var modalEl = document.getElementById("cmConfirmModal");
      var msgEl   = document.getElementById("cmConfirmMessage");
      var okBtn   = document.getElementById("cmConfirmOk");
      if (!modalEl || !okBtn){ resolve(confirm(message||"Xóa?")); return; }
      if (msgEl) msgEl.textContent = message || "Bạn chắc chắn?";
      var bs = window.bootstrap ? bootstrap.Modal.getOrCreateInstance(modalEl, {backdrop:"static"}) : null;
      function cleanup(){
        okBtn.onclick = null;
        modalEl.removeEventListener("hidden.bs.modal", onHidden);
      }
      function onHidden(){ cleanup(); resolve(false); }
      okBtn.onclick = function(){ cleanup(); bs && bs.hide(); resolve(true); };
      modalEl.addEventListener("hidden.bs.modal", onHidden);
      bs ? bs.show() : resolve(confirm(message||"Bạn chắc chắn?"));
    });
  }

  /* ========= Favorite toggle ========= */
  (function(){
    const btn = document.getElementById("btn-fav");
    if (!btn) return;
    const icon = document.getElementById("fav-icon");
    const theLabel = document.getElementById("fav-text");
    const countEl = document.getElementById("fav-count");
    btn.addEventListener("click", async function(){
      const productId = btn.getAttribute("data-product");
      try{
        const res = await fetch(ctx + "/favorite/toggle", {
          method:"POST",
          headers:{ "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","Accept":"application/json" },
          body:new URLSearchParams({ productId: productId })
        });
        if (res.status === 401){ window.location.href = ctx + "/login"; return; }
        const data = await res.json();
        if (data && data.ok){
          const fav = !!data.fav;
          btn.setAttribute("aria-pressed", String(fav));
          if (icon) icon.textContent = fav ? "❤️" : "🤍";
          if (theLabel) theLabel.textContent = fav ? "Đã thích" : "Thêm Yêu thích";
          if (countEl && typeof data.count === "number") countEl.textContent = data.count;
        }else{
          showToast("Không thể cập nhật Yêu thích.", "danger");
        }
      }catch(e){
        console.error(e); showToast("Lỗi kết nối khi gọi Yêu thích.", "danger");
      }
    });
  })();

  /* ========= Reviews ========= */
  (function(){
    const starPicker = document.getElementById("starPicker");
    const ratingInput = document.getElementById("rvRating");
    const reviewForm = document.getElementById("reviewForm");
    const btnSubmit = document.getElementById("btnSubmitReview");
    const btnDel = document.getElementById("btnDelReview");
    const rvHint = document.getElementById("rvHint");
    const avgEl = document.getElementById("rv-avg");
    const avgStarsEl = document.getElementById("rv-avg-stars");
    const countEl = document.getElementById("rv-count");
    const productId = "<c:out value='${product.productId}'/>";

    function renderAvgStars(avg){
      if (!avgStarsEl) return;
      const filled = Math.round(avg);
      var html = "";
      for (var i=1;i<=5;i++) html += (i <= filled) ? "★" : "☆";
      avgStarsEl.innerHTML = html;
      avgStarsEl.setAttribute("aria-label", avg + " trên 5 sao");
    }
    function updateStatsUI(avg, count){
      if (avgEl)   avgEl.textContent = String(avg);
      if (countEl) countEl.textContent = String(count);
      renderAvgStars(avg);
    }
    function setStars(v){
      if (!starPicker) return;
      document.querySelectorAll("#starPicker .star-btn").forEach(function(el){
        const n = parseInt(el.getAttribute("data-v")||"0",10);
        if (n <= v) el.classList.remove("inactive"); else el.classList.add("inactive");
      });
      if (ratingInput) ratingInput.value = String(v);
    }
    function escHtml(s){ return (s||"").replace(/[&<>"']/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c] || c; }); }
    function starHtml(n){ n = Math.max(0, Math.min(5, parseInt(n||0,10))); var h=''; for(var i=1;i<=5;i++) h += (i<=n?'★':'☆'); return h; }
    function formatVN(dt){
      try{
        var d = (dt instanceof Date) ? dt : new Date(dt);
        var pad = function(x){ return String(x).padStart(2,'0'); };
        return pad(d.getDate()) + "/" + pad(d.getMonth()+1) + "/" + d.getFullYear() + " " + pad(d.getHours()) + ":" + pad(d.getMinutes());
      }catch(_){ return ""; }
    }
    function ensureListContainer(){
      var list = document.getElementById("rv-list");
      if (list) return list;
      var section = (document.getElementById("reviews") && document.getElementById("reviews").parentElement) ? document.getElementById("reviews").parentElement : null;
      list = document.createElement("div");
      list.id = "rv-list";
      list.className = "mt-3";
      if (section) section.appendChild(list);
      return list;
    }
    function renderReviewItem(it, mine){
      var userName = escHtml((it && it.userName) ? it.userName : "Bạn");
      var created  = formatVN((it && it.createdAt) ? it.createdAt : new Date());
      var rating   = parseInt((it && it.rating) ? it.rating : 0, 10);
      var comment  = escHtml((it && (it.commentText || it.comment)) ? (it.commentText || it.comment) : "");
      var imageUrl = (it && it.imageUrl) ? escHtml(it.imageUrl) : "";
      var videoUrl = (it && it.videoUrl) ? escHtml(it.videoUrl) : "";
      var media = "";
      if (imageUrl) media += '<img src="' + imageUrl + '" alt="review image" onerror="this.onerror=null;this.src=\'' + ctx + '/assets/img/placeholder.png\';">';
      if (videoUrl) media += '<video src="' + videoUrl + '" controls></video>';
      return ''
        + '<div class="rv-item ' + (mine ? 'mine' : '') + '">'
        +   '<div class="d-flex align-items-center gap-2">'
        +     '<strong>' + userName + '</strong>'
        +     '<span class="rv-meta">• ' + created + '</span>'
        +   '</div>'
        +   '<div class="stars">' + starHtml(rating) + '</div>'
        +   '<div class="mt-1">' + comment + '</div>'
        +   '<div class="rv-media d-flex gap-2 mt-2">' + media + '</div>'
        + '</div>';
    }

    /* ===== NEW: khoá form review khi quá hạn/không đủ điều kiện ===== */
    function lockReviewForm(reason){
      if (!reviewForm) return;
      // disable inputs
      reviewForm.querySelectorAll("input, textarea, button").forEach(function(el){
        if (el.id === "btnComment") return;
        if (el.id === "btnDelReview") el.classList.add("d-none");
        if (el.type !== "hidden") el.disabled = true;
      });
      if (starPicker){
        starPicker.style.pointerEvents = "none";
        starPicker.classList.add("opacity-75");
      }
      if (rvHint){
        rvHint.classList.remove("d-none");
        rvHint.textContent = reason || "Chỉ cho phép sửa/xoá trong 24 giờ đầu.";
      }
    }

    /* === Luôn tải danh sách review === */
    async function loadReviewsList(force){
      const wrap = ensureListContainer();
      if (!force && wrap.querySelector('.rv-item')) return;
      try{
        const res = await fetch(ctx + "/review/list?productId=" + encodeURIComponent(productId), { headers:{ "Accept":"application/json" }});
        if (!res.ok){ wrap.innerHTML = '<div class="text-muted">Không tải được danh sách đánh giá.</div>'; return; }
        const data = await res.json();
        const arr = Array.isArray(data.items) ? data.items
                  : Array.isArray(data.reviews) ? data.reviews
                  : Array.isArray(data) ? data : [];
        if (!arr.length){
          wrap.innerHTML = '<div class="text-muted">Chưa có dữ liệu đánh giá để hiển thị.</div>';
          return;
        }
        wrap.innerHTML = arr.map(function(it){ return renderReviewItem(it,false); }).join("");
      }catch(e){
        console.error(e);
        const wrap = ensureListContainer();
        wrap.innerHTML = '<div class="text-muted">Không tải được danh sách đánh giá.</div>';
      }
    }

    /* star picker */
    if (starPicker){
      starPicker.addEventListener("click", function(ev){
        const t = ev.target;
        if (!(t instanceof HTMLElement)) return;
        if (!t.classList.contains("star-btn")) return;
        const v = parseInt(t.getAttribute("data-v")||"0",10);
        setStars(v);
      });
    }

    /* submit review */
    if (reviewForm){
      reviewForm.addEventListener("submit", async function(ev){
        ev.preventDefault();

        const fd = new FormData(reviewForm);
        const rating = parseInt((fd.get("rating")||"0").toString(), 10);
        if (!rating || rating < 1 || rating > 5){
          showToast("Vui lòng chọn số sao (1–5).", "danger");
          return;
        }

        // NEW: phát hiện có file để dùng multipart
        const hasImageFiles = Array.from(reviewForm.querySelectorAll('input[name="images"]'))
              .some(function(i){ return i && i.files && i.files.length > 0; });
        const videoInput = reviewForm.querySelector('input[name="video"]');
        const hasVideoFile = !!(videoInput && videoInput.files && videoInput.files.length > 0);
        const useMultipart = hasImageFiles || hasVideoFile;

        try{
          let res, payload;
          if (useMultipart){
            // multipart: giữ nguyên fd + append productId/rating/comment
            fd.set("productId", "<c:out value='${product.productId}'/>");
            fd.set("rating", String(rating));
            // Không set headers Content-Type → browser tự đặt boundary
            res = await fetch(reviewForm.action, {
              method:"POST",
              headers:{ "Accept":"application/json", "X-Requested-With":"XMLHttpRequest" },
              body: fd
            });
          } else {
            // url-encoded như cũ
            res = await fetch(reviewForm.action, {
              method:"POST",
              headers:{ "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8", "Accept":"application/json", "X-Requested-With":"XMLHttpRequest" },
              body: new URLSearchParams({
                productId: "<c:out value='${product.productId}'/>",
                rating: String(rating),
                comment: (fd.get("comment")||"").toString(),
                imageUrl: (fd.get("imageUrl")||"").toString(),
                videoUrl: (fd.get("videoUrl")||"").toString()
              })
            });
          }

          if (res.status === 401){ window.location.href = ctx + "/login"; return; }
          try { payload = await res.clone().json(); } catch(_) {}

          if (res.ok && payload && payload.ok){
            if (payload.stats){
              const avg = typeof payload.stats.avg === "number" ? payload.stats.avg : (avgEl ? parseFloat(avgEl.textContent||"0") : 0);
              const cnt = typeof payload.stats.count === "number" ? payload.stats.count : (countEl ? parseInt(countEl.textContent||"0",10) : 0);
              updateStatsUI(avg, cnt);
            }
            setStars(rating);
            const cmt = reviewForm.querySelector("textarea[name='comment']"); if (cmt) cmt.value = "";
            const img = reviewForm.querySelector("input[name='imageUrl']");  if (img) img.value = "";
            const vid = reviewForm.querySelector("input[name='videoUrl']");  if (vid) vid.value = "";
            // NEW: clear file inputs
            const imgFile = reviewForm.querySelector('input[name="images"]'); if (imgFile) imgFile.value = "";
            const vFile   = reviewForm.querySelector('input[name="video"]');  if (vFile) vFile.value = "";

            showToast("Đã lưu đánh giá.", "success");
            await loadReviewsList(true);
          } else if (res.status === 403) {
            const code = payload && payload.error;
            if (code === "too_late"){
              showToast("Bạn chỉ có thể sửa/xoá trong 24 giờ đầu.", "danger");
              lockReviewForm("Bạn chỉ có thể sửa/xoá trong 24 giờ đầu. Nếu muốn đánh giá tiếp, hãy mua lại sản phẩm.");
            } else if (code === "forbidden"){
              showToast("Chỉ đơn hàng đã giao (DELIVERED) mới được đánh giá.", "danger");
              lockReviewForm("Chỉ đơn hàng đã giao (DELIVERED) mới được đánh giá.");
            } else {
              showToast("Không thể lưu đánh giá.", "danger");
            }
          } else {
            showToast("Không thể lưu đánh giá.", "danger");
          }
        }catch(e){
          console.error(e); showToast("Lỗi kết nối khi gửi đánh giá.", "danger");
        }
      });
    }

    /* delete review */
    if (btnDel){
      btnDel.addEventListener("click", async function(){
        const ok = await confirmModal("Xoá đánh giá của bạn?");
        if (!ok) return;
        try{
          const res = await fetch(ctx + "/review/delete", {
            method:"POST",
            headers:{ "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8", "Accept":"application/json", "X-Requested-With":"XMLHttpRequest" },
            body: new URLSearchParams({ productId: "<c:out value='${product.productId}'/>" })
          });
          if (res.status === 401){ window.location.href = ctx + "/login"; return; }
          let payload = null;
          try { payload = await res.clone().json(); } catch(_) {}
          if (res.ok && payload && payload.ok){
            if (payload.stats){
              const avg = typeof payload.stats.avg === "number" ? payload.stats.avg : 0;
              const cnt = typeof payload.stats.count === "number" ? payload.stats.count : 0;
              updateStatsUI(avg, cnt);
            }
            const mine = document.querySelector("#rv-list .rv-item.mine");
            if (mine && mine.parentElement) mine.parentElement.removeChild(mine);
            setStars(0);
            const cmt = reviewForm && reviewForm.querySelector("textarea[name='comment']"); if (cmt) cmt.value = "";
            const img = reviewForm && reviewForm.querySelector("input[name='imageUrl']"); if (img) img.value = "";
            const vid = reviewForm && reviewForm.querySelector("input[name='videoUrl']"); if (vid) vid.value = "";
            const imgFile = reviewForm && reviewForm.querySelector('input[name="images"]'); if (imgFile) imgFile.value = "";
            const vFile   = reviewForm && reviewForm.querySelector('input[name="video"]');  if (vFile) vFile.value = "";
            btnDel.classList.add("d-none");
            showToast("Đã xoá đánh giá.", "success");
            await loadReviewsList(true);
          } else if (res.status === 403) {
            const code = payload && payload.error;
            if (code === "too_late"){
              showToast("Bạn chỉ có thể xoá trong 24 giờ đầu.", "danger");
              lockReviewForm("Bạn chỉ có thể xoá trong 24 giờ đầu.");
            } else {
              showToast("Không thể xoá đánh giá.", "danger");
            }
          } else {
            showToast("Không thể xoá đánh giá.", "danger");
          }
        }catch(e){
          console.error(e); showToast("Lỗi kết nối khi xoá đánh giá.", "danger");
        }
      });
    }

    /* === Đồng bộ sau reload — lấy stats & đánh giá của tôi === */
    (async function syncStatsAndMineOnLoad(){
      try{
        const sres = await fetch(ctx + "/review/stats?productId=" + encodeURIComponent(productId), { headers:{ "Accept":"application/json" }});
        if (sres.ok){
          const s = await sres.json();
          if (s && s.ok && typeof s.avg !== "undefined" && typeof s.count !== "undefined"){
            updateStatsUI(s.avg, s.count);
          }
        }
      }catch(_){}
      try{
        const mres = await fetch(ctx + "/review/mine?productId=" + encodeURIComponent(productId), { headers:{ "Accept":"application/json" }});
        if (mres.ok){
          const m = await mres.json();
          if (m && m.ok && m.userReview && reviewForm){
            const me = m.userReview;
            setStars(parseInt(me.rating||0,10));
            const cmt = reviewForm.querySelector("textarea[name='comment']"); if (cmt) cmt.value = (me.commentText||"");
            const img = reviewForm.querySelector("input[name='imageUrl']");  if (img) img.value = (me.imageUrl||"");
            const vid = reviewForm.querySelector("input[name='videoUrl']");  if (vid) vid.value = (me.videoUrl||"");
            if (btnDel) btnDel.classList.remove("d-none");

            // NEW: nếu quá 24h kể từ createdAt → khoá form
            try{
              if (me.createdAt){
                const created = new Date(me.createdAt.replace(' ', 'T'));
                const now = new Date();
                const diffHrs = Math.floor((now - created) / 36e5);
                if (diffHrs >= 24){
                  lockReviewForm("Bạn chỉ có thể sửa/xoá trong 24 giờ đầu. Nếu muốn đánh giá tiếp, hãy mua lại sản phẩm.");
                }
              }
            }catch(_){}
          }
        }
      }catch(_){}
    })();

    // Luôn refresh danh sách từ API để tránh trùng
    loadReviewsList(true);

  })();

  /* ========= Comments ========= */
  (function(){
    const list = document.getElementById("cmList");
    const rootForm = document.getElementById("commentForm");
    if (!list) return;
    const productId = list.getAttribute("data-productid");

    async function loadThreadAndRender(){
      try{
        const res = await fetch(ctx + "/comment/thread?productId=" + encodeURIComponent(productId), { headers:{ "Accept":"application/json" }});
        if (!res.ok) throw new Error("HTTP " + res.status);
        const data = await res.json();
        const items = (data && Array.isArray(data.items)) ? data.items : [];
        renderThread(items);
      }catch(e){
        console.error(e);
        list.innerHTML = '<div class="text-danger">Không tải được bình luận.</div>';
      }
    }

    function escHtml(s){ return (s||"").replace(/[&<>\"']/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]}); }

    function renderThread(items){
      if (!items.length){ list.innerHTML = '<div class="text-muted">Chưa có bình luận nào.</div>'; return; }
      var html = items.map(function(it){
        var cid = it.commentId;
        var indent = (it.depth && it.depth > 0) ? ' cm-indent' : '';
        var h = '';
        h += '<div class="cm-item'+indent+'" data-cid="'+cid+'">';
        h += '  <div class="d-flex align-items-center gap-2">';
        h += '    <strong>'+escHtml(it.userName)+'</strong>';
        h += '    <span class="text-muted small">'+escHtml(it.createdAt||"")+'</span>';
        h += '  </div>';
        h += '  <div class="mt-1">'+escHtml(it.content)+'</div>';
        h += '  <div class="cm-actions">';
        h += '    <button type="button" class="btn btn-link btn-cm-reply" data-cid="'+cid+'">Trả lời</button>';
        h += '    <button type="button" class="btn btn-link text-danger btn-cm-del" data-cid="'+cid+'">Xóa</button>';
        h += '  </div>';
        h += '  <div class="cm-reply-form d-none" id="rf-'+cid+'">';
        h += '    <form class="replyForm" data-cid="'+cid+'">';
        h += '      <input type="hidden" name="productId" value="'+productId+'"/>';
        h += '      <textarea class="form-control" name="content" rows="2" maxlength="500" placeholder="Phản hồi..."></textarea>';
        h += '      <div class="mt-2 d-flex gap-2">';
        h += '        <button type="submit" class="btn btn-sm btn-primary">Gửi</button>';
        h += '        <button type="button" class="btn btn-sm btn-outline-secondary btn-cancel-reply" data-cid="'+cid+'">Hủy</button>';
        h += '      </div>';
        h += '    </form>';
        h += '  </div>';
        h += '</div>';
        return h;
      }).join('');
      list.innerHTML = html;
    }

    loadThreadAndRender();

    if (rootForm){
      rootForm.addEventListener("submit", async function(ev){
        ev.preventDefault();
        var fd = new FormData(rootForm);
        var content = (fd.get("content")||"").toString().trim();
        if (!content){ showToast("Vui lòng nhập nội dung bình luận.", "danger"); return; }
        try{
          const res = await fetch(ctx + "/comment/add", {
            method:"POST",
            headers:{ "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","Accept":"application/json" },
            body:new URLSearchParams({ productId: productId, content: content })
          });
          if (res.status === 401){ window.location.href = ctx + "/login"; return; }
          if (!res.ok){ showToast("Đăng bình luận thất bại.", "danger"); return; }
          rootForm.reset();
          showToast("Đã đăng bình luận.", "success");
          await loadThreadAndRender();
        }catch(e){
          console.error(e); showToast("Lỗi kết nối khi đăng bình luận.", "danger");
        }
      });
    }

    document.getElementById("cmList").addEventListener("click", async function(ev){
      const t = ev.target;
      if (!(t instanceof HTMLElement)) return;

      if (t.classList.contains("btn-cm-reply")){
        const cid = t.getAttribute("data-cid");
        const frm = document.getElementById("rf-" + cid);
        if (frm) frm.classList.toggle("d-none");
        return;
      }
      if (t.classList.contains("btn-cancel-reply")){
        const cid = t.getAttribute("data-cid");
        const frm = document.getElementById("rf-" + cid);
        if (frm) frm.classList.add("d-none");
        return;
      }
      if (t.classList.contains("btn-cm-del")) {
        const cid = t.getAttribute("data-cid");
        if (!cid) return;

        const ok = await confirmModal("Xóa bình luận này?");
        if (!ok) return;

        try {
          const res = await fetch(ctx + "/comment/delete", {
            method: "POST",
            headers: {
              "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
              "Accept": "application/json",
              "X-Requested-With": "XMLHttpRequest"
            },
            body: new URLSearchParams({ commentId: cid, productId: productId })
          });

          if (res.status === 401) { window.location.href = ctx + "/login"; return; }

          let payload = null;
          try { payload = await res.clone().json(); } catch (_) {}

          if (res.ok && payload && payload.ok !== false) {
            const row = t.closest(".cm-item");
            if (row) row.remove();
            showToast("Đã xoá bình luận.", "success");
          } else {
            const err = payload && payload.error;
            if (res.status === 403 && (err === "too_late" || err === "forbidden")) {
              showToast("Bạn chỉ có thể xoá bình luận trong 24 giờ đầu (và khi bình luận chưa có phản hồi).", "danger");
            } else {
              showToast("Không thể xoá bình luận (HTTP " + res.status + ").", "danger");
            }
          }
        } catch (e) {
          console.error(e);
          showToast("Lỗi kết nối khi xoá bình luận.", "danger");
        }
      }
    });

    document.getElementById("cmList").addEventListener("submit", async function(ev){
      const form = ev.target;
      if (!(form instanceof HTMLFormElement)) return;
      if (!form.classList.contains("replyForm")) return;
      ev.preventDefault();
      const cid = form.getAttribute("data-cid");
      const fd = new FormData(form);
      const content = (fd.get("content")||"").toString().trim();
      if (!content){ showToast("Vui lòng nhập nội dung trả lời.", "danger"); return; }
      try{
        const res = await fetch(ctx + "/comment/reply", {
          method:"POST",
          headers:{ "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","Accept":"application/json" },
          body:new URLSearchParams({ parentCommentId: cid||"", productId: productId, content: content })
        });
        if (res.status === 401){ window.location.href = ctx + "/login"; return; }
        if (res.ok){
          showToast("Đã gửi trả lời.", "success");
          await loadThreadAndRender();
        }else if (res.status === 404){
          showToast("Server chưa có /comment/reply.", "danger");
        }else{
          showToast("Trả lời thất bại (HTTP " + res.status + ").", "danger");
        }
      }catch(e){
        console.error(e); showToast("Lỗi kết nối khi gửi trả lời.", "danger");
      }
    });
  })();

  /* ========= Thumbs ảnh ========= */
  (function(){
    const main = document.getElementById("mainImage");
    if (!main) return;
    document.querySelectorAll(".thumb").forEach(function(th){
      th.addEventListener("click", function(){
        document.querySelectorAll(".thumb").forEach(function(x){ x.classList.remove("border-primary"); });
        th.classList.add("border-primary");
        const src = th.getAttribute("data-src") || th.getAttribute("src");
        if (src) main.src = src;
      });
    });
  })();
});
</script>
