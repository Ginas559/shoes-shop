//src/main/webapp/WEB-INF/views/vendor/shop-create.jsp
<%@ page contentType="text/html;charset=UTF-8" %>
<main class="container py-4">
  <h2 class="mb-3">Tạo cửa hàng</h2>
  <form method="post" class="card p-3 shadow-sm">
    <div class="mb-3">
      <label class="form-label">Tên cửa hàng</label>
      <input name="shopName" class="form-control" required>
    </div>
    <div class="mb-3">
      <label class="form-label">Mô tả</label>
      <textarea name="description" class="form-control" rows="3"></textarea>
    </div>
    <button class="btn btn-primary">Tạo shop</button>
  </form>
</main>
