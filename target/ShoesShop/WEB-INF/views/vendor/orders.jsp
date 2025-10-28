<!-- filepath: src/main/webapp/WEB-INF/views/vendor/orders.jsp -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="statuses" value="NEW,CONFIRMED,SHIPPING,DONE,CANCELLED"/>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h2 class="mb-0">Đơn hàng của shop</h2>
    <div>
      <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/vendor/dashboard">← Về Dashboard</a>
    </div>
  </div>

  <!-- (Optional) Quick stats theo trạng thái: chỉ hiển thị nếu controller set sẵn 'statusCounts' -->
  <c:if test="${not empty statusCounts}">
    <div class="d-flex flex-wrap gap-2 mb-3">
      <c:forEach var="e" items="${statusCounts}">
        <span class="badge bg-light text-dark border">
          <strong>${e.key}</strong>: ${e.value}
        </span>
      </c:forEach>
    </div>
  </c:if>

  <!-- Filter trạng thái -->
  <form class="row g-2 mb-3" method="get" action="${pageContext.request.contextPath}/vendor/orders">
    <div class="col-auto">
      <label class="visually-hidden">Trạng thái</label>
      <select name="status" class="form-select">
        <option value="">-- Tất cả trạng thái --</option>
        <c:forEach var="st" items="${fn:split(statuses, ',')}">
          <option value="${st}" <c:if test="${st eq status}">selected="selected"</c:if>>${st}</option>
        </c:forEach>
      </select>
    </div>
    <div class="col-auto">
      <button class="btn btn-primary" type="submit">Lọc</button>
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
                      <option value="${st}" <c:if test="${st eq o.status.name()}">selected="selected"</c:if>>${st}</option>
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
    </div>
  </div>
</main>
