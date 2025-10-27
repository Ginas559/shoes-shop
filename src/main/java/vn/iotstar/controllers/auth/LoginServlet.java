// tung - filepath: src/main/java/vn/iotstar/controllers/auth/LoginServlet.java
package vn.iotstar.controllers.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import vn.iotstar.entities.User;
import vn.iotstar.services.AuthService;

@WebServlet(urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthService(); // dùng JPA EMF "default"
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Nếu đã đăng nhập thì điều hướng theo role
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            redirectByRole(resp, req.getContextPath(), (String) session.getAttribute("role"));
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        final String email = req.getParameter("email");
        final String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đủ Email và Mật khẩu.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            User u = authService.login(email, password); // ném IllegalStateException khi lỗi

            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", u);
            session.setAttribute("userId", u.getId());
            session.setAttribute("email", u.getEmail());
            session.setAttribute("role", u.getRole().name()); // USER | ADMIN | VENDOR | SHIPPER

            // ⭐ Thêm hỗ trợ STAFF (USER thuộc 1 shop)
            if (u.getStaffShop() != null) {
                session.setAttribute("staffShopId", u.getStaffShop().getShopId());
            } else {
                session.removeAttribute("staffShopId");
            }

            redirectByRole(resp, req.getContextPath(), u.getRole().name());
        } catch (IllegalStateException ex) {
            req.setAttribute("error", ex.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Có lỗi hệ thống, vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }


    private void redirectByRole(HttpServletResponse resp, String ctx, String role) throws IOException {
        if ("ADMIN".equalsIgnoreCase(role)) {
            resp.sendRedirect(ctx + "/admin/dashboard");
        } else if ("VENDOR".equalsIgnoreCase(role)) {
            resp.sendRedirect(ctx + "/vendor/dashboard");
        } else {
            // USER hoặc các role khác
            resp.sendRedirect(ctx + "/");
        }
    }
}
