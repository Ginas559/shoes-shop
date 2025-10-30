<!-- filepath: src/main/webapp/WEB-INF/views/vendor/dashboard.jsp -->
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<main class="container py-4">
	<div
		class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
		<h2 class="mb-0">Vendor Dashboard</h2>

		<!-- Bộ lọc thời gian (optional) -->
		<form class="row g-2" method="get" action="${ctx}/vendor/dashboard">
			<div class="col-auto">
				<input type="date" class="form-control" name="from"
					value="${filterFrom}" placeholder="From (YYYY-MM-DD)" />
			</div>
			<div class="col-auto">
				<input type="date" class="form-control" name="to"
					value="${filterTo}" placeholder="To (YYYY-MM-DD)" />
			</div>
			<div class="col-auto">
				<input type="number" class="form-control" name="year"
					value="${filterYear}" placeholder="Year (YYYY)" min="2000"
					max="2100" />
			</div>
			<div class="col-auto">
				<button class="btn btn-outline-primary">Áp dụng</button>
			</div>
		</form>
	</div>

	<!-- HÀNG BUTTON CHUYỂN TRANG -->
	<div class="mb-4 d-flex flex-wrap gap-3">
		<a href="${ctx}/vendor/products" class="btn btn-primary">🛍️ Quản
			lý sản phẩm</a> <a href="${ctx}/vendor/orders" class="btn btn-success">📦
			Đơn hàng</a>
		<c:if test="${not empty shop and not empty shop.shopId}">
			<a href="${ctx}/chat?shopId=${shop.shopId}"
				class="btn btn-outline-primary">💬 Chat nội bộ</a>
			<a href="${ctx}/chat/public?shopId=${shop.shopId}"
				class="btn btn-outline-primary">💬 Chat công khai</a>
		</c:if>
	</div>


	<!-- KPIs -->
	<div class="row g-3">
		<div class="col-md-3">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h6 class="text-muted mb-1">Tổng đơn hàng</h6>
					<p class="display-6 mb-0">
						<c:out value="${stats.orderCount}" />
					</p>
				</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h6 class="text-muted mb-1">Doanh thu (DELIVERED)</h6>
					<p class="display-6 mb-0">
						<c:out value="${stats.revenue}" />
					</p>
				</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h6 class="text-muted mb-1">Tăng trưởng MoM</h6>
					<c:set var="grow" value="${growthPercent}" />
					<div class="d-flex align-items-baseline gap-2">
						<span class="display-6 mb-0"> <c:out value="${grow}" />%
						</span>
						<c:choose>
							<c:when test="${grow >= 0}">
								<span class="badge bg-success">↑</span>
							</c:when>
							<c:otherwise>
								<span class="badge bg-danger">↓</span>
							</c:otherwise>
						</c:choose>
					</div>
					<small class="text-muted">So với tháng trước</small>
				</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h6 class="text-muted mb-1">Top sản phẩm</h6>
					<ol class="mb-0 small">
						<c:forEach var="row" items="${stats.topProducts}">
							<li><span class="text-truncate d-inline-block"
								style="max-width: 180px;"> <c:out value="${row[0]}" />
							</span> — SL: <strong><c:out value="${row[1]}" /></strong></li>
						</c:forEach>
						<c:if test="${empty stats.topProducts}">
							<li class="text-muted">Chưa có dữ liệu</li>
						</c:if>
					</ol>
				</div>
			</div>
		</div>
	</div>

	<hr class="my-4" />

	<!-- Charts -->
	<div class="row g-3">
		<div class="col-lg-7">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h5 class="card-title mb-3">Doanh thu theo tháng</h5>
					<canvas id="revChart" height="140"></canvas>
				</div>
			</div>
		</div>
		<div class="col-lg-5">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h5 class="card-title mb-3">Cơ cấu trạng thái đơn hàng</h5>
					<canvas id="statusChart" height="140"></canvas>
				</div>
			</div>
		</div>
	</div>

	<hr class="my-4" />

	<!-- Recent orders -->
	<div class="card shadow-sm">
		<div class="card-body">
			<h5 class="card-title mb-3">Đơn gần đây</h5>
			<div class="table-responsive">
				<table class="table table-sm align-middle">
					<thead class="table-light">
						<tr>
							<th>ID</th>
							<th>Khách hàng</th>
							<th>Tổng tiền</th>
							<th>Trạng thái</th>
							<th>Ngày tạo</th>
						</tr>
					</thead>
					<tbody id="recentOrdersTable">
						<c:forEach var="o" items="${recentOrders}">
							<tr>
								<td>#<c:out value="${o.orderId}" /></td>
								<td><c:out value="${o.user.firstname}" /> <c:out
										value="${o.user.lastname}" /></td>
								<td><c:out value="${o.totalAmount}" /></td>
								<td><span class="badge bg-secondary"><c:out
											value="${o.status}" /></span></td>
								<td><c:out value="${o.createdAt}" /></td>
							</tr>
						</c:forEach>
						<c:if test="${empty recentOrders}">
							<tr>
								<td colspan="5" class="text-muted">Chưa có đơn hàng.</td>
							</tr>
						</c:if>
					</tbody>
				</table>
			</div>
		</div>
	</div>
</main>

<!-- Chart.js -->
<script
	src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  // Build revenue arrays from server-side 'revenueRows' => [ [month, total], ... ]
  const revLabels = [];
  const revValues = [];
  <%-- JSTL → JS --%>
  <c:forEach var="r" items="${revenueRows}">
    revLabels.push("Tháng ${r[0]}");
    revValues.push(${r[1]});
  </c:forEach>

  const ctxRev = document.getElementById('revChart');
  if (ctxRev) {
    new Chart(ctxRev, {
      type: 'bar',
      data: { labels: revLabels, datasets: [{ label: 'Doanh thu', data: revValues }] },
      options: { responsive: true, scales: { y: { beginAtZero: true } } }
    });
  }

  // Build status chart from 'statusCounts' => Map {status -> count}
  const statusLabels = [];
  const statusValues = [];
  <c:forEach var="e" items="${statusCounts}">
    statusLabels.push("${e.key}");
    statusValues.push(${e.value});
  </c:forEach>

  const ctxStatus = document.getElementById('statusChart');
  if (ctxStatus) {
    new Chart(ctxStatus, {
      type: 'doughnut',
      data: { labels: statusLabels, datasets: [{ label: 'Số đơn', data: statusValues }] },
      options: { responsive: true }
    });
  }
</script>
