// filepath: src/main/java/vn/iotstar/utils/AuthFilter.java
package vn.iotstar.utils;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;

@WebFilter(urlPatterns = {"/vendor/*"})
public class AuthFilter implements Filter {

    // STAFF chỉ được vào các path này
    private static final Set<String> STAFF_ALLOWED = Set.of(
            "/vendor/dashboard",
            "/vendor/products",
            "/vendor/orders"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession ss = req.getSession(false);
        String role = (ss != null) ? (String) ss.getAttribute("role") : null;
        Object staffShopId = (ss != null) ? ss.getAttribute("staffShopId") : null;

        // Vendor: full quyền vendor/*
        if ("VENDOR".equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        // Staff (USER + có staffShopId): whitelist đường dẫn
        if ("USER".equals(role) && staffShopId != null) {
            String sp = req.getServletPath();              // /vendor/products
            String pi = req.getPathInfo();                 // /edit, /add, ...
            String key = (pi == null) ? sp : sp;           // kiểm theo servletPath là đủ
            boolean ok = STAFF_ALLOWED.stream().anyMatch(key::startsWith);
            if (ok) {
                chain.doFilter(request, response);
                return;
            }
            // Không nằm trong whitelist → chặn
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Staff không có quyền truy cập trang này.");
            return;
        }

        // Chưa đăng nhập hoặc không đúng vai
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
