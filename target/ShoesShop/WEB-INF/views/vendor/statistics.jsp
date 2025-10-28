<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<head>
<title>Thống kê</title>
</head>

<main class="container py-4">
	<div
		class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
		<h2 class="mb-0">Thống kê doanh thu</h2>

		<form id="statFilter" class="row g-2">
			<div class="col-auto">
				<input type="date" class="form-control" id="statFrom"
					placeholder="From" />
			</div>
			<div class="col-auto">
				<input type="date" class="form-control" id="statTo" placeholder="To" />
			</div>
			<div class="col-auto">
				<input type="number" class="form-control" id="statYear"
					placeholder="Year (YYYY)" min="2000" max="2100" />
			</div>
			<div class="col-auto">
				<button class="btn btn-outline-primary" type="submit">Áp
					dụng</button>
			</div>
		</form>
	</div>

	<div id="totalRevenueWrap" class="alert alert-info py-2"
		style="display: none;">
		<strong>Tổng doanh thu:</strong> <span id="totalRevenueVal"></span>
	</div>

	<div class="card shadow-sm mb-3">
		<div class="card-body">
			<h5 class="card-title mb-3">Doanh thu theo tháng</h5>
			<canvas id="revenueChart" height="120"></canvas>
			<div id="noDataMsg" class="text-muted small mt-2"
				style="display: none;">Không có dữ liệu.</div>
		</div>
	</div>

	<div class="card shadow-sm" id="prodCard">
		<div class="card-body">
			<h5 class="card-title mb-3">Doanh thu theo sản phẩm (Top)</h5>
			<div class="row g-3">
				<div class="col-lg-7">
					<canvas id="prodChart" height="160"></canvas>
				</div>
				<div class="col-lg-5">
					<div class="table-responsive">
						<table class="table table-sm align-middle">
							<thead class="table-light">
								<tr>
									<th>#</th>
									<th>Sản phẩm</th>
									<th class="text-end">Doanh thu</th>
								</tr>
							</thead>
							<tbody id="prodTableBody"></tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>
</main>

<script
	src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  const chartEl = document.getElementById('revenueChart');
  const prodEl  = document.getElementById('prodChart');
  const noDataMsg = document.getElementById('noDataMsg');

  const totalWrap = document.getElementById('totalRevenueWrap');
  const totalVal  = document.getElementById('totalRevenueVal');

  const prodCard  = document.getElementById('prodCard');
  const prodTBody = document.getElementById('prodTableBody');

  let chart, prodChart;

  async function loadChart(params) {
	    const url = new URL('${ctx}/vendor/statistics', window.location.origin);
	    if (params.from) url.searchParams.set('from', params.from);
	    if (params.to)   url.searchParams.set('to', params.to);
	    if (params.year) url.searchParams.set('year', params.year);

	    const res  = await fetch(url.toString(), { headers: { "Accept": "application/json" } });
	    const data = await res.json(); // {labels,current,previous,values,productRevenue?}

	    const labels = data.labels || [];
	    const cur = data.current || data.values || [];
	    const pre = data.previous || [];

	    const isEmpty = (!labels.length) || (cur.every(v => (+v)===0) && (!pre.length || pre.every(v => (+v)===0)));
	    noDataMsg.style.display = isEmpty ? 'block' : 'none';

	    const total = (cur || []).reduce((s,v)=>s+(Number(v)||0),0);
	    if (total > 0) {
	      totalVal.textContent = Number(total).toLocaleString('vi-VN',{style:'currency',currency:'VND'});
	      totalWrap.style.display = 'block';
	    } else totalWrap.style.display = 'none';

	    if (chart) chart.destroy();
	    chart = new Chart(chartEl, {
	      type: 'bar',
	      data: { labels, datasets: [
	        { label: 'Năm hiện tại', data: cur },
	        { label: 'Năm trước',   data: pre }
	      ]},
	      options: {
	        responsive: true,
	        scales: { y: { beginAtZero: true } },
	        plugins: { tooltip: { callbacks: {
	          label: (ctx) => {
	            const v = ctx.parsed?.y ?? ctx.raw ?? 0;
	            return ctx.dataset.label + ': ' + Number(v).toLocaleString('vi-VN') + ' ₫';
	          }
	        }}}
	      }
	    });

	    const prod = Array.isArray(data.productRevenue) ? data.productRevenue : [];
	    
	    // 💥 ĐẢM BẢO KHUNG SẢN PHẨM LUÔN HIỆN
	    prodCard.style.display = 'block'; 
	    
	    if (prod.length) {
	      // Logic cũ: prodCard.style.display = 'block'; // Đã chuyển ra ngoài
	      const top = [...prod].sort((a,b)=>Number(b.total)-Number(a.total)).slice(0,10);
	      const pLabels = top.map(x=>x.product);
	      const pValues = top.map(x=>Number(x.total)||0);

	      if (prodChart) prodChart.destroy();
	      prodChart = new Chart(prodEl, {
	        type: 'bar',
	        data: { labels: pLabels, datasets: [{ label: 'Doanh thu', data: pValues }] },
	        options: {
	          responsive: true,
	          indexAxis: 'y',
	          scales: { x: { beginAtZero: true } },
	          plugins: { tooltip: { callbacks: {
	            label: (ctx) => {
	              const v = ctx.parsed?.x ?? ctx.raw ?? 0;
	              return Number(v).toLocaleString('vi-VN') + ' ₫';
	            }
	          }}}
	        }
	      });

	      // Hiển thị dữ liệu trong bảng
	      prodTBody.innerHTML = top.map((x,i)=>(
	        '<tr>' +
	          '<td>' + (i+1) + '</td>' +
	          '<td><span class="text-truncate d-inline-block" style="max-width:220px" title="' + x.product + '">' + x.product + '</span></td>' +
	          '<td class="text-end">' + Number(x.total||0).toLocaleString('vi-VN') + ' ₫</td>' +
	        '</tr>')).join('');

	    } else {
	      // Khung vẫn hiện, nhưng biểu đồ bị huỷ và bảng rỗng
	      prodTBody.innerHTML = '<tr><td colspan="3" class="text-center text-muted">Không có dữ liệu sản phẩm trong phạm vi này.</td></tr>';
	      if (prodChart) { prodChart.destroy(); prodChart = null; }
	    }
	  }

	  document.getElementById('statFilter').addEventListener('submit', (e)=>{
	    e.preventDefault();
	    const year = (document.getElementById('statYear').value||'').trim();
	    const from = (document.getElementById('statFrom').value||'').trim();
	    const to   = (document.getElementById('statTo').value||'').trim();
	    if (year) loadChart({year}); else loadChart({from: from||null, to: to||null});
	  });

	  loadChart({});
	</script>