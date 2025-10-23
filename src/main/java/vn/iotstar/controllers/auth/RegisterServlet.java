// tung - filepath: src/main/java/vn/iotstar/controllers/auth/RegisterServlet.java
package vn.iotstar.controllers.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import vn.iotstar.services.AuthService;
import vn.iotstar.services.OtpService;
import vn.iotstar.entities.User;

@WebServlet(urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private AuthService authService;
    private OtpService otpService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthService();
        this.otpService = new OtpService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String firstname = req.getParameter("firstname");
        String lastname  = req.getParameter("lastname");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phone");
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirm");

        if (firstname == null || firstname.isBlank()
                || lastname == null || lastname.isBlank()
                || email == null || email.isBlank()
                || phone == null || phone.isBlank()
                || password == null || password.isBlank()
                || confirm == null || confirm.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đủ các trường bắt buộc.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        try {
            User user = authService.registerNewUser(firstname, lastname, email, phone, password);
            // tạo & gửi OTP kích hoạt
            otpService.createAndSendActivateOtp(user.getId(), user.getEmail());
            // lưu tạm userId để verify
            req.getSession(true).setAttribute("PENDING_ACTIVATE_USER_ID", user.getId());
            resp.sendRedirect(req.getContextPath() + "/verify-otp?purpose=ACTIVATE");
        } catch (IllegalStateException ex) {
            req.setAttribute("error", ex.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}
