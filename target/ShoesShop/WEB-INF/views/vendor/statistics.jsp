<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<main class="container py-4">
  <h2 class="mb-3">Thống kê doanh thu</h2>

  <div class="card shadow-sm">
    <div class="card-body">
      <canvas id="revenueChart" height="120"></canvas>
    </div>
  </div>
</main>

<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
(async function () {
  try {
    const res = await fetch("<c:url value='/vendor/statistics'/>", { headers: { "Accept": "application/json" } });
    const data = await res.json(); // {labels:[], values:[]}

    const ctx = document.getElementById('revenueChart');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.labels,
        datasets: [{
          label: 'Doanh thu',
          data: data.values
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: { beginAtZero: true }
        }
      }
    });
  } catch (e) {
    console.error(e);
    alert('Không tải được dữ liệu thống kê.');
  }
})();
</script>
