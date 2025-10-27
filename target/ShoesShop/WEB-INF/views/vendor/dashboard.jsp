<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<main class="container py-4">
  <h2 class="mb-4">Vendor Dashboard</h2>

  <!-- HÀNG BUTTON CHUYỂN TRANG -->
  <div class="mb-4 d-flex flex-wrap gap-3">
    <a href="<c:url value='/vendor/products'/>" class="btn btn-primary">
      🛍️ Quản lý sản phẩm
    </a>
    <a href="<c:url value='/vendor/orders'/>" class="btn btn-success">
      📦 Đơn hàng
    </a>

    <!-- ⭐️ Nút chat giống profile, chỉ hiện khi có shop -->
    <c:if test="${not empty shop and not empty shop.shopId}">
      <a href="${ctx}/chat?shopId=${shop.shopId}" class="btn btn-outline-primary">
        💬 Chat với cửa hàng
      </a>
    </c:if>
  </div>

  <div class="row g-3">
    <div class="col-md-4">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Tổng đơn hàng</h5>
          <p class="display-6 mb-0"><c:out value="${stats.orderCount}" /></p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Doanh thu</h5>
          <p class="display-6 mb-0"><c:out value="${stats.revenue}" /></p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Top sản phẩm</h5>
          <ol class="mb-0">
            <c:forEach var="row" items="${stats.topProducts}">
              <li><c:out value="${row[0]}" /> — SL: <c:out value="${row[1]}"/></li>
            </c:forEach>
          </ol>
        </div>
      </div>
    </div>
  </div>

  <hr class="my-4"/>

  <div class="card shadow-sm">
    <div class="card-body">
      <h5 class="card-title mb-3">Biểu đồ doanh thu theo tháng</h5>
      <canvas id="revChart" height="120"></canvas>
    </div>
  </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
  fetch('<c:url value="/vendor/statistics"/>')
    .then(r => r.json())
    .then(({labels, values}) => {
      const ctx = document.getElementById('revChart');
      new Chart(ctx, {
        type: 'bar',
        data: { labels, datasets: [{ label: 'Doanh thu', data: values, backgroundColor: '#60a5fa' }] },
        options: { responsive: true }
      });
    });
</script>
