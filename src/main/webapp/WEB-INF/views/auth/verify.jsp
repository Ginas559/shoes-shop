// filepath: src/main/webapp/WEB-INF/views/auth/verify.jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="row justify-content-center">
  <div class="col-md-6">

    <c:if test="${not empty flash}">
      <div class="alert alert-info">${flash}</div>
    </c:if>

    <h2 class="mb-3">Xác minh OTP</h2>

    <form method="post" action="${ctx}/verify" class="mb-3">
      <input type="hidden" name="email" value="${param.email}"/>
      <div class="mb-3">
        <label class="form-label">Mã OTP</label>
        <input type="text" name="code" class="form-control" maxlength="6" required/>
      </div>
      <button class="btn btn-primary">Xác minh</button>
    </form>

    <form method="post" action="${ctx}/otp/resend">
      <input type="hidden" name="email" value="${param.email}"/>
      <button class="btn btn-outline-secondary btn-sm">Gửi lại OTP</button>
    </form>

  </div>
</div>
