// filepath: src/main/java/vn/iotstar/controllers/auth/RegisterServlet.java
package vn.iotstar.controllers.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import vn.iotstar.entities.User;
import vn.iotstar.services.AuthService;
import vn.iotstar.services.OtpService;

import java.io.IOException;

@WebServlet(urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private AuthService authService;
    private OtpService  otpService;

    @Override
    public void init() {
        this.authService = new AuthService();
        this.otpService  = new OtpService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("pageTitle", "Đăng ký tài khoản");
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String firstname = req.getParameter("firstname");
        String lastname  = req.getParameter("lastname");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phone");
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirm");

        try {
            if (firstname == null || lastname == null || email == null || phone == null
                    || password == null || confirm == null
                    || firstname.isBlank() || lastname.isBlank()
                    || email.isBlank() || phone.isBlank()
                    || password.isBlank()) {
                throw new IllegalStateException("Vui lòng nhập đầy đủ thông tin.");
            }
            if (!password.equals(confirm)) {
                throw new IllegalStateException("Mật khẩu xác nhận không khớp.");
            }

            // 1) Tạo user
            User user = authService.registerNewUser(firstname, lastname, email, phone, password);

            // 2) Tạo & gửi OTP (không chặn flow nếu mail fail)
            OtpService.OtpResult r = otpService.createAndSendActivateOtp(user);

            // 3) Chuyển sang trang verify kèm thông báo
            String msg = r.mailSent
                    ? "Mã OTP đã được gửi đến email của bạn."
                    : "Không gửi được email. Vui lòng kiểm tra trang xác minh và GỬI LẠI OTP.";
            req.getSession().setAttribute("flash", msg);
            resp.sendRedirect(req.getContextPath() + "/verify?email=" + email);
        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", ex.getMessage() != null ? ex.getMessage() : "Có lỗi xảy ra, vui lòng thử lại.");
            req.setAttribute("pageTitle", "Đăng ký tài khoản");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}
