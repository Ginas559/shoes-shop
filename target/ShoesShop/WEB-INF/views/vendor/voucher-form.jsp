<!-- filepath: src/main/webapp/WEB-INF/views/vendor/voucher-form.jsp -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="mb-0">
      <c:out value="${empty v and empty v_id ? 'Tạo voucher mới' : 'Cập nhật voucher'}"/>
    </h2>
  </div>

  <!-- Hiển thị thông báo lỗi (nếu có) -->
  <c:if test="${not empty errors}">
    <div class="alert alert-danger">
      <ul class="mb-0">
        <c:forEach var="e" items="${errors}">
          <li><c:out value="${e}"/></li>
        </c:forEach>
      </ul>
    </div>
  </c:if>

  <div class="card shadow-sm">
    <div class="card-body">
      <form method="post" action="${ctx}/vendor/vouchers/save" class="row g-3">

        <!-- Hidden ID (update) -->
        <c:if test="${not empty v or not empty v_id}">
          <input type="hidden" name="id" value="${not empty v ? v.voucherId : v_id}"/>
        </c:if>

        <!-- Data cũ (nếu có lỗi) -->
        <c:set var="codeValue" value="${not empty v ? v.code : v_code}"/>
        <c:set var="typeValue" value="${not empty v ? v.type : v_type}"/>

        <!-- Code -->
        <div class="col-md-4">
          <label for="code" class="form-label">Code</label>
          <input name="code" id="code" class="form-control" required
                 value="${codeValue}"
                 onblur="this.value=this.value.trim().toUpperCase()"/>
        </div>

        <!-- Type -->
        <div class="col-md-3">
          <label for="typeSelect" class="form-label">Loại</label>
          <select name="type" id="typeSelect" class="form-select" required>
            <option value="">-- Chọn --</option>
            <option value="PERCENT" ${typeValue == 'PERCENT' ? 'selected' : ''}>PERCENT (theo sản phẩm)</option>
            <option value="AMOUNT"  ${typeValue == 'AMOUNT'  ? 'selected' : ''}>AMOUNT (theo đơn)</option>
          </select>
        </div>

        <!-- Percent -->
        <div class="col-md-2 percent-group">
          <label for="percent" class="form-label">Percent (1–100)</label>
          <input name="percent" id="percent" type="number" step="0.01" min="1" max="100" class="form-control"
                 value="${not empty v ? v.percent : v_percent}"/>
        </div>

        <!-- Amount -->
        <div class="col-md-3 amount-group">
          <label for="amount" class="form-label">Amount (>0)</label>
          <input name="amount" id="amount" type="number" step="0.01" min="0.01" class="form-control"
                 value="${not empty v ? v.amount : v_amount}"/>
        </div>

        <!-- Min Order -->
        <div class="col-md-3">
          <label for="minOrderAmount" class="form-label">Min Order (≥0)</label>
          <input name="minOrderAmount" id="minOrderAmount" type="number" step="0.01" min="0" class="form-control"
                 value="${not empty v ? v.minOrderAmount : v_minOrder}"/>
        </div>

        <!-- Start / End -->
        <div class="col-md-3">
          <label for="startAt" class="form-label">Start At</label>
          <input name="startAt" id="startAt" type="datetime-local" class="form-control"
                 value="${not empty v ? v.startAt : v_startAt}"/>
        </div>
        <div class="col-md-3">
          <label for="endAt" class="form-label">End At</label>
          <input name="endAt" id="endAt" type="datetime-local" class="form-control"
                 value="${not empty v ? v.endAt : v_endAt}"/>
        </div>

        <!-- Status (update only) -->
        <c:if test="${not empty v}">
          <div class="col-md-3">
            <label for="status" class="form-label">Trạng thái</label>
            <select name="status" id="status" class="form-select">
              <option value="ACTIVE" ${v.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
              <option value="INACTIVE" ${v.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
            </select>
          </div>
        </c:if>

        <!-- Multi-select products (PERCENT only) -->
        <div class="col-12 percent-group">
          <label for="productIds" class="form-label">Áp dụng cho sản phẩm</label>
          <select name="productIds" id="productIds" class="form-select" multiple size="8">
            <c:forEach var="p" items="${products}">
              <c:set var="isSel" value="${not empty selectedProductIds and selectedProductIds.contains(p.productId)}"/>
              <option value="${p.productId}" ${isSel ? 'selected' : ''}>
                [#${p.productId}] ${p.productName}
              </option>
            </c:forEach>
          </select>
          <small class="text-muted">Giữ Ctrl/Shift để chọn nhiều sản phẩm.</small>
        </div>

        <!-- Actions -->
        <div class="col-12 d-flex justify-content-end">
          <a class="btn btn-outline-secondary me-2" href="${ctx}/vendor/vouchers">Hủy</a>
          <button class="btn btn-primary" type="submit">Lưu</button>
        </div>
      </form>
    </div>
  </div>
</main>

<!-- SCRIPT: toggle nhóm input theo type -->
<script>
(function(){
  const typeSelect = document.getElementById('typeSelect');
  const toggleGroups = () => {
    const t = typeSelect?.value;
    document.querySelectorAll('.percent-group').forEach(el => {
      el.style.display = (t === 'PERCENT') ? '' : 'none';
      el.querySelector('[name="percent"]')?.toggleAttribute('disabled', t !== 'PERCENT');
      el.querySelector('[name="productIds"]')?.toggleAttribute('disabled', t !== 'PERCENT');
    });
    document.querySelectorAll('.amount-group').forEach(el => {
      el.style.display = (t === 'AMOUNT') ? '' : 'none';
      el.querySelector('[name="amount"]')?.toggleAttribute('disabled', t !== 'AMOUNT');
    });
  };
  if (typeSelect) {
    typeSelect.addEventListener('change', toggleGroups);
    toggleGroups();
  }
})();
</script>
