<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!-- ✅ Ấn định locale VN để định dạng số/tiền -->
<fmt:setLocale value="vi_VN" />

<h1 class="h5 mb-3">Xác nhận đặt hàng (COD)</h1>

<!-- Thông báo -->
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
		<div class="row g-3">
			<!-- Địa chỉ giao hàng -->
			<div class="col-12 col-lg-5">
				<div class="card h-100">
					<div class="card-header fw-semibold">Địa chỉ giao hàng</div>
					<div class="card-body">
						<c:choose>
							<c:when test="${not empty addresses}">
								<form method="post" action="${ctx}/checkout" id="checkoutForm">
									<div class="vstack gap-2">
										<c:forEach var="a" items="${addresses}" varStatus="st">
											<label class="border rounded p-2 d-flex gap-2 align-items-start">
												<input class="form-check-input mt-1" type="radio"
													   name="addressId" value="${a.addressId}"
													   ${a.isDefault || st.first ? 'checked' : ''} />
												<span>
													<div class="fw-semibold">${a.receiverName}• ${a.phone}</div>
													<div class="text-muted small">${a.addressDetail}</div>
													<c:if test="${a.isDefault}">
														<span class="badge bg-success mt-1">Mặc định</span>
													</c:if>
												</span>
											</label>
										</c:forEach>
									</div>
								</form>
							</c:when>
							<c:otherwise>
								<div class="text-muted">Bạn chưa có địa chỉ giao hàng.</div>
								<a class="btn btn-outline-primary mt-2" href="${ctx}/user/address/new">➕ Thêm địa chỉ</a>
							</c:otherwise>
						</c:choose>
					</div>
				</div>
			</div>

			<!-- Tóm tắt đơn hàng -->
			<div class="col-12 col-lg-7">
				<div class="card">
					<div class="card-header fw-semibold">Đơn hàng của bạn</div>
					<div class="card-body">
						<div class="table-responsive">
							<table class="table align-middle">
								<thead>
									<tr>
										<th>Sản phẩm</th>
										<th class="text-end">Giá</th>
										<th class="text-center">SL</th>
										<th class="text-end">Tạm tính</th>
									</tr>
								</thead>
								<tbody>
									<c:set var="total" value="0" />
									<c:forEach var="ci" items="${cart.cartItems}">
										<tr>
											<td>
												<a href="${ctx}/product/${ci.product.productId}" class="text-decoration-none">
													<c:out value="${ci.product.productName}" />
												</a>
											</td>
											<td class="text-end">
												<!-- ✅ Hiển thị tiền với ký hiệu ₫ -->
												<fmt:formatNumber value="${ci.product.price}" type="currency" currencySymbol="₫" />
											</td>
											<td class="text-center">${ci.quantity}</td>
											<td class="text-end">
												<fmt:formatNumber value="${ci.product.price * ci.quantity}" type="currency" currencySymbol="₫" />
											</td>
										</tr>
										<c:set var="total" value="${total + (ci.product.price * ci.quantity)}" />
									</c:forEach>
								</tbody>
								<tfoot>
									<tr>
										<th colspan="3" class="text-end">Tổng cộng:</th>
										<th class="text-end">
											<fmt:formatNumber value="${total}" type="currency" currencySymbol="₫" />
										</th>
									</tr>
								</tfoot>
							</table>
						</div>

						<div class="d-flex justify-content-between mt-3">
							<a href="${ctx}/cart" class="btn btn-outline-secondary">← Quay lại giỏ hàng</a>
							<c:choose>
								<c:when test="${not empty addresses}">
									<button form="checkoutForm" class="btn btn-success">Đặt hàng (COD)</button>
								</c:when>
								<c:otherwise>
									<a href="${ctx}/user/address/new" class="btn btn-primary">Thêm địa chỉ để tiếp tục</a>
								</c:otherwise>
							</c:choose>
						</div>
					</div>
				</div>
			</div>
		</div>
	</c:when>

	<c:otherwise>
		<div class="text-center text-muted py-5">
			Giỏ hàng trống. <a href="${ctx}/products">Xem sản phẩm</a>
		</div>
	</c:otherwise>
</c:choose>
