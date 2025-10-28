// src/main/java/vn/iotstar/controllers/vendor/VendorDashboardServlet.java

package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.YearMonth;
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

        Long uid = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        HttpSession ss = req.getSession(false);
        Long staffShopId = (ss != null && ss.getAttribute("staffShopId") != null)
                ? (Long) ss.getAttribute("staffShopId") : null;

        boolean isVendor = "VENDOR".equals(role);
        boolean isStaff = "USER".equals(role) && (staffShopId != null);

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

        // === Filters (optional) ===
        LocalDate from = parseDate(req.getParameter("from"));
        LocalDate to = parseDate(req.getParameter("to"));
        Integer year = parseInt(req.getParameter("year"));

        Map<String, Object> stats = statisticService.getDashboardData(shop.getShopId());
        var revenueRows = statisticService.getRevenueByMonth(shop.getShopId(), year, from, to);
        var statusCounts = statisticService.countOrdersByStatus(shop.getShopId(), from, to);
        var recentOrders = statisticService.findRecentOrders(shop.getShopId(), 5);
        var mom = statisticService.calcMonthOverMonthGrowth(shop.getShopId(), YearMonth.now());

        // ⭐️ Attributes cho JSP
        req.setAttribute("shop", shop);
        req.setAttribute("stats", stats);
        req.setAttribute("revenueRows", revenueRows);       // List<Object[]> {month, sum}
        req.setAttribute("statusCounts", statusCounts);     // Map<Status, Long>
        req.setAttribute("recentOrders", recentOrders);     // List<Order>
        req.setAttribute("growthPercent", mom);             // BigDecimal
        req.setAttribute("filterFrom", from);
        req.setAttribute("filterTo", to);
        req.setAttribute("filterYear", year);

        req.getRequestDispatcher("/WEB-INF/views/vendor/dashboard.jsp").forward(req, resp);
    }

    private LocalDate parseDate(String s) {
        try {
            return (s == null || s.isBlank()) ? null : LocalDate.parse(s);
        } catch (Exception e) {
            return null;
        }
    }

    private Integer parseInt(String s) {
        try {
            return (s == null || s.isBlank()) ? null : Integer.valueOf(s);
        } catch (Exception e) {
            return null;
        }
    }
}