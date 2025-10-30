<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${pageTitle != null ? pageTitle : 'BMTT Shop'}</title>

<sitemesh:write property="head" />

<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/assets/css/web2.css">

<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- ĐÃ THÊM: class "main-vendor-shop-create" để "ăn" nền pastel --%>
<main class="container py-4 main-vendor-shop-create">
  
  <%-- ĐÃ THÊM: class "gradient-text" (từ v1) cho "cháy" --%>
  <h2 class="mb-3 gradient-text" style="font-weight: 700;">Tạo cửa hàng</h2>

  <%-- 
    ĐÃ NÂNG CẤP: Bọc form vào "form-card-pink"
    Class này sẽ được "refactor" (tái cấu trúc) trong web2.css
    để dùng chung cho mọi trang form (Thêm SP, Thuộc tính, Tạo shop)
  --%>
  <div class="card shadow-sm form-card-pink">
    <div class="card-body">
      <h5 class="card-title mb-3" style="font-weight: 600;">Thông tin cơ bản</h5>
      
      <%-- ĐÃ XÓA: class="card p-3 shadow-sm" (vì đã bọc bên ngoài) --%>
      <form method="post">
        <div class="mb-3">
          <label class="form-label">Tên cửa hàng</label>
          <%-- Input này sẽ tự "ăn" style nền mờ từ card --%>
          <input name="shopName" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label">Mô tả</label>
          <%-- Textarea này cũng sẽ tự "ăn" style nền mờ --%>
          <textarea name="description" class="form-control" rows="3"></textarea>
        </div>
        
        <%-- Nút này sẽ tự "ăn" style hồng "cháy" và "pulse" --%>
        <button class="btn btn-primary">Tạo shop</button>
      </form>
    </div>
  </div>
</main>