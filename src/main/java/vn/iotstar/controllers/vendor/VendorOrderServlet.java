package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import vn.iotstar.entities.Order;
import vn.iotstar.entities.Shop;
import vn.iotstar.services.OrderService;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/orders"})
public class VendorOrderServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();
    private final StatisticService helper = new StatisticService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // check đăng nhập + đúng role Vendor
        Long uid = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        if (uid == null || !"VENDOR".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // lấy shop của vendor
        Shop shop = helper.findShopByOwner(uid);
        if (shop == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Vendor chưa có shop");
            return;
        }

        // lọc theo trạng thái (có thể null -> lấy tất cả)
        String status = req.getParameter("status"); // NEW/CONFIRMED/SHIPPING/DONE/CANCELLED
        List<Order> orders = orderService.getOrdersByStatus(shop.getShopId(), status);

        req.setAttribute("orders", orders);
        req.setAttribute("status", status);
        req.getRequestDispatcher("/WEB-INF/views/vendor/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // đổi trạng thái đơn hàng
        Long uid = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        if (uid == null || !"VENDOR".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Long orderId = Long.valueOf(req.getParameter("orderId"));
        String newStatus = req.getParameter("newStatus");
        orderService.updateStatus(orderId, newStatus);

        resp.sendRedirect(req.getContextPath() + "/vendor/orders");
    }
}
