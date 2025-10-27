<!-- tung - filepath: src/main/webapp/WEB-INF/views/auth/verify-otp.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html>
<head>
    <title>Xác thực OTP</title>
    <meta charset="utf-8"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/bootstrap.min.css"/>
</head>
<body>
<div class="container mt-5" style="max-width: 480px;">
    <h3 class="mb-3 text-center">Nhập mã OTP</h3>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>
    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/verify-otp">
        <input type="hidden" name="purpose" value="${param.purpose != null ? param.purpose : 'ACTIVATE'}"/>
        <div class="mb-3">
            <label class="form-label">Mã OTP (6 số)</label>
            <input type="text" name="code" class="form-control" maxlength="6" required/>
        </div>
        <button class="btn btn-success w-100" type="submit">Xác nhận</button>
    </form>
</div>
</body>
</html>
