<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ - UTE Shop</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container mt-4">
    <h2 class="mb-4 text-center">Sản phẩm mới nhất</h2>

    <div class="row">
        <c:forEach var="p" items="${products}">
            <div class="col-md-3 mb-4">
                <div class="card h-100 shadow-sm">
                    <c:choose>
                        <c:when test="${not empty p.images}">
                            <img src="${p.images[0].url}" class="card-img-top" alt="${p.name}">
                        </c:when>
                        <c:otherwise>
                            <img src="https://via.placeholder.com/300x200?text=No+Image" class="card-img-top" alt="No image">
                        </c:otherwise>
                    </c:choose>
                    <div class="card-body">
                        <h6 class="card-title text-truncate">${p.name}</h6>
                        <p class="card-text text-danger fw-bold">
                            ${p.price} VNĐ
                        </p>
                        <a href="${pageContext.request.contextPath}/product?id=${p.id}" class="btn btn-sm btn-primary">Xem chi tiết</a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

</body>
</html>
