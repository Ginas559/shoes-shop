<!-- filepath: src/main/webapp/WEB-INF/views/vendor/shoe-attribute.jsp -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<main class="container py-4">

    <!-- HÀNG BUTTON CHUYỂN TRANG -->
    <div class="mb-4 d-flex flex-wrap gap-3">
        <a href="${ctx}/vendor/products" class="btn btn-primary">🛍️ Quản
            lý sản phẩm</a>
        <a href="${ctx}/vendor/orders" class="btn btn-success">📦
            Đơn hàng</a>
        <c:if test="${not empty shop and not empty shop.shopId}">
            <a href="${ctx}/chat?shopId=${shop.shopId}"
                class="btn btn-outline-primary">💬 Chat nội bộ</a>
            <a href="${ctx}/chat/public?shopId=${shop.shopId}"
                class="btn btn-outline-primary">💬 Chat công khai</a>
        </c:if>
    </div>

    <h2 class="mb-3">Thuộc tính giày: ${product.productName}</h2>

    <form method="post" class="row g-3">
        <input type="hidden" name="productId" value="${product.productId}"/>

        <div class="col-md-6">
            <label class="form-label">Thương hiệu</label>
            <input type="text" name="brand" class="form-control"
                   value="${attr != null ? attr.brand : ''}" placeholder="Nike, Adidas, v.v.">
        </div>

        <div class="col-md-6">
            <label class="form-label">Chất liệu</label>
            <input type="text" name="material" class="form-control"
                   value="${attr != null ? attr.material : ''}" placeholder="Da, Vải, PU...">
        </div>

        <div class="col-md-6">
            <label class="form-label">Giới tính</label>
            <select name="gender" class="form-select">
                <option value="">-- Chọn --</option>
                <option value="Nam" ${attr.gender == 'Nam' ? 'selected' : ''}>Nam</option>
                <option value="Nữ" ${attr.gender == 'Nữ' ? 'selected' : ''}>Nữ</option>
                <option value="Unisex" ${attr.gender == 'Unisex' ? 'selected' : ''}>Unisex</option>
            </select>
        </div>

        <div class="col-md-6">
            <label class="form-label">Kiểu dáng</label>
            <input type="text" name="style" class="form-control"
                   value="${attr != null ? attr.style : ''}" placeholder="Sneaker, Boot, Thể thao...">
        </div>

        <div class="col-12">
            <button class="btn btn-primary">Lưu thay đổi</button>
        </div>
    </form>

</main>
