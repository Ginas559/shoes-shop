// filepath: src/main/java/vn/iotstar/controllers/vendor/VendorOrderServlet.java
package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Objects;

import vn.iotstar.entities.Order;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.User;
import vn.iotstar.services.OrderService;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/orders"})
public class VendorOrderServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();
    private final StatisticService helper = new StatisticService();

    /**
     * Gợi nhớ về JWT:
     * - AuthFilter (JWT) gắn sẵn vào request: uid, role, shopId. Nếu có thì ưu tiên dùng để xác định shop.
     * - Nếu không có JWT, quay về cơ chế session như hiện tại (giữ staffShopId cho staff).
     */
    private Shop resolveShop(HttpServletRequest req) {
        // Ưu tiên JWT: đọc role/shopId do AuthFilter gắn
        Object jwtRoleObj = req.getAttribute("role");
        Object jwtShopIdObj = req.getAttribute("shopId");
        String jwtRole = (jwtRoleObj instanceof String) ? (String) jwtRoleObj : null;
        Long jwtShopId = (jwtShopIdObj instanceof Long) ? (Long) jwtShopIdObj : null;

        if ("VENDOR".equals(jwtRole) && jwtShopId != null) {
            return helper.findShopById(jwtShopId);
        }

        // Fallback session như code cũ
        Long uid  = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        HttpSession ss = req.getSession(false);
        Long staffShopId = (ss != null && ss.getAttribute("staffShopId") != null)
                ? (Long) ss.getAttribute("staffShopId") : null;

        if ("VENDOR".equals(role)) return helper.findShopByOwner(uid);

        if ("USER".equals(role)) {
            Long sid = staffShopId;
            if (sid == null && ss != null) {
                Object cu = ss.getAttribute("currentUser");
                if (cu instanceof User u && u.getStaffShop() != null) {
                    sid = u.getStaffShop().getShopId();
                    ss.setAttribute("staffShopId", sid);
                }
            }
            return (sid != null) ? helper.findShopById(sid) : null;
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Shop shop = resolveShop(req);
        if (shop == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không xác định được shop.");
            return;
        }

        String status = req.getParameter("status"); // NEW/CONFIRMED/SHIPPING/DONE/CANCELLED
        List<Order> orders = orderService.getOrdersByStatus(shop.getShopId(), status);

        req.setAttribute("orders", orders);
        req.setAttribute("status", status);
        req.getRequestDispatcher("/WEB-INF/views/vendor/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Shop shop = resolveShop(req);
        if (shop == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không xác định được shop.");
            return;
        }

        // Gợi nhớ: chỉ thao tác đơn thuộc shopId đã xác định ở trên
        Long orderId;
        try {
            orderId = Long.valueOf(req.getParameter("orderId"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu hoặc sai orderId");
            return;
        }
        String newStatus = req.getParameter("newStatus");

        Order o = orderService.findById(orderId);
        if (o == null || o.getShop() == null
                || !Objects.equals(o.getShop().getShopId(), shop.getShopId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền cập nhật đơn này.");
            return;
        }

        orderService.updateStatus(orderId, newStatus);
        resp.sendRedirect(req.getContextPath() + "/vendor/orders");
    }
}
