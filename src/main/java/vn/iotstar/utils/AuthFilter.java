// filepath: src/main/java/vn/iotstar/utils/AuthFilter.java
package vn.iotstar.utils;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Bảo vệ /vendor/* : chỉ cho phép khi session.role == "VENDOR" */
@WebFilter(urlPatterns = {"/vendor/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession ss = req.getSession(false);
        String role = (ss != null && ss.getAttribute("role") != null)
                ? String.valueOf(ss.getAttribute("role")) : null;

        if (!"VENDOR".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        chain.doFilter(request, response);
    }
}


