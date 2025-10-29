// filepath: src/main/webapp/WEB-INF/views/vendor/vouchers.jsp

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="mb-0">Voucher</h2>
    <div class="d-flex gap-2">
      <a class="btn btn-primary" href="${ctx}/vendor/vouchers/new">+ Tạo voucher</a>
    </div>
  </div>

  <%-- Hiển thị thông báo lỗi (nếu có) --%>
  <c:if test="${not empty errors}">
    <div class="alert alert-danger">
      <ul class="mb-0">
        <c:forEach var="e" items="${errors}">
          <li><c:out value="${e}"/></li>
        </c:forEach>
      </ul>
    </div>
  </c:if>

  <div class="card shadow-sm mb-3">
    <div class="card-body">
      <h5 class="card-title">Tìm kiếm & Lọc</h5>
      <form method="get" action="${ctx}/vendor/vouchers" class="row g-2">
        <div class="col-md-3">
          <input class="form-control" name="q" placeholder="Tìm theo code..." value="${q}"/>
        </div>
        <div class="col-md-2">
          <select class="form-select" name="type">
            <option value="" ${empty type ? 'selected' : ''}>-- Loại --</option>
            <option value="PERCENT" ${type == 'PERCENT' ? 'selected' : ''}>PERCENT</option>
            <option value="AMOUNT" ${type == 'AMOUNT' ? 'selected' : ''}>AMOUNT</option>
          </select>
        </div>
        <div class="col-md-2">
          <select class="form-select" name="status">
            <option value="" ${empty status ? 'selected' : ''}>-- Trạng thái --</option>
            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
            <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
          </select>
        </div>
        <div class="col-md-2">
          <input class="form-control" type="datetime-local" name="from" value="${from}" placeholder="Từ"/>
        </div>
        <div class="col-md-2">
          <input class="form-control" type="datetime-local" name="to" value="${to}" placeholder="Đến"/>
        </div>
        <div class="col-md-1">
          <select class="form-select" name="size">
            <c:set var="sz" value="${size != null ? size : 10}"/>
            <option ${sz == 10 ? 'selected' : ''} value="10">10</option>
            <option ${sz == 20 ? 'selected' : ''} value="20">20</option>
            <option ${sz == 50 ? 'selected' : ''} value="50">50</option>
          </select>
        </div>
        <div class="col-md-12 d-flex justify-content-end">
          <button class="btn btn-outline-secondary">Lọc</button>
        </div>
      </form>
    </div>
  </div>

  <div class="card shadow-sm">
    <div class="card-body">
      <h5 class="card-title">Danh sách voucher</h5>
      <div class="table-responsive">
        <table class="table table-bordered align-middle mb-0">
          <thead class="table-light">
          <tr>
            <th>ID</th>
            <th>Code</th>
            <th>Loại</th>
            <th>Giá trị</th>
            <th>Min Order</th>
            <th>Hiệu lực</th>
            <th>Trạng thái</th>
            <th width="180">Hành động</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach var="v" items="${vouchers}">
            <tr data-row-id="${v.voucherId}">
              <td>${v.voucherId}</td>
              <td><span class="fw-semibold"><c:out value="${v.code}"/></span></td>
              <td>${v.type}</td>
              <td>
                <c:choose>
                  <c:when test="${v.type == 'PERCENT'}">
                    ${v.percent}%
                  </c:when>
                  <c:otherwise>
                    ${v.amount}
                  </c:otherwise>
                </c:choose>
              </td>
              <td>${v.minOrderAmount}</td>
              <td>
                <div><small>Bắt đầu:</small> ${v.startAt}</div>
                <div><small>Kết thúc:</small> ${v.endAt}</div>
              </td>
              <td>
                <span class="badge status-badge bg-${v.status == 'ACTIVE' ? 'success' : 'secondary'}">
                  ${v.status}
                </span>
              </td>
              <td class="d-flex gap-2">
                <a class="btn btn-sm btn-outline-primary" href="${ctx}/vendor/vouchers/edit?id=${v.voucherId}">Sửa</a>
                <button type="button"
                        class="btn btn-sm btn-toggle ${v.status == 'ACTIVE' ? 'btn-outline-danger' : 'btn-outline-success'}"
                        data-id="${v.voucherId}">
                  ${v.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'}
                </button>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </div>

      <c:if test="${totalPages > 1}">
        <nav class="mt-3">
          <ul class="pagination mb-0">
            <c:set var="cur" value="${page}"/>
            
            <%-- Nút Previous --%>
            <li class="page-item ${cur <= 1 ? 'disabled' : ''}">
              <a class="page-link"
                 href="<c:url value='/vendor/vouchers'>
                         <c:param name='page' value='${cur-1}'/>
                         <c:param name='size' value='${size}'/>
                         <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                         <c:if test='${not empty type}'><c:param name='type' value='${type}'/></c:if>
                         <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                         <c:if test='${not empty from}'><c:param name='from' value='${from}'/></c:if>
                         <c:if test='${not empty to}'><c:param name='to' value='${to}'/></c:if>
                       </c:url>">Prev</a>
            </li>

            <%-- Các nút số trang --%>
            <c:forEach var="i" begin="1" end="${totalPages}">
              <li class="page-item ${i == cur ? 'active' : ''}">
                <a class="page-link"
                   href="<c:url value='/vendor/vouchers'>
                           <c:param name='page' value='${i}'/>
                           <c:param name='size' value='${size}'/>
                           <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                           <c:if test='${not empty type}'><c:param name='type' value='${type}'/></c:if>
                           <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                           <c:if test='${not empty from}'><c:param name='from' value='${from}'/></c:if>
                           <c:if test='${not empty to}'><c:param name='to' value='${to}'/></c:if>
                         </c:url>">${i}</a>
              </li>
            </c:forEach>

            <%-- Nút Next --%>
            <li class="page-item ${cur >= totalPages ? 'disabled' : ''}">
              <a class="page-link"
                 href="<c:url value='/vendor/vouchers'>
                         <c:param name='page' value='${cur+1}'/>
                         <c:param name='size' value='${size}'/>
                         <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                         <c:if test='${not empty type}'><c:param name='type' value='${type}'/></c:if>
                         <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                         <c:if test='${not empty from}'><c:param name='from' value='${from}'/></c:if>
                         <c:if test='${not empty to}'><c:param name='to' value='${to}'/></c:if>
                       </c:url>">Next</a>
            </li>
          </ul>
        </nav>
      </c:if>
    </div>
  </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function () {
  const $$ = (q, el = document) => Array.from(el.querySelectorAll(q));
  
  $$('.btn-toggle').forEach(btn => {
    btn.addEventListener('click', async () => {
      const id = btn.dataset.id;
      // Xác nhận trước khi thực hiện toggle (Optional: có thể thêm SweetAlert hoặc modal)
      // if (!confirm('Bạn có chắc muốn thay đổi trạng thái voucher này?')) return;

      try {
        const res = await fetch('<c:url value="/vendor/vouchers/toggle"/>', {
          method: 'POST',
          headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
          body: new URLSearchParams({id})
        });
        
        const data = await res.json();
        
        if (!res.ok || !data.ok) { 
          alert(data.message || 'Lỗi thao tác'); 
          return; 
        }

        // Cập nhật giao diện sau khi thành công
        const newStatus = data.status;
        const row = btn.closest('tr');
        const badge = row.querySelector('.status-badge');
        
        // Cập nhật Badge
        if (badge) {
          badge.textContent = newStatus;
          badge.classList.remove('bg-success', 'bg-secondary');
          badge.classList.add(newStatus === 'ACTIVE' ? 'bg-success' : 'bg-secondary');
        }
        
        // Cập nhật Button
        btn.classList.remove('btn-outline-danger', 'btn-outline-success');
        if (newStatus === 'ACTIVE') {
          btn.classList.add('btn-outline-danger'); 
          btn.textContent = 'Ẩn';
        } else {
          btn.classList.add('btn-outline-success'); 
          btn.textContent = 'Hiện';
        }
        
      } catch (e) {
        console.error("Toggle Error:", e);
        alert('Lỗi kết nối hoặc lỗi máy chủ.');
      }
    });
  });
});
</script>