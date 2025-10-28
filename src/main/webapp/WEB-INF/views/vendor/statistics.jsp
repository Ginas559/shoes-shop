<!-- filepath: src/main/webapp/WEB-INF/views/vendor/statistics.jsp -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h2 class="mb-0">Thống kê doanh thu</h2>

    <!-- Bộ lọc thời gian (gọi JSON API) -->
    <form id="statFilter" class="row g-2">
      <div class="col-auto">
        <input type="date" class="form-control" id="statFrom" placeholder="From"/>
      </div>
      <div class="col-auto">
        <input type="date" class="form-control" id="statTo" placeholder="To"/>
      </div>
      <div class="col-auto">
        <input type="number" class="form-control" id="statYear" placeholder="Year (YYYY)" min="2000" max="2100"/>
      </div>
      <div class="col-auto">
        <button class="btn btn-outline-primary" type="submit">Áp dụng</button>
      </div>
    </form>
  </div>

  <div class="card shadow-sm">
    <div class="card-body">
      <h5 class="card-title mb-3">Doanh thu theo tháng</h5>
      <canvas id="revenueChart" height="120"></canvas>
    </div>
  </div>
</main>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  const chartEl = document.getElementById('revenueChart');
  let chart;

  async function loadChart(params) {
    const url = new URL('${ctx}/vendor/statistics', window.location.origin);
    if (params.from) url.searchParams.set('from', params.from);
    if (params.to) url.searchParams.set('to', params.to);
    if (params.year) url.searchParams.set('year', params.year);

    const res = await fetch(url.toString(), { headers: { "Accept": "application/json" } });
    const data = await res.json(); // {labels:[], values:[]}

    if (chart) chart.destroy();
    chart = new Chart(chartEl, {
      type: 'bar',
      data: { labels: data.labels, datasets: [{ label: 'Doanh thu', data: data.values }] },
      options: { responsive: true, scales: { y: { beginAtZero: true } } }
    });
  }

  // Submit filter → reload chart
  document.getElementById('statFilter').addEventListener('submit', function (e) {
    e.preventDefault();
    loadChart({
      from: document.getElementById('statFrom').value || null,
      to: document.getElementById('statTo').value || null,
      year: document.getElementById('statYear').value || null,
    });
  });

  // First load
  loadChart({});
</script>
