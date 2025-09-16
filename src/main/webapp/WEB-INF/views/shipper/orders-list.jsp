<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Order List</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-5">
    <h2>Order List</h2>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Address</th>
                <th>Created At</th>
                <th>Subtotal</th>
                <th>Shipping Fee</th>
                <th>Discount</th>
                <th>Total</th>
                <th>Order Status</th>
                <th>Payment Method</th>
                <th>Payment Status</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="o" items="${orders}">
                <tr>
                    <td>${o.id}</td>
                    <td>${o.addressSnapshotJson}</td>
                    <td>${o.createdAt}</td>
                    <td>${o.subtotal}</td>
                    <td>${o.shippingFee}</td>
                    <td>${o.discount}</td>
                    <td>${o.total}</td>
                    <td>${o.orderStatus}</td>
                    <td>${o.paymentMethod}</td>
                    <td>${o.paymentStatus}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>
