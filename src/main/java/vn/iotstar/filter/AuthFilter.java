package vn.iotstar.filter;

import java.io.IOException;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.entity.User;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Cho phép truy cập các trang public
        if (uri.endsWith("/login") || uri.endsWith("/register") || uri.contains("/home")
                || uri.contains("/css/") || uri.contains("/js/")) {
            chain.doFilter(request, response);
            return;
        }

        // Nếu chưa login
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Check role
        if (uri.startsWith(req.getContextPath() + "/admin") && !"ADMIN".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        if (uri.startsWith(req.getContextPath() + "/vendor") && !"VENDOR".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        if (uri.startsWith(req.getContextPath() + "/shipper") && !"SHIPPER".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        chain.doFilter(request, response);
    }
}
