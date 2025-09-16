<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Product List</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-5">
    <h2>Product List</h2>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Brand</th>
                <th>Price</th>
                <th>Discount Price</th>
                <th>Status</th>
                <th>Sold Count</th>
                <th>Rating Avg</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="p" items="${products}">
                <tr>
                    <td>${p.id}</td>
                    <td>${p.name}</td>
                    <td>${p.brand}</td>
                    <td>${p.price}</td>
                    <td>${p.discountPrice}</td>
                    <td>${p.status}</td>
                    <td>${p.soldCount}</td>
                    <td>${p.ratingAvg}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>
