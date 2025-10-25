<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<main class="container py-4">
  <h2 class="mb-3">Quản lý sản phẩm</h2>

  <div class="card shadow-sm mb-3">
    <div class="card-body">
      <h5 class="card-title">Thêm / Cập nhật sản phẩm</h5>

      <form method="post"
            action="<c:url value='/vendor/products/${empty p ? "add" : "update"}'/>"
            class="row g-3">
        <c:if test="${not empty p}">
          <input type="hidden" name="productId" value="${p.productId}"/>
        </c:if>

        <div class="col-md-4">
          <label class="form-label">Tên</label>
          <input name="name" class="form-control" required value="${p.productName}"/>
        </div>

        <div class="col-md-2">
          <label class="form-label">Giá</label>
          <input name="price" type="number" step="0.01" min="0" class="form-control" required value="${p.price}"/>
        </div>

        <div class="col-md-2">
          <label class="form-label">Tồn</label>
          <input name="stock" type="number" min="0" class="form-control" required value="${p.stock}"/>
        </div>

        <div class="col-md-4">
          <label class="form-label">Danh mục</label>
          <select name="categoryId" class="form-select" required>
            <option value="">-- Chọn danh mục --</option>
            <c:forEach var="c" items="${categories}">
              <option value="${c.categoryId}"
                ${not empty p && p.category.categoryId == c.categoryId ? 'selected' : ''}>
                ${c.categoryName}
              </option>
            </c:forEach>
          </select>
        </div>

        <c:if test="${not empty p}">
          <div class="col-md-3">
            <label class="form-label">Trạng thái</label>
            <select name="status" class="form-select">
              <option ${p.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
              <option ${p.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
            </select>
          </div>
        </c:if>

        <div class="col-12 d-flex justify-content-end">
          <button class="btn btn-primary" type="submit">
            ${empty p ? "Thêm" : "Lưu"}
          </button>
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
            <th>Tên</th>
            <th>Giá</th>
            <th>Tồn</th>
            <th>Trạng thái</th>
            <th width="180">Hành động</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach var="it" items="${products}">
            <tr>
              <td>${it.productId}</td>
              <td>${it.productName}</td>
              <td>${it.price}</td>
              <td>${it.stock}</td>
              <td>
                <span class="badge bg-${it.status == 'ACTIVE' ? 'success' : 'secondary'}">
                  ${it.status}
                </span>
              </td>
              <td>
                <a class="btn btn-sm btn-outline-primary"
                   href="<c:url value='/vendor/products/edit?id=${it.productId}'/>">Sửa</a>
                <form method="post" action="<c:url value='/vendor/products/delete'/>" class="d-inline">
                  <input type="hidden" name="productId" value="${it.productId}"/>
                  <button class="btn btn-sm btn-outline-danger"
                          onclick="return confirm('Ẩn sản phẩm này?')">Ẩn</button>
                </form>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</main>
