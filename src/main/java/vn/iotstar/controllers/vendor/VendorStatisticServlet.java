package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

import com.google.gson.Gson;
import vn.iotstar.entities.Shop;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/statistics", "/vendor/statistics/view"})
public class VendorStatisticServlet extends HttpServlet {
    private final StatisticService statisticService = new StatisticService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Nếu gọi /vendor/statistics/view => Trả UI (JSP)
        String servletPath = req.getServletPath();
        if ("/vendor/statistics/view".equals(servletPath)) {
            req.setAttribute("pageTitle", "Thống kê");
            req.getRequestDispatcher("/WEB-INF/views/vendor/statistics.jsp").forward(req, resp);
            return;
        }

        // Mặc định: /vendor/statistics => JSON
        resp.setContentType("application/json; charset=UTF-8");

        Long uid = SessionUtil.currentUserId(req);
        if (uid == null) {
            resp.getWriter().write("{\"labels\":[],\"values\":[]}");
            return;
        }

        Shop shop = statisticService.findShopByOwner(uid);
        if (shop == null) {
            resp.getWriter().write("{\"labels\":[],\"values\":[]}");
            return;
        }

        List<Object[]> rows = statisticService.getRevenueByMonth(shop.getShopId());

        List<String> labels = new ArrayList<>();
        List<BigDecimal> values = new ArrayList<>();
        for (Object[] r : rows) {
            int month = (r[0] instanceof Number) ? ((Number) r[0]).intValue() : Integer.parseInt(r[0].toString());
            BigDecimal total = (r[1] instanceof BigDecimal) ? (BigDecimal) r[1] : new BigDecimal(r[1].toString());
            labels.add("Tháng " + month);
            values.add(total);
        }
        resp.getWriter().write(gson.toJson(Map.of("labels", labels, "values", values)));
    }
}
