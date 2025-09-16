package vn.iotstar.controller.shipper;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.iotstar.dao.OrderDAO;
import vn.iotstar.entity.Order;

@WebServlet("/shipper/orders")
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO dao = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        List<Order> list = dao.findAll();
        req.setAttribute("orders", list);
        req.getRequestDispatcher("/WEB-INF/views/shipper/orders-list.jsp")
           .forward(req, resp);
    }
}
