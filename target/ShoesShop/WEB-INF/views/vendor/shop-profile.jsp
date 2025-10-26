<!-- filepath: src/main/webapp/WEB-INF/views/vendor/shop-profile.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-4">
  <h3 class="mb-3">Hồ sơ Shop</h3>

  <form action="${pageContext.request.contextPath}/vendor/shop/update"
        method="post" enctype="multipart/form-data" class="card p-3">

    <div class="mb-3">
      <label class="form-label">Tên shop</label>
      <input class="form-control" name="shopName" value="${shop.shopName}">
    </div>

    <div class="mb-3">
      <label class="form-label">Mô tả</label>
      <textarea class="form-control" rows="4" name="description">${shop.description}</textarea>
    </div>

    <div class="row g-3 align-items-center mb-3">
      <div class="col-auto">
        <c:choose>
          <c:when test="${not empty shop.logoUrl}">
            <img id="logoPreview" src="${shop.logoUrl}" alt="Logo"
                 style="width:96px;height:96px;border-radius:12px;object-fit:cover;">
          </c:when>
          <c:otherwise>
            <img id="logoPreview" src="https://via.placeholder.com/96?text=Logo"
                 alt="Logo" style="width:96px;height:96px;border-radius:12px;object-fit:cover;">
          </c:otherwise>
        </c:choose>
      </div>
      <div class="col">
        <label class="form-label">Logo (tuỳ chọn)</label>
        <input class="form-control" type="file" name="logo" accept="image/*" onchange="previewLogo(event)">
        <div class="form-text">Chọn ảnh mới nếu muốn thay đổi logo.</div>
      </div>
    </div>

    <button class="btn btn-primary">Lưu thay đổi</button>
  </form>
</div>

<script>
  function previewLogo(e){
    const f = e.target.files && e.target.files[0];
    if(!f) return;
    document.getElementById('logoPreview').src = URL.createObjectURL(f);
  }
</script>
