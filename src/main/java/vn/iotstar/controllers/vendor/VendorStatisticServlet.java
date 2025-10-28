// filepath: src/main/java/vn/iotstar/controllers/vendor/VendorStatisticServlet.java
package vn.iotstar.controllers.vendor;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import vn.iotstar.entities.Shop;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/statistics", "/vendor/statistics/view"})
public class VendorStatisticServlet extends HttpServlet {

    private final StatisticService statisticService = new StatisticService();
    private final Gson gson = new Gson();

 // filepath: src/main/java/vn/iotstar/controllers/vendor/VendorStatisticServlet.java

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String servletPath = req.getServletPath();
        if ("/vendor/statistics/view".equals(servletPath)) {
            req.setAttribute("pageTitle", "Thống kê");
            req.getRequestDispatcher("/WEB-INF/views/vendor/statistics.jsp").forward(req, resp);
            return;
        }

        resp.setContentType("application/json; charset=UTF-8");

        Long uid = SessionUtil.currentUserId(req);
        if (uid == null) {
            resp.getWriter().write("{\"labels\":[],\"current\":[],\"previous\":[],\"values\":[],\"productRevenue\":[]}");
            return;
        }

        Shop shop = statisticService.findShopByOwner(uid);
        if (shop == null) {
            resp.getWriter().write("{\"labels\":[],\"current\":[],\"previous\":[],\"values\":[],\"productRevenue\":[]}");
            return;
        }

        LocalDate from = parseDate(req.getParameter("from"));
        LocalDate to   = parseDate(req.getParameter("to"));
        Integer year   = parseInt(req.getParameter("year"));

        // *** LOGIC XỬ LÝ LỌC VÀ LẤY DỮ LIỆU ***
        LocalDateTime start = null, end = null, prevStart = null, prevEnd = null;
        boolean hasDateFilter = false;
        
        if (year != null) {
            hasDateFilter = true;
            // Lọc theo năm
            start = LocalDate.of(year,1,1).atStartOfDay();
            end   = LocalDate.of(year, 12, 31).atTime(23, 59, 59);
            prevStart = start.minusYears(1);
            prevEnd   = end.minusYears(1);
        } else if (from != null && to != null) {
            hasDateFilter = true;
            // Lọc theo phạm vi ngày
            start = from.atStartOfDay();
            end   = to.plusDays(1).atStartOfDay().minusNanos(1);
            prevStart = start.minusYears(1);
            prevEnd   = end.minusYears(1);
        }

        Map<String,Object> series;
        List<Object[]> prodRows;
        
        if (hasDateFilter) {
            // Trường hợp 1: CÓ BỘ LỌC NGÀY/NĂM
            series = statisticService.buildMonthSeries(shop.getShopId(), start, end, prevStart, prevEnd);
            // Thống kê sản phẩm CÓ LỌC NGÀY
            prodRows = statisticService.getProductRevenueBetween(shop.getShopId(), start, end);
        } else {
            // Trường hợp 2: KHÔNG CÓ BỘ LỌC (Tải trang lần đầu)
            // Lấy dữ liệu biểu đồ tháng (mặc định lấy theo năm hiện tại)
            int currentYear = LocalDate.now().getYear();
            LocalDateTime defaultStart = LocalDate.of(currentYear,1,1).atStartOfDay();
            LocalDateTime defaultEnd   = LocalDate.of(currentYear, 12, 31).atTime(23, 59, 59);
            
            series = statisticService.buildMonthSeries(shop.getShopId(), 
                        defaultStart, defaultEnd, 
                        defaultStart.minusYears(1), defaultEnd.minusYears(1));
                        
            // Thống kê sản phẩm TRỌN ĐỜI (Sử dụng hàm không lọc ngày)
            prodRows = statisticService.getProductRevenueLifetime(shop.getShopId()); 
        }
        
        // 💥 LOGGING CÓ THÊM DÒNG XUỐNG DÒNG ĐỂ LÀM NỔI BẬT 💥
        System.out.println("\n\n\n");
        System.out.println("====================================================");
        System.out.println("--- KẾT QUẢ THỐNG KÊ SẢN PHẨM TRẢ VỀ TỪ SERVICE ---");
        System.out.println("====================================================");
        if (prodRows == null || prodRows.isEmpty()) {
            System.out.println("Danh sách sản phẩm trống (hoặc trả về NULL).");
        } else {
            for (Object[] row : prodRows) {
                // row[0] là tên sản phẩm (String)
                // row[1] là tổng doanh thu (BigDecimal)
                System.out.printf("Sản phẩm: %s | Doanh thu: %s\n", row[0], row[1]);
            }
        }
        System.out.println("----------------------------------------------------");
        System.out.println("\n\n\n");


        // Đóng gói dữ liệu sản phẩm thành JSON
        List<Map<String,Object>> productRevenue = new ArrayList<>();
        for (Object[] r : prodRows) {
            Map<String,Object> m = new HashMap<>();
            m.put("product", r[0]==null ? "(Không tên)" : r[0].toString());
            
            Object totalObj = r[1];
            BigDecimal total = (totalObj instanceof BigDecimal) 
                ? (BigDecimal) totalObj 
                : new BigDecimal(totalObj != null ? totalObj.toString() : "0");
                
            m.put("total", total);
            productRevenue.add(m);
        }
        series.put("productRevenue", productRevenue); 

        // Gửi JSON cuối cùng
        resp.getWriter().write(gson.toJson(series));
    }

    private LocalDate parseDate(String s){
        try { return (s==null || s.isBlank()) ? null : LocalDate.parse(s); }
        catch(Exception e){ return null; }
    }
    private Integer parseInt(String s){
        try { return (s==null || s.isBlank()) ? null : Integer.valueOf(s); }
        catch(Exception e){ return null; }
    }
}