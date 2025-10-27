<!-- filepath: src/main/webapp/WEB-INF/views/vendor/shop-profile.jsp -->
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="container py-4">
	<h3 class="mb-3">Hồ sơ cửa hàng</h3>

	<!-- /WEB-INF/views/products/detail.jsp -->
	<c:if test="${not empty shop and not empty shop.shopId}">
		<a href="${ctx}/chat?shopId=${shop.shopId}"
			class="btn btn-outline-primary"> 💬 Chat với cửa hàng </a>
	</c:if>




	<form action="${ctx}/vendor/shop" method="post"
		enctype="multipart/form-data" class="card p-3 shadow-sm">
		<div class="mb-3">
			<label class="form-label">Tên cửa hàng</label> <input type="text"
				class="form-control" name="shopName" value="${shop.shopName}"
				required />
		</div>

		<div class="mb-3">
			<label class="form-label">Mô tả</label>
			<textarea class="form-control" name="description" rows="3">${shop.description}</textarea>
		</div>

		<div class="row">
			<!-- Logo -->
			<div class="col-md-6 mb-3">
				<label class="form-label">Logo (Avatar)</label> <input type="file"
					class="form-control" name="logo" accept="image/*" />
				<div class="mt-2 d-flex align-items-center gap-3">
					<c:choose>
						<c:when test="${not empty shop.logoUrl}">
							<img src="${shop.logoUrl}"
								class="rounded-circle border shadow-sm"
								style="width: 96px; height: 96px; object-fit: cover;">
						</c:when>
						<c:otherwise>
							<img src="https://via.placeholder.com/96?text=Logo"
								class="rounded-circle border shadow-sm"
								style="width: 96px; height: 96px; object-fit: cover;">
						</c:otherwise>
					</c:choose>
					<small class="text-muted">Chọn ảnh mới để thay logo (tuỳ
						chọn).</small>
				</div>
			</div>

			<!-- Cover -->
			<div class="col-md-6 mb-3">
				<label class="form-label">Ảnh bìa (Cover)</label> <input type="file"
					class="form-control" name="cover" accept="image/*" />
				<div class="mt-2">
					<c:choose>
						<c:when test="${not empty shop.coverUrl}">
							<img src="${shop.coverUrl}" class="img-fluid rounded border"
								style="width: 100%; max-height: 220px; object-fit: cover;">
						</c:when>
						<c:otherwise>
							<img src="https://via.placeholder.com/800x220?text=Cover"
								class="img-fluid rounded border"
								style="width: 100%; max-height: 220px; object-fit: cover;">
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		</div>

		<div class="d-flex gap-2">
			<button type="submit" class="btn btn-primary">Lưu thay đổi</button>
			<a href="${ctx}/vendor/dashboard" class="btn btn-secondary">Hủy</a>
		</div>
	</form>
</div>
