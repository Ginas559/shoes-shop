<!-- filepath: src/main/webapp/WEB-INF/views/vendor/product-variant.jsp -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<main class="container py-4">

  <!-- HÀNG BUTTON CHUYỂN TRANG -->
  <div class="mb-4 d-flex flex-wrap gap-3">
    <a href="${ctx}/vendor/products" class="btn btn-primary">🛍️ Quản lý sản phẩm</a>
    <a href="${ctx}/vendor/orders" class="btn btn-success">📦 Đơn hàng</a>
    <c:if test="${not empty shop and not empty shop.shopId}">
      <a href="${ctx}/chat?shopId=${shop.shopId}" class="btn btn-outline-primary">💬 Chat nội bộ</a>
      <a href="${ctx}/chat/public?shopId=${shop.shopId}" class="btn btn-outline-primary">💬 Chat công khai</a>
    </c:if>
  </div>

  <h2 class="mb-3">Biến thể sản phẩm: ${product.productName}</h2>

  <!-- Form thêm biến thể -->
  <form method="post" enctype="multipart/form-data" class="row g-2 mb-4">
    <input type="hidden" name="productId" value="${product.productId}"/>
    <div class="col-md-2">
      <input type="text" name="size" class="form-control" placeholder="Size" required>
    </div>
    <div class="col-md-3">
      <input type="text" name="color" class="form-control" placeholder="Màu sắc" required>
    </div>
    <div class="col-md-2">
      <input type="number" name="stock" class="form-control" placeholder="Tồn kho">
    </div>

    <!-- Upload ảnh biến thể -->
    <div class="col-md-3">
      <input type="file" name="variantImage" accept=".jpg,.jpeg,.png,.webp,image/*" class="form-control"/>
      <small class="text-muted">Chọn 1 ảnh (≤ 2MB) — ảnh thumbnail của biến thể.</small>
    </div>

    <div class="col-md-2">
      <button class="btn btn-primary w-100">Thêm</button>
    </div>
  </form>

  <!-- Bảng danh sách biến thể -->
  <table class="table table-bordered align-middle">
    <thead class="table-light">
    <tr>
      <th>#</th>
      <th>Size</th>
      <th>Màu</th>
      <th>Tồn kho</th>
      <th>Ảnh</th>
      <th>Thao tác</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="v" items="${variants}">
      <tr>
        <td>${v.variantId}</td>
        <td>${v.size}</td>
        <td>${v.color}</td>
        <td>${v.stock}</td>
        <td>
          <c:choose>
            <c:when test="${not empty v.imageUrl}">
              <img src="${v.imageUrl}" alt="ảnh" width="70" class="rounded shadow-sm"/>
            </c:when>
            <c:otherwise>
              <span class="text-muted">Không có ảnh</span>
            </c:otherwise>
          </c:choose>
        </td>
        <td>
          <a href="${ctx}/vendor/product/variant/delete?id=${v.variantId}&productId=${product.productId}"
             class="btn btn-sm btn-danger">Xóa</a>
        </td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</main>
