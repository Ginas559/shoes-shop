// filepath: src/main/java/vn/iotstar/controllers/vendor/VendorOrderServlet.java

package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
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

    // ⭐ NEW: Hàm tiện ích để parse Integer an toàn
    private static int pi(String s, int d) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return d;
        }
    }

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

        // ⭐ NEW: Đọc tham số q, page, size
        String status = req.getParameter("status"); // Trạng thái lọc
        String q = req.getParameter("q");           // Chuỗi tìm kiếm tên/email khách hàng
        int page = pi(req.getParameter("page"), 1); // Trang hiện tại (mặc định 1)
        int size = pi(req.getParameter("size"), 20); // Kích thước trang (mặc định 20)
        
        // ⭐ NEW: Sử dụng phương thức findByShopPaged
        OrderService.PageResult<Order> pr = orderService.findByShopPaged(
                shop.getShopId(), status, q, page, size);

        // ⭐ NEW: Gắn tất cả thông tin phân trang lên request
        req.setAttribute("orders", pr.items); // Danh sách đơn hàng cho trang hiện tại
        req.setAttribute("page", pr.page);
        req.setAttribute("size", pr.size);
        req.setAttribute("totalPages", pr.totalPages);
        req.setAttribute("totalItems", pr.totalItems);
        
        // Gắn lại các tham số lọc/tìm kiếm để giữ trạng thái trên giao diện
        req.setAttribute("status", status);
        req.setAttribute("q", q); 
        
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
        
        // Sau khi update, redirect về trang danh sách (nên giữ lại tham số trạng thái hiện tại nếu cần)
        // Hiện tại chỉ redirect về /vendor/orders (trang 1, mặc định)
        resp.sendRedirect(req.getContextPath() + "/vendor/orders");
    }
}