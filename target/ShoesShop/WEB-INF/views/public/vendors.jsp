<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:set var="currPage" value="${empty page_number ? 1 : page_number}" />
<c:set var="currSize" value="${empty page_size ? 12 : page_size}" />
<c:set var="totalPages" value="${empty total_pages ? 1 : total_pages}" />

<style>
/* CSS MỚI cho Vendor Card */
.vendor-card {
	border: none; /* Xóa border mặc định của card */
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); /* Thêm đổ bóng nhẹ */
	transition: transform 0.3s, box-shadow 0.3s;
}

.vendor-card:hover {
	transform: translateY(-4px); /* Hiệu ứng nổi nhẹ khi di chuột */
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
}

.vendor-card .cover-container {
	height: 120px; /* Chiều cao cố định cho phần cover */
	position: relative;
	border-radius: 0.375rem 0.375rem 0 0; /* Bo góc trên giống với card */
	overflow: hidden;
}

.vendor-card .cover {
	width: 100%;
	height: 100%;
	object-fit: cover;
	opacity: 0.8; /* Làm mờ ảnh cover một chút */
}

.vendor-card .logo {
	width: 72px;
	height: 72px;
	object-fit: cover;
	border: 3px solid #fff;
	position: absolute;
	left: 1rem;
	bottom: -36px; /* Đặt logo lấn xuống dưới cover */
	border-radius: 50%;
	background: #fff;
	z-index: 10;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.vendor-card .card-body {
	padding-top: 2.5rem; /* Tăng padding để nhường chỗ cho logo */
}

.line-clamp-2 {
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}
</style>

<h1 class="h5 mb-3">Danh bạ Vendor</h1>

<form class="row g-2 mb-3" method="get" action="${ctx}/vendors">
	<div class="col-12 col-md-6">
		<input class="form-control" name="q" value="${q}"
			placeholder="Tìm theo tên shop...">
	</div>
	<div class="col-12 col-md-auto d-flex gap-2">
		<select class="form-select" name="size">
			<option value="12" ${currSize==12?'selected':''}>12 / trang</option>
			<option value="24" ${currSize==24?'selected':''}>24 / trang</option>
			<option value="36" ${currSize==36?'selected':''}>36 / trang</option>
		</select>
		<button class="btn btn-primary">Tìm</button>
		<a class="btn btn-outline-secondary" href="${ctx}/vendors">Xóa lọc</a>
	</div>
</form>

<c:choose>
	<c:when test="${not empty shops}">
		<div
			class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-3">
			<c:forEach var="s" items="${shops}">
				<c:set var="coverRaw" value="${empty s.coverUrl ? '' : s.coverUrl}" />
				<c:set var="logoRaw" value="${empty s.logoUrl  ? '' : s.logoUrl }" />

				<c:set var="cover"
					value="${fn:startsWith(coverRaw,'http') ? coverRaw : (fn:startsWith(coverRaw,'/') ? coverRaw : (ctx.concat('/assets/img/').concat(coverRaw)))}" />
				<c:set var="logo"
					value="${fn:startsWith(logoRaw,'http') ? logoRaw : (fn:startsWith(logoRaw,'/') ? (ctx.concat(logoRaw)) : (ctx.concat('/assets/img/').concat(logoRaw)))}" />

				<div class="col">
					<div class="card h-100 vendor-card">
						<div class="cover-container">
							<img class="cover"
								src="${empty cover ? (ctx.concat('/assets/img/placeholder.png')) : cover}"
								alt="<c:out value='${s.shopName}'/> Cover"
								onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">

							<a class="logo"
								href="<c:url value='/vendor'><c:param name='shopId' value='${s.shopId}'/></c:url>">
								<img class="w-100 h-100 rounded-circle"
								src="${empty logo ? (ctx.concat('/assets/img/placeholder.png')) : logo}"
								alt="<c:out value='${s.shopName}'/> Logo"
								onerror="this.onerror=null;this.src='${ctx}/assets/img/placeholder.png';">
							</a>

						</div>

						<div class="card-body">
							<div class="mb-2">
								<a class="text-decoration-none text-dark"
									href="<c:url value='/vendor'><c:param name='shopId' value='${s.shopId}'/></c:url>">
									<div class="fw-bold fs-5 text-truncate" title="${s.shopName}">
										<c:out value="${s.shopName}" />
									</div>
								</a>
								<div class="text-muted small line-clamp-2"
									style="min-height: 2.8em;">
									<c:out
										value="${empty s.description ? 'Chưa có mô tả.' : s.description}" />
								</div>
							</div>

							<div class="mt-2 d-flex justify-content-end">
								<a class="btn btn-sm btn-outline-primary"
									href="<c:url value='/products'><c:param name='shopId' value='${s.shopId}'/></c:url>">
									Chi tiết &raquo; </a>
							</div>

						</div>
					</div>
				</div>
			</c:forEach>
		</div>

		<c:if test="${totalPages > 1}">
			<nav class="mt-3">
				<ul class="pagination justify-content-center">
					<li class="page-item ${currPage>1 ? '' : 'disabled'}"><a
						class="page-link"
						href="<c:url value='/vendors'>
                 <c:param name='q' value='${q}'/>
                 <c:param name='size' value='${currSize}'/>
                 <c:param name='page' value='${currPage-1}'/>
               </c:url>">«</a>
					</li>

					<c:forEach var="i" begin="1" end="${totalPages}">
						<li class="page-item ${i==currPage?'active':''}"><a
							class="page-link"
							href="<c:url value='/vendors'>
                   <c:param name='q' value='${q}'/>
                   <c:param name='size' value='${currSize}'/>
                   <c:param name='page' value='${i}'/>
                 </c:url>">${i}</a>
						</li>
					</c:forEach>

					<li class="page-item ${currPage<totalPages ? '' : 'disabled'}">
						<a class="page-link"
						href="<c:url value='/vendors'>
                 <c:param name='q' value='${q}'/>
                 <c:param name='size' value='${currSize}'/>
                 <c:param name='page' value='${currPage+1}'/>
               </c:url>">»</a>
					</li>
				</ul>
			</nav>
		</c:if>
	</c:when>

	<c:otherwise>
		<div class="text-center text-muted py-5">Chưa có shop để hiển
			thị.</div>
	</c:otherwise>
</c:choose>