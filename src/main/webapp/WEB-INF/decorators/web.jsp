<%@ page contentType="text/html; charset=UTF-8" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${pageTitle != null ? pageTitle : 'BMTT Shop'}</title>

  <!-- Nếu trang con có nội dung <head>, SiteMesh sẽ chèn tại đây -->
  <sitemesh:write property="head"/>

  <!-- Bootstrap CSS (CDN) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- (Tuỳ chọn) Khi đã có file local thì bật dòng dưới và bỏ CDN ở trên -->
  <!-- <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css"/> -->
</head>
<body>
  <nav class="navbar navbar-expand-lg navbar-light bg-light border-bottom mb-3">
    <div class="container">
      <a class="navbar-brand" href="${pageContext.request.contextPath}/">BMTT Shop</a>

      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav"
              aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="mainNav">
        <!-- Menu trái -->
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/products">Sản phẩm</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/cart">Giỏ hàng</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/checkout">Thanh toán (COD)</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/orders">Đơn hàng của tôi</a>
          </li>
        </ul>

        <!-- Nhóm link test nhanh (không JWT) -->
        <div class="d-flex align-items-center gap-2">
          <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/user/profile">Hồ sơ</a>
          <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/user/addresses">Địa chỉ</a>
        </div>
      </div>
    </div>
  </nav>

  <main class="container">
    <!-- Body trang con sẽ được SiteMesh thay thế tại đây -->
    <sitemesh:write property="body"/>
  </main>

  <!-- Footer tối thiểu, áp dụng cho mọi trang -->
  <footer class="border-top mt-5 py-3">
    <div class="container small text-muted d-flex flex-wrap gap-2 justify-content-between">
      <span>&copy; 2025 BMTTShop</span>
      <span>
        <a class="text-decoration-none" href="${pageContext.request.contextPath}/products">Sản phẩm</a>
        • <a class="text-decoration-none" href="#">Liên hệ</a>
      </span>
    </div>
  </footer>

  <!-- Bootstrap JS (CDN) -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- (Tuỳ chọn) Dùng file local khi đã chép vào dự án -->
  <!-- <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script> -->
</body>
</html>
