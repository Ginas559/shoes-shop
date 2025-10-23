<!-- filepath: src/main/webapp/WEB-INF/views/auth/login.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8"/>
  <title>Đăng nhập</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/bootstrap.min.css"/>
</head>
<body>
<div class="container mt-5" style="max-width: 480px;">
  <h3 class="mb-3 text-center">Đăng nhập</h3>

  <c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
  </c:if>

  <form method="post" action="${pageContext.request.contextPath}/login">
    <div class="mb-3">
      <label class="form-label">Email</label>
      <input type="email" name="email" class="form-control" required/>
    </div>
    <div class="mb-3">
      <label class="form-label">Mật khẩu</label>
      <input type="password" name="password" class="form-control" required/>
    </div>
    <button class="btn btn-primary w-100" type="submit">Đăng nhập</button>
  </form>

  <div class="mt-3 text-center">
    <a href="${pageContext.request.contextPath}/register">Chưa có tài khoản? Đăng ký</a>
  </div>
</div>
</body>
</html>
