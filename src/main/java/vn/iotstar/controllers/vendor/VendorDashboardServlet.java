package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

import vn.iotstar.entities.Shop;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/dashboard"})
public class VendorDashboardServlet extends HttpServlet {
    private final StatisticService statisticService = new StatisticService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long uid = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        if (uid == null || !"VENDOR".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Shop shop = statisticService.findShopByOwner(uid);
        if (shop == null) {
            resp.sendRedirect(req.getContextPath() + "/vendor/shop/create");
            return;
        }

        Map<String, Object> stats = statisticService.getDashboardData(shop.getShopId());
        req.setAttribute("stats", stats);
        req.getRequestDispatcher("/WEB-INF/views/vendor/dashboard.jsp").forward(req, resp);
    }
}
