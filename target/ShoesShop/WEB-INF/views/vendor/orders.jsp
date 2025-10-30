<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Đã thêm: Định nghĩa biến context path để sử dụng nhất quán --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:set var="statuses" value="NEW,CONFIRMED,SHIPPING,DONE,CANCELLED"/>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h2 class="mb-0">Đơn hàng của shop</h2>
    <a class="btn btn-outline-secondary btn-sm" href="${ctx}/vendor/dashboard">← Về Dashboard</a>
  </div>

  <%-- Khung Flash Message --%>
  <c:if test="${not empty flashMsg}">
    <div class="alert alert-${empty flashType ? 'info' : flashType} alert-dismissible fade show" role="alert">
      ${flashMsg}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  </c:if>

  <form class="row g-2 mb-3" method="get" action="${ctx}/vendor/orders">
    <div class="col-md-3">
      <input class="form-control" name="q" placeholder="Tìm khách (tên/email)..." value="${q}"/>
    </div>
    <div class="col-md-3">
      <select name="status" class="form-select">
        <option value="">-- Tất cả trạng thái --</option>
        <c:forEach var="st" items="${fn:split(statuses, ',')}">
          <option value="${st}" <c:if test="${st eq status}">selected</c:if>>${st}</option>
        </c:forEach>
      </select>
    </div>
    <div class="col-md-2">
      <select name="size" class="form-select">
        <c:set var="sz" value="${size!=null?size:20}"/>
        <option value="10"  ${sz==10 ? 'selected':''}>10 / trang</option>
        <option value="20"  ${sz==20 ? 'selected':''}>20 / trang</option>
        <option value="50"  ${sz==50 ? 'selected':''}>50 / trang</option>
      </select>
    </div>
    <div class="col-md-2">
      <button class="btn btn-primary w-100">Lọc</button>
    </div>
  </form>

  <div class="card shadow-sm">
    <div class="card-body">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <p class="text-muted mb-0">
          Hiển thị ${fn:length(orders)} trên ${totalItems} kết quả.
        </p>
      </div>

      <div class="table-responsive">
        <table class="table table-striped align-middle">
          <thead class="table-light">
          <tr>
            <th>ID</th>
            <th>Khách hàng</th>
            <th>Tổng tiền</th>
            <th>Trạng thái</th>
            <th>Ngày tạo</th>
            <th width="220">Cập nhật</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach var="o" items="${orders}">
            <tr>
              <td>
                ${o.orderId}
                <button type="button" class="btn btn-link btn-sm p-0 ms-2 js-detail" data-id="${o.orderId}" title="Xem chi tiết và tồn kho">
                  Chi tiết
                </button>
              </td>
              <td>${o.user.firstname} ${o.user.lastname}</td>
              <td>${o.totalAmount}</td>
              <td><span class="badge bg-secondary">${o.status}</span></td>
              <td>${o.createdAt}</td>
              <td>
                <form method="post" action="${ctx}/vendor/orders" class="d-flex gap-2">
                  <input type="hidden" name="orderId" value="${o.orderId}"/>
                  <input type="hidden" name="page" value="${page}"/> 
                  <c:if test="${not empty status}"><input type="hidden" name="status" value="${status}"/></c:if>
                  <c:if test="${not empty q}"><input type="hidden" name="q" value="${q}"/></c:if>
                  
                  <select name="newStatus" class="form-select form-select-sm">
                    <c:forEach var="st" items="${fn:split(statuses, ',')}">
                      <%-- Đã sửa lỗi unbalanced tag --%>
                      <option value="${st}" <c:if test="${st eq o.status.name()}">selected</c:if>>${st}</option>
                    </c:forEach>
                  </select>
                  <button class="btn btn-sm btn-primary" type="submit">Lưu</button>
                </form>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty orders}">
            <tr><td colspan="6" class="text-muted">Không có đơn phù hợp.</td></tr>
          </c:if>
          </tbody>
        </table>
      </div>

      <c:if test="${totalPages > 1}">
        <nav>
          <ul class="pagination">
            <c:set var="cur" value="${page}" />
            <li class="page-item ${cur<=1?'disabled':''}">
              <a class="page-link"
                 href="<c:url value='/vendor/orders'>
                          <c:param name='page' value='${cur-1}'/>
                          <c:param name='size' value='${size}'/>
                          <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                          <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                        </c:url>">Prev</a>
            </li>
            <c:forEach var="i" begin="1" end="${totalPages}">
              <li class="page-item ${i==cur?'active':''}">
                <a class="page-link"
                   href="<c:url value='/vendor/orders'>
                            <c:param name='page' value='${i}'/>
                            <c:param name='size' value='${size}'/>
                            <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                            <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                         </c:url>">${i}</a>
              </li>
            </c:forEach>
            <li class="page-item ${cur>=totalPages?'disabled':''}">
              <a class="page-link"
                 href="<c:url value='/vendor/orders'>
                          <c:param name='page' value='${cur+1}'/>
                          <c:param name='size' value='${size}'/>
                          <c:if test='${not empty q}'><c:param name='q' value='${q}'/></c:if>
                          <c:if test='${not empty status}'><c:param name='status' value='${status}'/></c:if>
                        </c:url>">Next</a>
            </li>
          </ul>
        </nav>
      </c:if>
    </div>
  </div>
</main>

<%-- Modal hiển thị chi tiết --%>
<div class="modal fade" id="orderDetailModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Chi tiết đơn hàng</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div id="orderDetailBody" class="text-center text-muted">Đang tải…</div>
      </div>
    </div>
  </div>
</div>

<%-- JavaScript xử lý Ajax và Modal --%>
<script>
document.addEventListener('DOMContentLoaded', () => {
  // Lấy giá trị context path từ JSTL và dùng biến JS cố định
  const BASE_URL = '${ctx}'; 

  // Khởi tạo Modal từ Bootstrap
  const modalEl = document.getElementById('orderDetailModal');
  const modal   = new bootstrap.Modal(modalEl);
  const body    = document.getElementById('orderDetailBody');

  async function openDetail(orderId) {
      body.innerHTML = '<div class="text-center text-muted py-3">Đang tải…</div>'; 
      modal.show();

      try {
        // Đã sửa lỗi EL: Sử dụng nối chuỗi thuần JS để gọi encodeURIComponent()
        const url = BASE_URL + '/vendor/orders/detail?orderId=' + encodeURIComponent(orderId);
        const res = await fetch(url);
        
        if (!res.ok) {
           throw new Error('Lỗi Server: ' + res.status);
        }
        
        body.innerHTML = await res.text();
      } catch (e) {
        console.error("Lỗi tải chi tiết đơn hàng:", e);
        body.innerHTML = '<div class="alert alert-danger">Không tải được chi tiết đơn hàng. Vui lòng thử lại.</div>';
      }
  }

  // Lắng nghe sự kiện click trên tất cả các nút "Chi tiết"
  document.querySelectorAll('.js-detail').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.dataset.id;
      openDetail(id); 
    });
  });
});
</script>