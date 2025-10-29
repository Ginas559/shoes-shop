<%-- filepath: src/main/webapp/WEB-INF/views/vendor/products.jsp --%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:choose>
	<c:when test="${empty p}">
		<c:set var="actionPath" value="/vendor/products/add" />
	</c:when>
	<c:otherwise>
		<c:set var="actionPath" value="/vendor/products/update" />
	</c:otherwise>
</c:choose>

<main class="container py-4">
	<div class="d-flex align-items-center justify-content-between mb-3">
		<h2 class="mb-0">Quản lý sản phẩm</h2>
		<c:if test="${not empty shop}">
			<span class="text-muted">Shop: <strong>${shop.shopName}</strong></span>
		</c:if>
	</div>

	<c:if test="${not empty errors}">
		<div class="alert alert-danger">
			<ul class="mb-0">
				<c:forEach var="e" items="${errors}">
					<li>${e}</li>
				</c:forEach>
			</ul>
		</div>
	</c:if>

	<div class="card shadow-sm mb-3">
		<div class="card-body">
			<h5 class="card-title">Thêm / Cập nhật sản phẩm</h5>

			<form method="post" enctype="multipart/form-data"
				action="<c:url value='${actionPath}'/>" class="row g-3">
				<c:if test="${not empty p}">
					<input type="hidden" name="productId" value="${p.productId}" />
				</c:if>

				<div class="col-md-4">
					<label class="form-label">Tên</label> <input name="name"
						class="form-control" required value="${p.productName}" />
				</div>

				<div class="col-md-2">
					<label class="form-label">Giá</label> <input name="price"
						type="number" step="0.01" min="0.01" class="form-control" required
						value="${p.price}" />
				</div>

				<div class="col-md-2">
					<label class="form-label">Tồn</label> <input name="stock"
						type="number" min="0" class="form-control" required
						value="${p.stock}" />
				</div>

				<div class="col-md-4">
					<label class="form-label">Danh mục</label> <select
						name="categoryId" class="form-select" required>
						<option value="">-- Chọn danh mục --</option>
						<c:forEach var="c" items="${categories}">
							<option value="${c.categoryId}"
								${not empty p && p.category.categoryId == c.categoryId ? 'selected' : ''}>
								${c.categoryName}</option>
						</c:forEach>
					</select>
				</div>

				<div class="col-md-6">
					<label class="form-label">Ảnh sản phẩm</label> <input type="file"
						name="image" accept=".jpg,.jpeg,.png,.webp,image/*"
						class="form-control" /> <small class="text-muted">Chọn 1
						ảnh (≤ 2MB) — sẽ lấy làm thumbnail.</small>

					<c:if test="${not empty thumbEditing}">
						<div class="mt-2">
							<img src="${thumbEditing}" width="120" class="rounded shadow-sm" />
						</div>
					</c:if>
				</div>

				<c:if test="${not empty p}">
					<div class="col-md-3">
						<label class="form-label">Trạng thái</label> <select name="status"
							class="form-select">
							<option value="ACTIVE" ${p.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
							<option value="INACTIVE"
								${p.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
						</select>
					</div>
				</c:if>

				<div class="col-12 d-flex justify-content-end">
					<button class="btn btn-primary" type="submit">${empty p ? "Thêm" : "Lưu"}
					</button>
				</div>
			</form>
		</div>
	</div>

	<div class="card shadow-sm mb-4">
		<div class="card-body">
			<h5 class="card-title">Tìm kiếm & Lọc</h5>
			<form method="get" action="<c:url value='/vendor/products'/>"
				class="row g-2">
				<div class="col-md-4">
					<input class="form-control" name="q" placeholder="Tìm theo tên..."
						value="${q}" />
				</div>
				<div class="col-md-3">
					<select class="form-select" name="categoryId">
						<option value="">-- Tất cả danh mục --</option>
						<c:forEach var="c" items="${categories}">
							<option value="${c.categoryId}"
								${categoryId == c.categoryId ? 'selected' : ''}>${c.categoryName}</option>
						</c:forEach>
					</select>
				</div>
				<div class="col-md-2">
					<select class="form-select" name="status">
						<option value="" ${empty status ? 'selected' : ''}>-- Tất
							cả --</option>
						<option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
						<option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
					</select>
				</div>
				<div class="col-md-2">
					<select class="form-select" name="size">
						<c:set var="sz" value="${size != null ? size : 10}" />
						<option ${sz == 10 ? 'selected' : ''} value="10">10 /
							trang</option>
						<option ${sz == 20 ? 'selected' : ''} value="20">20 /
							trang</option>
						<option ${sz == 50 ? 'selected' : ''} value="50">50 /
							trang</option>
					</select>
				</div>
				<div class="col-md-1 d-grid">
					<button class="btn btn-outline-secondary">Lọc</button>
				</div>
			</form>
		</div>
	</div>

	<div class="card shadow-sm">
		<div class="card-body">
			<h5 class="card-title">Danh sách sản phẩm</h5>
			<div class="table-responsive">
				<table class="table table-bordered align-middle mb-0">
					<thead class="table-light">
						<tr>
							<th>ID</th>
							<th>Ảnh</th>
							<th>Tên</th>
							<th>Danh mục</th>
							<th>Giá</th>
							<th>Tồn</th>
							<th>Shop</th>
							<th>Trạng thái</th>
							<th width="200">Hành động</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="it" items="${products}">
							<tr data-row-id="${it.productId}">
								<td>${it.productId}</td>
								<td><c:choose>
										<c:when test="${not empty thumbnails[it.productId]}">
											<img src="${thumbnails[it.productId]}" width="60"
												class="rounded shadow-sm" />
										</c:when>
										<c:otherwise>
											<span class="text-muted">Không có</span>
										</c:otherwise>
									</c:choose></td>
								<td>${it.productName}</td>
								<td><c:out
										value="${empty it.category ? '—' : it.category.categoryName}" /></td>
								<td>${it.price}</td>
								<td>${it.stock}</td>
								<td><c:choose>
										<c:when test="${not empty it.shop}">${it.shop.shopName}</c:when>
										<c:when test="${not empty shop}">${shop.shopName}</c:when>
										<c:otherwise>—</c:otherwise>
									</c:choose></td>
								<td><span
									class="badge status-badge bg-${it.status == 'ACTIVE' ? 'success' : 'secondary'}">
										${it.status} </span></td>
								<td class="d-flex gap-2"><a
									class="btn btn-sm btn-outline-primary"
									href="<c:url value='/vendor/products/edit'>
              <c:param name='id' value='${it.productId}'/>
           </c:url>">Sửa</a>

									<!-- ⚙️ Biến thể (size/màu) --> <a
									class="btn btn-sm btn-outline-warning"
									href="<c:url value='/vendor/product/variants'>
              <c:param name='productId' value='${it.productId}'/>
           </c:url>">Biến
										thể</a> <!-- 🧩 Thuộc tính giày (brand/material/gender/style) -->
									<a class="btn btn-sm btn-outline-secondary"
									href="<c:url value='/vendor/attribute'>
              <c:param name='productId' value='${it.productId}'/>
           </c:url>">Thuộc
										tính</a> <!-- CHỈ 1 nút: Ẩn/Hiện (giữ nguyên AJAX toggle) -->
									<button type="button"
										class="btn btn-sm btn-toggle ${it.status == 'ACTIVE' ? 'btn-outline-danger' : 'btn-outline-success'}"
										data-id="${it.productId}">${it.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'}
									</button></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>

			<c:if test="${totalPages > 1}">
				<nav class="mt-3">
					<ul class="pagination mb-0">
						<c:set var="cur" value="${page}" />
						<li class="page-item ${cur <= 1 ? 'disabled' : ''}"><a
							class="page-link"
							href="<c:url value='/vendor/products'>
                         <c:param name='page' value='${cur-1}'/>
                         <c:param name='size' value='${size}'/>
                         <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                         <c:if test='${not empty categoryId}'><c:param name='categoryId' value='${categoryId}'/></c:if>
                         <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                       </c:url>">Prev</a>
						</li>
						<c:forEach var="i" begin="1" end="${totalPages}">
							<li class="page-item ${i == cur ? 'active' : ''}"><a
								class="page-link"
								href="<c:url value='/vendor/products'>
                           <c:param name='page' value='${i}'/>
                           <c:param name='size' value='${size}'/>
                           <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                           <c:if test='${not empty categoryId}'><c:param name='categoryId' value='${categoryId}'/></c:if>
                           <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                         </c:url>">${i}</a>
							</li>
						</c:forEach>
						<li class="page-item ${cur >= totalPages ? 'disabled' : ''}">
							<a class="page-link"
							href="<c:url value='/vendor/products'>
                         <c:param name='page' value='${cur+1}'/>
                         <c:param name='size' value='${size}'/>
                         <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                         <c:if test='${not empty categoryId}'><c:param name='categoryId' value='${categoryId}'/></c:if>
                         <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                       </c:url>">Next</a>
						</li>
					</ul>
				</nav>
			</c:if>
		</div>
	</div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function () {
  const $$ = (q, el=document) => Array.from(el.querySelectorAll(q));

  $$('.btn-toggle').forEach(btn => {
    btn.addEventListener('click', async () => {
      const id = btn.dataset.id;
      try {
        const res = await fetch('<c:url value="/vendor/products/toggle"/>', {
          method: 'POST',
          headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
          body: new URLSearchParams({id})
        });
        const data = await res.json();
        if (!data.ok) { alert(data.message || 'Lỗi thao tác'); return; }

        const row = btn.closest('tr');
        const badge = row.querySelector('.status-badge');
        if (badge) {
          badge.textContent = data.status;
          badge.classList.remove('bg-success', 'bg-secondary');
          badge.classList.add(data.status === 'ACTIVE' ? 'bg-success' : 'bg-secondary');
        }

        // Cập nhật nút: chỉ hiển thị "Ẩn" hoặc "Hiện"
        btn.classList.remove('btn-outline-danger', 'btn-outline-success');
        if (data.status === 'ACTIVE') {
          btn.classList.add('btn-outline-danger');
          btn.textContent = 'Ẩn';
        } else {
          btn.classList.add('btn-outline-success');
          btn.textContent = 'Hiện';
        }
      } catch (e) {
        alert('Lỗi kết nối');
      }
    });
  });
});
</script>
