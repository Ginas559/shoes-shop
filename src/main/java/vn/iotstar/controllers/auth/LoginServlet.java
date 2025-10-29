// filepath: src/main/java/vn/iotstar/controllers/auth/LoginServlet.java
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
        // Khởi tạo service dùng EntityManager mặc định
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Nếu đã có phiên session cũ thì điều hướng theo vai trò
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            redirectByRole(resp, req.getContextPath(), (String) session.getAttribute("role"));
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        final String email = req.getParameter("email");
        final String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đủ Email và Mật khẩu.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            // Xác thực tài khoản bằng service (mật khẩu đã hash)
            User u = authService.login(email, password); // ném IllegalStateException khi lỗi

            // Lưu session để tương thích phần cũ (fallback cho staff, hoặc nơi khác còn dùng session)
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", u);
            session.setAttribute("userId", u.getId());
            session.setAttribute("email", u.getEmail());
            session.setAttribute("role", u.getRole().name()); // USER | ADMIN | VENDOR | SHIPPER

            // Hỗ trợ staff: nếu user thuộc 1 shop, set staffShopId để whitelist các trang staff
            if (u.getStaffShop() != null) {
                session.setAttribute("staffShopId", u.getStaffShop().getShopId());
            } else {
                session.removeAttribute("staffShopId");
            }

            // JWT: phát access token sau khi đăng nhập thành công
            // Lý do: dùng cookie httpOnly để tránh JS đọc token; Filter sẽ đọc token từ cookie hoặc Authorization header.
            String token = authService.issueAccessToken(u);

            Cookie cookie = new Cookie("access_token", token);
            cookie.setHttpOnly(true);
            cookie.setPath("/"); // token có hiệu lực toàn site
            // Nếu chạy HTTPS, có thể bật cookie.setSecure(true)
            resp.addCookie(cookie);

            // SameSite=Lax để hạn chế gửi cookie trong bối cảnh cross-site thông thường
            resp.addHeader("Set-Cookie", "access_token=" + token + "; Path=/; HttpOnly; SameSite=Lax");

            // Điều hướng theo vai trò cho rõ ràng khi trình bày với giảng viên
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
