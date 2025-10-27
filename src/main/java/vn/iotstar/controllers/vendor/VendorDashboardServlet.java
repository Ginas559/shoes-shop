// filepath: src/main/java/vn/iotstar/controllers/vendor/VendorDashboardServlet.java
package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

import vn.iotstar.entities.Shop;
import vn.iotstar.entities.User;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/dashboard"})
public class VendorDashboardServlet extends HttpServlet {
    private final StatisticService statisticService = new StatisticService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long uid  = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        HttpSession ss = req.getSession(false);
        Long staffShopId = (ss != null && ss.getAttribute("staffShopId") != null)
                ? (Long) ss.getAttribute("staffShopId") : null;

        boolean isVendor = "VENDOR".equals(role);
        boolean isStaff  = "USER".equals(role) && (staffShopId != null);

        if (uid == null || (!isVendor && !isStaff)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Shop shop = null;
        if (isVendor) {
            shop = statisticService.findShopByOwner(uid);
        } else {
            Long sid = staffShopId;
            if (sid == null && ss != null) {
                Object cu = ss.getAttribute("currentUser");
                if (cu instanceof User u && u.getStaffShop() != null) {
                    sid = u.getStaffShop().getShopId();
                    ss.setAttribute("staffShopId", sid);
                }
            }
            if (sid != null) shop = statisticService.findShopById(sid);
        }

        if (shop == null) {
            if (isVendor) {
                resp.sendRedirect(req.getContextPath() + "/vendor/shop/create");
            } else {
                req.getSession().setAttribute("error", "Bạn chưa có quyền vào khu quản lý shop.");
                resp.sendRedirect(req.getContextPath() + "/");
            }
            return;
        }

        Map<String, Object> stats = statisticService.getDashboardData(shop.getShopId());

        // ⭐️ Thêm dòng này để JSP dùng ${shop.shopId} cho nút chat
        req.setAttribute("shop", shop);
        req.setAttribute("stats", stats);

        req.getRequestDispatcher("/WEB-INF/views/vendor/dashboard.jsp").forward(req, resp);
    }
}
