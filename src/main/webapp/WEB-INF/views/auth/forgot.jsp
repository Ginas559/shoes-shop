<!-- ✅ filepath: src/main/webapp/WEB-INF/views/auth/forgot.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="container" style="max-width:520px;">
  <h3 class="mt-4 mb-3">Quên mật khẩu</h3>

  <c:if test="${not empty flash}">
    <div class="alert alert-info">${flash}</div>
    <c:remove var="flash" scope="session"/>
  </c:if>

  <form method="post" action="${ctx}/forgot-password">
    <div class="mb-3">
      <label class="form-label">Email đăng ký</label>
      <input type="email" name="email" class="form-control" required maxlength="128"/>
    </div>
    <button class="btn btn-primary w-100">Gửi OTP</button>
  </form>

  <div class="text-center mt-3">
    <a href="${ctx}/login">Quay lại đăng nhập</a>
  </div>
</div>
