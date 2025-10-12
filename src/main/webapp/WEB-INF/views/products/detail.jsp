<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:choose>
  <c:when test="${not empty product}">
    <div class="row g-3">
      <div class="col-12 col-md-6">
        <img class="img-fluid rounded border"
             src="${empty images ? (ctx.concat('/assets/img/placeholder.png')) : images[0]}"
             alt="<c:out value='${product.productName}'/>">
        <div class="d-flex gap-2 mt-2 flex-wrap">
          <c:forEach var="img" items="${images}">
            <img src="${img}" style="width:80px;height:80px;object-fit:cover" class="rounded border"/>
          </c:forEach>
        </div>
      </div>
      <div class="col-12 col-md-6">
        <h1 class="h5"><c:out value="${product.productName}"/></h1>
        <div class="text-muted mb-2">
          <c:out value="${product.category != null ? product.category.categoryName : ''}"/>
        </div>
        <div class="fs-4 fw-bold">
          <c:choose>
            <c:when test="${not empty product.discountPrice}">${product.discountPrice}</c:when>
            <c:otherwise>${product.price}</c:otherwise>
          </c:choose>
        </div>
        <p class="mt-3"><c:out value="${product.description}"/></p>
        <small class="text-muted d-block">(*Giỏ hàng/Like sẽ bật khi nối backend sau.)</small>
      </div>
    </div>
  </c:when>
  <c:otherwise>
    <div class="text-center text-muted py-5">Không tìm thấy sản phẩm.</div>
  </c:otherwise>
</c:choose>
