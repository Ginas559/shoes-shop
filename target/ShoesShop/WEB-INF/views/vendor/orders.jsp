<!-- filepath: src/main/webapp/WEB-INF/views/vendor/orders.jsp -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="statuses" value="NEW,CONFIRMED,SHIPPING,DONE,CANCELLED"/>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h2 class="mb-0">Đơn hàng của shop</h2>
    <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/vendor/dashboard">← Về Dashboard</a>
  </div>

  <!-- Filter trạng thái + tìm theo tên/email + page size -->
  <form class="row g-2 mb-3" method="get" action="${pageContext.request.contextPath}/vendor/orders">
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
              <td>${o.orderId}</td>
              <td>${o.user.firstname} ${o.user.lastname}</td>
              <td>${o.totalAmount}</td>
              <td><span class="badge bg-secondary">${o.status}</span></td>
              <td>${o.createdAt}</td>
              <td>
                <form method="post" action="${pageContext.request.contextPath}/vendor/orders" class="d-flex gap-2">
                  <input type="hidden" name="orderId" value="${o.orderId}"/>
                  <select name="newStatus" class="form-select form-select-sm">
                    <c:forEach var="st" items="${fn:split(statuses, ',')}">
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

      <!-- NEW: pagination -->
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
