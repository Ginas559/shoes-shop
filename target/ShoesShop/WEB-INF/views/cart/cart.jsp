<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<fmt:setLocale value="vi_VN" />

<h1 class="h5 mb-3">Giỏ hàng của bạn</h1>

<!-- Thông báo flash -->
<c:if test="${not empty flash}">
  <div class="alert alert-success">${flash}</div>
  <c:remove var="flash" scope="session" />
</c:if>
<c:if test="${not empty flash_error}">
  <div class="alert alert-danger">${flash_error}</div>
  <c:remove var="flash_error" scope="session" />
</c:if>

<c:choose>
  <c:when test="${cart != null && not empty cart.cartItems}">
    <div class="table-responsive">
      <table class="table align-middle">
        <thead>
          <tr>
            <th style="width:60px">#</th>
            <th>Sản phẩm</th>
            <th class="text-end" style="width:140px">Giá</th>
            <th class="text-center" style="width:180px">Số lượng</th>
            <th class="text-end" style="width:160px">Tổng</th>
            <th class="text-end" style="width:110px"></th>
          </tr>
        </thead>
        <tbody>
          <c:set var="grandTotal" value="0" />
          <c:forEach var="item" items="${cart.cartItems}" varStatus="st">
            <c:set var="lineTotal" value="${item.product.price * (empty item.quantity ? 1 : item.quantity)}" />
            <tr>
              <td>${st.index + 1}</td>

              <td class="js-product-name">
                <a href="${ctx}/product/${item.product.productId}">
                  <c:out value="${item.product.productName}" />
                </a>
              </td>

              <td class="text-end">
                <fmt:formatNumber value="${item.product.price}" type="currency" currencySymbol="₫" />
              </td>

              <!-- Cập nhật số lượng -->
              <td class="text-center">
                <form method="post" action="${ctx}/cart/update" class="d-inline-flex align-items-center gap-2">
                  <input type="hidden" name="itemId" value="${item.cartItemId}" />
                  <input type="number"
                         class="form-control form-control-sm text-center"
                         name="quantity"
                         value="${empty item.quantity ? 1 : item.quantity}"
                         min="1"
                         style="width:80px"/>
                  <button class="btn btn-sm btn-outline-primary">Cập nhật</button>
                </form>
              </td>

              <td class="text-end">
                <fmt:formatNumber value="${lineTotal}" type="currency" currencySymbol="₫" />
              </td>

              <!-- Xoá -->
              <td class="text-end">
                <!-- ✅ bỏ confirm() sơ sài; giữ nguyên action/method -->
                <form method="post" action="${ctx}/cart/delete" class="d-inline js-delete-form">
                  <input type="hidden" name="itemId" value="${item.cartItemId}" />
                  <button type="button" class="btn btn-sm btn-outline-danger js-delete-btn">
                    Xoá
                  </button>
                </form>
              </td>
            </tr>

            <!-- Cộng dồn tổng -->
            <c:set var="grandTotal" value="${grandTotal + lineTotal}" />
          </c:forEach>
        </tbody>

        <!-- ✅ Dòng tổng cộng -->
        <tfoot>
          <tr>
            <th colspan="4" class="text-end">Tổng cộng:</th>
            <th class="text-end">
              <fmt:formatNumber value="${grandTotal}" type="currency" currencySymbol="₫" />
            </th>
            <th></th>
          </tr>
        </tfoot>
      </table>
    </div>

    <div class="text-end mt-3">
      <a href="${ctx}/checkout" class="btn btn-success">Tiến hành đặt hàng (COD)</a>
    </div>
  </c:when>

  <c:otherwise>
    <div class="text-center text-muted py-5">
      Giỏ hàng trống. <a href="${ctx}/products">Xem sản phẩm</a>
    </div>
  </c:otherwise>
</c:choose>

<!-- ========== Modal xác nhận xoá (đẹp, có màu & khối nổi, không phụ thuộc lib ngoài) ========== -->
<style>
  .cm-overlay {
    position: fixed; inset: 0;
    display: none; align-items: center; justify-content: center;
    background: rgba(0, 0, 0, 0.55);
    backdrop-filter: blur(3px);
    z-index: 1050;
    transition: opacity .2s ease;
  }
  .cm-overlay.show {
    display: flex;
    animation: cm-fadeIn .25s ease forwards;
  }
  @keyframes cm-fadeIn { from {opacity:0} to {opacity:1} }
  @keyframes cm-scaleUp { from {transform:scale(0.92); opacity:0} to {transform:scale(1); opacity:1} }

  .cm-modal {
    width: min(480px, 90vw);
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 15px 40px rgba(0,0,0,.30);
    overflow: hidden;
    animation: cm-scaleUp .22s ease;
  }
  .cm-header {
    padding: 16px 20px;
    background: linear-gradient(135deg, #ff4b2b, #ff416c);
    color: #fff;
    font-weight: 600;
    font-size: 1.05rem;
    display: flex; align-items: center; gap: 8px;
  }
  .cm-body {
    padding: 18px 22px;
    background: #fff;
    color: #333;
  }
  .cm-body strong { color: #e63946; }
  .cm-footer {
    padding: 14px 20px;
    background: #f9f9f9;
    border-top: 1px solid #eee;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  .cm-btn {
    border: none;
    padding: 8px 14px;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: transform .2s ease, background .2s ease, box-shadow .2s ease;
  }
  .cm-btn:hover { transform: translateY(-1px); }
  .cm-btn:active { transform: translateY(0); }
  .cm-btn-cancel {
    background: #e9ecef;
    color: #333;
  }
  .cm-btn-cancel:hover { background: #dcdcdc; }
  .cm-btn-danger {
    background: #ff4b2b;
    color: #fff;
    box-shadow: 0 6px 16px rgba(255, 75, 43, 0.35);
  }
  .cm-btn-danger:hover { background: #ff2d1a; }
</style>

<div class="cm-overlay" id="confirmDeleteOverlay" role="dialog" aria-modal="true" aria-labelledby="cmTitle" aria-hidden="true">
  <div class="cm-modal" role="document">
    <div class="cm-header">🗑 Xác nhận xoá sản phẩm</div>
    <div class="cm-body">
      <div id="cmMessage">Bạn có chắc muốn xoá sản phẩm này khỏi giỏ hàng?</div>
    </div>
    <div class="cm-footer">
      <button type="button" class="cm-btn cm-btn-cancel" id="cmCancelBtn">Huỷ</button>
      <button type="button" class="cm-btn cm-btn-danger" id="cmConfirmBtn">Xoá</button>
    </div>
  </div>
</div>

<script>
(function () {
  // Trạng thái modal
  var overlay = document.getElementById('confirmDeleteOverlay');
  var confirmBtn = document.getElementById('cmConfirmBtn');
  var cancelBtn  = document.getElementById('cmCancelBtn');
  var msgBox     = document.getElementById('cmMessage');

  var pendingForm = null;

  function openModal(message, form) {
    pendingForm = form;
    // Cho phép in đậm tên SP (message đã được build từ textContent => an toàn)
    msgBox.innerHTML = message || "Bạn có chắc muốn xoá sản phẩm này khỏi giỏ hàng?";
    overlay.classList.add('show');
    overlay.setAttribute('aria-hidden', 'false');
    confirmBtn.focus();
  }

  function closeModal() {
    overlay.classList.remove('show');
    overlay.setAttribute('aria-hidden', 'true');
    pendingForm = null;
  }

  // Bấm Xoá trong modal
  confirmBtn.addEventListener('click', function () {
    if (pendingForm) {
      pendingForm.submit();
    }
    closeModal();
  });

  // Huỷ / bấm ra ngoài để đóng
  cancelBtn.addEventListener('click', closeModal);
  overlay.addEventListener('click', function (e) {
    if (e.target === overlay) closeModal();
  });

  // ESC để đóng
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && overlay.classList.contains('show')) {
      e.preventDefault();
      closeModal();
    }
  });

  // Gắn cho tất cả form xoá
  document.addEventListener('click', function (e) {
    var btn = e.target.closest('.js-delete-btn');
    if (!btn) return;

    var form = btn.closest('.js-delete-form');
    if (!form) return;

    // Lấy tên SP từ textContent (tránh HTML), rồi render đậm trong modal
    var row = form.closest('tr');
    var nameCell = row ? row.querySelector('.js-product-name') : null;
    var nameText = nameCell ? nameCell.textContent.trim() : 'sản phẩm này';

    e.preventDefault();
    openModal('Bạn có chắc muốn xoá <strong>"' + nameText + '"</strong> khỏi giỏ hàng?', form);
  });
})();
</script>
