// filepath: src/main/webapp/WEB-INF/decorators/web.jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sitemesh" uri="http://www.sitemesh.org/decorator" %>

<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title><c:out value="${pageTitle != null ? pageTitle : 'BMTT Shop'}"/></title>

  <!-- Head từ trang con -->
  <sitemesh:write property="head"/>

  <!-- Bootstrap CSS (CDN) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- (Tuỳ chọn) Dùng file local khi đã có -->
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

        <!-- User actions -->
        <div class="d-flex align-items-center gap-2">
          <c:choose>
            <c:when test="${empty sessionScope.userId}">
              <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
              <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/register">Đăng ký</a>
            </c:when>
            <c:otherwise>
              <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/user/profile">
                Xin chào, <c:out value="${sessionScope.email}"/>
              </a>
              <form method="post" action="${pageContext.request.contextPath}/logout" class="d-inline m-0">
                <button class="btn btn-sm btn-danger" type="submit">Đăng xuất</button>
              </form>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </nav>

  <main class="container">
    <!-- Body trang con -->
    <sitemesh:write property="body"/>
  </main>

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
  <!-- (Tuỳ chọn) file local -->
  <!-- <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script> -->
</body>
</html>
