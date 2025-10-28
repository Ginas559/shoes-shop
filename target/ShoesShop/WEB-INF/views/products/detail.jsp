<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<fmt:setLocale value="vi_VN" scope="page" />

<style>
.product-detail .main-img {
	width: 100%;
	max-width: 640px; /* desktop cap */
	aspect-ratio: 1/1; /* luôn vuông */
	object-fit: cover; /* cắt gọn, không méo */
}

.product-detail .thumb {
	width: 96px;
	height: 96px;
	object-fit: cover;
	cursor: pointer;
}

@media ( max-width : 576px) {
	.product-detail .main-img {
		max-width: 100%;
	}
	.product-detail .thumb {
		width: 72px;
		height: 72px;
	}
}
/* Card hover nhẹ cho related & viewed */
.card:hover {
	transform: translateY(-2px);
	transition: transform .15s ease;
}
/* FAVORITE button tweak */
.fav-wrap {
	display: flex;
	align-items: center;
	gap: .5rem;
	margin-top: .5rem;
}

.fav-wrap .btn {
	line-height: 1.1;
}

/* ===== Reviews / Comments (Từ 7786f02...) ===== */
.stars {
	color: #f59e0b;
} /* amber */
.star-btn {
	cursor: pointer;
	font-size: 1.25rem;
	line-height: 1;
}

.star-btn.inactive {
	color: #ddd;
}

.rv-item {
	border-bottom: 1px solid #eee;
	padding: 12px 0;
}

.rv-meta {
	font-size: .9rem;
	color: #666;
}

.rv-media img, .rv-media video {
	max-width: 160px;
	max-height: 160px;
	border-radius: 8px;
	object-fit: cover;
}

.cm-item {
	border-bottom: 1px dashed #eee;
	padding: 10px 0;
}

/* >>> added for threaded comments >>> */
.cm-row {
	padding: 10px 0;
	border-bottom: 1px dashed #eee;
}

.cm-head {
	display: flex;
	align-items: center;
	gap: .5rem;
}

.cm-meta {
	color: #6c757d;
	font-size: .875rem;
}

.cm-actions {
	display: flex;
	gap: .5rem;
	margin-top: .25rem;
}

.cm-actions .btn-link {
	padding: 0;
	font-size: .875rem;
	text-decoration: none;
}

.cm-indent {
	border-left: 2px solid #f1f1f1;
	padding-left: 10px;
}

.cm-reply-form {
	margin-top: .5rem;
}

.cm-reply-form textarea {
	resize: vertical;
}
/* <<< end added */
</style>

<c:choose>
	<c:when test="${not empty product}">
		<div class="row g-3 product-detail">

			<div class="col-12 col-md-6">
				<%-- === Resolve main image from images[0] (Thống nhất logic resolve path & fix lỗi assset) === --%>
				<c:set var="mainRaw" value="${empty images ? '' : images[0]}" />
				<c:set var="mainFixed"
					value="${fn:replace(mainRaw, '/assset/', '/assets/')}" />
				<c:choose>
					<c:when
						test="${fn:startsWith(mainFixed,'http://') or fn:startsWith(mainFixed,'https://')}">
						<c:set var="resolvedMain" value="${mainFixed}" />
					</c:when>
					<c:when test="${fn:startsWith(mainFixed,'/assets/')}">
						<c:set var="resolvedMain" value="${ctx.concat(mainFixed)}" />
					</c:when>
					<c:when test="${fn:startsWith(mainFixed,'/')}">
						<c:set var="resolvedMain" value="${mainFixed}" />
					</c:when>
					<c:otherwise>
						<c:set var="resolvedMain"
							value="${ctx.concat('/assets/img/products/').concat(mainFixed)}" />
					</c:otherwise>
				</c:choose>

				<img id="mainImage"
					class="img-fluid rounded border d-block mx-auto main-img"
					src="${empty resolvedMain ? (ctx.concat('/assets/img/placeholder.png')) : resolvedMain}"
					alt="<c:out value='${product.productName}'/>"
					onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">

				<c:if test="${not empty images}">
					<div class="d-flex gap-2 mt-2 flex-wrap">
						<c:forEach var="img" items="${images}" varStatus="st">
							<%-- Resolve each thumb --%>
							<c:set var="tRaw" value="${empty img ? '' : img}" />
							<c:set var="tFixed"
								value="${fn:replace(tRaw, '/assset/', '/assets/')}" />
							<c:choose>
								<c:when
									test="${fn:startsWith(tFixed,'http://') or fn:startsWith(tFixed,'https://')}">
									<c:set var="resolvedThumb" value="${tFixed}" />
								</c:when>
								<c:when test="${fn:startsWith(tFixed,'/assets/')}">
									<c:set var="resolvedThumb" value="${ctx.concat(tFixed)}" />
								</c:when>
								<c:when test="${fn:startsWith(tFixed,'/')}">
									<c:set var="resolvedThumb" value="${tFixed}" />
								</c:when>
								<c:otherwise>
									<c:set var="resolvedThumb"
										value="${ctx.concat('/assets/img/products/').concat(tFixed)}" />
								</c:otherwise>
							</c:choose>

							<img
								src="${empty resolvedThumb ? (ctx.concat('/assets/img/placeholder.png')) : resolvedThumb}"
								data-src="${empty resolvedThumb ? (ctx.concat('/assets/img/placeholder.png')) : resolvedThumb}"
								class="rounded ${st.first ? 'border border-primary' : 'border'} thumb"
								onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
						</c:forEach>
					</div>
				</c:if>
			</div>

			<div class="col-12 col-md-6">
				<h1 class="h5">
					<c:out value="${product.productName}" />
				</h1>

				<c:if test="${not empty product.shop}">
					<div class="d-flex align-items-center gap-2 mb-2">
						<c:if test="${not empty product.shop.logoUrl}">
							<img src="${ctx}${product.shop.logoUrl}"
								alt="<c:out value='${product.shop.shopName}'/>"
								class="rounded border"
								style="width: 172px; height: 172px; object-fit: cover"
								onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
						</c:if>

						<div>
							<div class="small text-muted">Của shop</div>
							<a
								class="badge bg-secondary-subtle border text-secondary text-decoration-none"
								href="<c:url value='/products'>
                          <c:param name='shopId' value='${product.shop.shopId}'/>
                       </c:url>">
								<c:out value="${product.shop.shopName}" />
							</a> <a href="${ctx}/chat/public?shopId=${product.shop.shopId}"
								class="btn btn-outline-primary"> 💬 Chat công khai với cửa
								hàng </a>

						</div>
					</div>
				</c:if>

				<div class="text-muted mb-2">
					<c:out
						value="${product.category != null ? product.category.categoryName : ''}" />
				</div>

				<%-- ======= GIÁ CHÍNH: format VNĐ + rút gọn k/triệu ======= --%>
				<c:set var="priceMain"
					value="${not empty product.discountPrice ? product.discountPrice : product.price}" />
				<div class="fs-4 fw-bold">
					<fmt:formatNumber value="${priceMain}" type="number"
						maxFractionDigits="0" />
					₫ <span class="text-muted small"> ( <c:choose>
							<c:when test="${priceMain >= 1000000}">
								<fmt:formatNumber value="${priceMain / 1000000.0}"
									maxFractionDigits="1" /> triệu
              </c:when>
							<c:otherwise>
								<fmt:formatNumber value="${priceMain / 1000.0}"
									maxFractionDigits="0" />k
              </c:otherwise>
						</c:choose> )
					</span>
				</div>

				<c:set var="isFavSafe" value="${isFav == true}" />
				<c:set var="favCountSafe"
					value="${empty favoriteCount ? 0 : favoriteCount}" />
				<div class="fav-wrap">
					<button id="btn-fav" type="button"
						class="btn btn-outline-danger btn-sm"
						data-product="${product.productId}" aria-pressed="${isFavSafe}">
						<span id="fav-icon">${isFavSafe ? '❤️' : '🤍'}</span> <span
							id="fav-text">${isFavSafe ? 'Đã thích' : 'Thêm Yêu thích'}</span>
					</button>
					<small class="text-muted">(<span id="fav-count">${favCountSafe}</span>)
					</small>
				</div>

				<p class="mt-3">
					<c:out value="${product.description}" />
				</p>

				<div class="mt-3">
					<form id="addToCartForm" method="post" action="${ctx}/cart/add"
						class="d-flex align-items-center gap-2">
						<input type="hidden" name="productId" value="${product.productId}" />
						<div class="input-group" style="width: 220px;">
							<input type="number" name="quantity" value="1" min="1"
								class="form-control" />
							<button type="submit" class="btn btn-primary">Thêm vào
								giỏ</button>
						</div>
					</form>

					<small class="text-muted d-block mt-2"> Xem giỏ tại <a
						class="text-decoration-none" href="${ctx}/cart">${ctx}/cart</a>.
					</small>
				</div>

				<div class="mt-3 d-flex gap-2">
					<a class="btn btn-outline-secondary" href="${ctx}/products">←
						Quay lại danh sách</a> <a class="btn btn-primary"
						href="${ctx}/product/${product.productId}">Tải lại</a>
				</div>
			</div>
		</div>

		<c:if test="${not empty relatedProducts}">
			<h2 class="h6 mt-4 mb-2">Sản phẩm liên quan</h2>
			<div class="row row-cols-2 row-cols-md-4 g-3">
				<c:forEach var="rp" items="${relatedProducts}">
					<%-- Resolve related cover --%>
					<c:set var="rpRaw" value="${empty rp.coverUrl ? '' : rp.coverUrl}" />
					<c:set var="rpFixed"
						value="${fn:replace(rpRaw, '/assset/', '/assets/')}" />
					<c:choose>
						<c:when
							test="${fn:startsWith(rpFixed,'http://') or fn:startsWith(rpFixed,'https://')}">
							<c:set var="rpCover" value="${rpFixed}" />
						</c:when>
						<c:when test="${fn:startsWith(rpFixed,'/assets/')}">
							<c:set var="rpCover" value="${ctx.concat(rpFixed)}" />
						</c:when>
						<c:when test="${fn:startsWith(rpFixed,'/')}">
							<c:set var="rpCover" value="${rpFixed}" />
						</c:when>
						<c:otherwise>
							<c:set var="rpCover"
								value="${ctx.concat('/assets/img/products/').concat(rpFixed)}" />
						</c:otherwise>
					</c:choose>

					<div class="col">
						<div class="card h-100">
							<a href="${ctx}/product/${rp.id}"> <img class="card-img-top"
								style="aspect-ratio: 1/1; object-fit: cover"
								src="${empty rpCover ? (ctx.concat('/assets/img/placeholder.png')) : rpCover}"
								alt="<c:out value='${rp.productName}'/>"
								onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
							</a>
							<div class="card-body p-2">
								<div class="small text-muted text-truncate">
									<c:out
										value="${rp.category != null ? rp.category.categoryName : ''}" />
								</div>
								<div class="fw-semibold text-truncate" title="${rp.productName}">
									<c:out value="${rp.productName}" />
								</div>

								<%-- Giá liên quan --%>
								<c:set var="rpMain"
									value="${not empty rp.discountPrice ? rp.discountPrice : rp.price}" />
								<div class="fw-bold">
									<fmt:formatNumber value="${rpMain}" type="number"
										maxFractionDigits="0" />
									₫
								</div>
							</div>
						</div>
					</div>
				</c:forEach>
			</div>
		</c:if>

		<div class="mt-4">
			<div class="d-flex align-items-center justify-content-between mb-2">
				<h2 class="h4 m-0 fw-semibold">Bạn đã xem gần đây</h2>
				<a class="btn btn-sm btn-outline-secondary" href="${ctx}/recent">Xem
					tất cả</a>
			</div>

			<c:choose>
				<c:when test="${not empty recentViewed}">
					<div class="row row-cols-2 row-cols-md-6 g-3">
						<c:forEach var="rv" items="${recentViewed}">
							<%-- Resolve cover --%>
							<c:set var="rvRaw"
								value="${empty rv.coverUrl ? '' : rv.coverUrl}" />
							<c:set var="rvFixed"
								value="${fn:replace(rvRaw, '/assset/', '/assets/')}" />
							<c:choose>
								<c:when
									test="${fn:startsWith(rvFixed,'http://') or fn:startsWith(rvFixed,'https://')}">
									<c:set var="rvCover" value="${rvFixed}" />
								</c:when>
								<c:when test="${fn:startsWith(rvFixed,'/assets/')}">
									<c:set var="rvCover" value="${ctx.concat(rvFixed)}" />
								</c:when>
								<c:when test="${fn:startsWith(rvFixed,'/')}">
									<c:set var="rvCover" value="${rvFixed}" />
								</c:when>
								<c:otherwise>
									<c:set var="rvCover"
										value="${ctx.concat('/assets/img/products/').concat(rvFixed)}" />
								</c:otherwise>
							</c:choose>

							<div class="col">
								<div class="card h-100">
									<a href="${ctx}/product/${rv.productId}"> <img
										class="card-img-top"
										style="aspect-ratio: 1/1; object-fit: cover"
										src="${empty rvCover ? (ctx.concat('/assets/img/placeholder.png')) : rvCover}"
										alt="<c:out value='${rv.productName}'/>"
										onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
									</a>
									<div class="card-body p-2">
										<div class="fw-semibold text-truncate"
											title="${rv.productName}">
											<c:out value="${rv.productName}" />
										</div>

										<%-- Giá viewed: hiển thị VNĐ gọn --%>
										<c:set var="rvMain"
											value="${not empty rv.discountPrice ? rv.discountPrice : rv.price}" />
										<div class="fw-bold small">
											<fmt:formatNumber value="${rvMain}" type="number"
												maxFractionDigits="0" />
											₫
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
							<div
								class="rounded bg-white border d-flex align-items-center justify-content-center"
								style="width: 56px; height: 56px;">
								<span class="text-muted">🕘</span>
							</div>
							<div>
								<div class="fw-semibold">Chưa có lịch sử đã xem</div>
								<div class="text-muted small">Hãy duyệt vài sản phẩm —
									chúng sẽ xuất hiện ở đây để bạn mở lại nhanh.</div>
							</div>
						</div>
					</div>
				</c:otherwise>
			</c:choose>
		</div>

		<div class="mt-5">
			<h2 class="h5 mb-3">Đánh giá sản phẩm</h2>

			<c:set var="avgStar"
				value="${empty reviewStats ? 0 : reviewStats.avg}" />
			<c:set var="countStar"
				value="${empty reviewStats ? 0 : reviewStats.count}" />
			<div class="d-flex align-items-center gap-2 mb-3">
				<div class="fs-4 fw-bold">${avgStar}</div>
				<div class="stars" aria-label="${avgStar} trên 5 sao">
					<c:forEach var="i" begin="1" end="5">
						<span>${i <= (avgStar+0.5) ? '★' : '☆'}</span>
					</c:forEach>
				</div>
				<div class="text-muted">(${countStar} đánh giá)</div>
			</div>

			<c:if test="${canReview == true}">
				<div class="border rounded p-3 mb-3">
					<form id="reviewForm" method="post" action="${ctx}/review/save">
						<input type="hidden" name="productId" value="${product.productId}" />

						<div class="mb-2">
							<label class="form-label">Chấm điểm</label>
							<div id="starPicker" class="stars">
								<c:set var="myRating"
									value="${empty userReview ? 0 : userReview.rating}" />
								<c:forEach var="i" begin="1" end="5">
									<span class="star-btn ${i <= myRating ? '' : 'inactive'}"
										data-v="${i}">★</span>
								</c:forEach>
							</div>
							<input type="hidden" name="rating" id="rvRating"
								value="${myRating}" />
						</div>

						<div class="mb-2">
							<label class="form-label">Nội dung</label>
							<textarea class="form-control" name="comment" rows="3"
								placeholder="Cảm nhận của bạn...">${empty userReview ? '' : userReview.commentText}</textarea>
						</div>

						<div class="row g-2">
							<div class="col-12 col-md-6">
								<label class="form-label">Ảnh (URL)</label> <input
									class="form-control" type="url" name="imageUrl"
									value="${empty userReview ? '' : userReview.imageUrl}"
									placeholder="https://... (Cloudinary được hỗ trợ)" />
							</div>
							<div class="col-12 col-md-6">
								<label class="form-label">Video (URL)</label> <input
									class="form-control" type="url" name="videoUrl"
									value="${empty userReview ? '' : userReview.videoUrl}"
									placeholder="https://..." />
							</div>
						</div>

						<div class="mt-3 d-flex gap-2">
							<button class="btn btn-primary" type="submit">${empty userReview ? 'Gửi đánh giá' : 'Cập nhật đánh giá'}</button>
							<c:if test="${not empty userReview}">
								<button class="btn btn-outline-danger" type="button"
									id="btnDelReview">Xoá đánh giá</button>
							</c:if>
						</div>
					</form>
				</div>
			</c:if>
			<c:if test="${canReview != true}">
				<div class="alert alert-info">Bạn cần đăng nhập và/hoặc đã mua
					hàng để đánh giá.</div>
			</c:if>

			<c:if test="${not empty reviews}">
				<div class="mt-3">
					<c:forEach var="rv" items="${reviews}">
						<div class="rv-item">
							<div class="d-flex align-items-center gap-2">
								<strong><c:out value="${rv.userName}" /></strong> <span
									class="rv-meta">• <fmt:formatDate
										value="${rv.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
							</div>
							<div class="stars">
								<c:forEach var="i" begin="1" end="5">
									<span>${i <= rv.rating ? '★' : '☆'}</span>
								</c:forEach>
							</div>
							<div class="mt-1">
								<c:out value="${rv.commentText}" />
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
			</c:if>
			<c:if test="${empty reviews && countStar == 0}">
				<div class="text-muted">Chưa có đánh giá nào.</div>
			</c:if>
		</div>

		<div class="mt-5">
			<h2 class="h6 mb-3">Bình luận</h2>

			<div class="border rounded p-3 mb-3">
				<form id="commentForm" method="post" action="${ctx}/comment/add">
					<input type="hidden" name="productId" value="${product.productId}" />
					<div class="mb-2">
						<textarea class="form-control" name="content" rows="2"
							maxlength="500" placeholder="Viết bình luận..."></textarea>
					</div>
					<button class="btn btn-outline-primary btn-sm" type="submit"
						id="btnComment">Gửi bình luận</button>
					<small id="cmHint" class="text-muted ms-2 d-none"></small>
				</form>
			</div>

			<c:if test="${not empty comments}">
				<div id="cmList" data-productid="${product.productId}">
					<c:forEach var="cm" items="${comments}">
						<div class="cm-item">
							<div class="d-flex align-items-center gap-2">
								<strong><c:out value="${cm.userName}" /></strong> <span
									class="text-muted small"><fmt:formatDate
										value="${cm.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
							</div>
							<div class="mt-1">
								<c:out value="${cm.content}" />
							</div>
						</div>
					</c:forEach>
				</div>
			</c:if>
			<c:if test="${empty comments}">
				<div class="text-muted">Chưa có bình luận nào.</div>
			</c:if>
		</div>

	</c:when>
	<c:otherwise>
		<div class="text-center text-muted py-5">Không tìm thấy sản
			phẩm.</div>
	</c:otherwise>
</c:choose>

<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1080">
	<div id="cartToast"
		class="toast align-items-center text-bg-success border-0"
		role="status" aria-live="polite" aria-atomic="true"
		data-bs-autohide="true" data-bs-delay="2500">
		<div class="d-flex">
			<div class="toast-body">Đã thêm sản phẩm vào giỏ hàng!</div>
			<button type="button" class="btn-close btn-close-white me-2 m-auto"
				data-bs-dismiss="toast" aria-label="Close"></button>
		</div>
	</div>
</div>