<!-- ✅ filepath: src/main/webapp/WEB-INF/views/auth/login.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="container" style="max-width:520px;">
  <h2 class="mt-4 mb-3 text-center">Đăng nhập</h2>

  <c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
  </c:if>
  <c:if test="${not empty flash}">
    <div class="alert alert-info">${flash}</div>
    <c:remove var="flash" scope="session"/>
  </c:if>

  <form method="post" action="${ctx}/login">
    <div class="mb-3">
      <label class="form-label">Email</label>
      <input type="email" name="email" class="form-control" required maxlength="128"/>
    </div>
    <div class="mb-2">
      <label class="form-label">Mật khẩu</label>
      <input type="password" name="password" class="form-control" required/>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <div></div>
      <!-- 🔗 Thêm link Quên mật khẩu -->
      <a href="${ctx}/forgot-password" class="small">Quên mật khẩu?</a>
    </div>

    <button class="btn btn-primary w-100" type="submit">Đăng nhập</button>
  </form>

  <div class="text-center mt-3">
    Chưa có tài khoản? <a href="${ctx}/register">Đăng ký</a>
  </div>
</div>
