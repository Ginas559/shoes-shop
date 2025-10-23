<!-- tung - filepath: src/main/webapp/WEB-INF/views/auth/register.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html>
<head>
    <title>Đăng ký tài khoản</title>
    <meta charset="utf-8"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/bootstrap.min.css"/>
</head>
<body>
<div class="container mt-5" style="max-width: 540px;">
    <h3 class="mb-3 text-center">Đăng ký tài khoản</h3>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/register">
        <div class="mb-3">
            <label class="form-label">Họ</label>
            <input type="text" name="firstname" class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Tên</label>
            <input type="text" name="lastname" class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Email (đăng nhập)</label>
            <input type="email" name="email" class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Số điện thoại</label>
            <input type="text" name="phone" class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Mật khẩu</label>
            <input type="password" name="password" class="form-control" minlength="6" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Xác nhận mật khẩu</label>
            <input type="password" name="confirm" class="form-control" minlength="6" required/>
        </div>
        <button class="btn btn-primary w-100" type="submit">Đăng ký</button>
    </form>
</div>
</body>
</html>
