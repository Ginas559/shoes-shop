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

              <td>
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
                <form method="post" action="${ctx}/cart/delete"
                      onsubmit="return confirm('Xoá sản phẩm này khỏi giỏ hàng?');"
                      class="d-inline">
                  <input type="hidden" name="itemId" value="${item.cartItemId}" />
                  <button class="btn btn-sm btn-outline-danger">Xoá</button>
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
