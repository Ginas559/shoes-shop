// filepath: src/main/java/vn/iotstar/controllers/auth/VerifyOtpServlet.java
package vn.iotstar.controllers.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import vn.iotstar.services.OtpService;

import java.io.IOException;

@WebServlet(urlPatterns = {"/verify", "/otp/resend"})
public class VerifyOtpServlet extends HttpServlet {

    private OtpService otpService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.otpService = new OtpService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/verify.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        if ("/otp/resend".equals(path)) {
            String email = req.getParameter("email");
            boolean ok = otpService.resendRegisterOtp(email);
            req.getSession().setAttribute("flash", ok ? "Đã gửi lại OTP." : "Không gửi được OTP. Vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/verify?email=" + email);
            return;
        }

        // POST /verify
        String email = req.getParameter("email");
        String code  = req.getParameter("code");
        boolean ok = otpService.verifyActivateOtp(email, code);
        if (ok) {
            req.getSession().setAttribute("flash", "Kích hoạt tài khoản thành công. Vui lòng đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/login");
        } else {
            req.getSession().setAttribute("flash", "Mã OTP không đúng hoặc đã hết hạn.");
            resp.sendRedirect(req.getContextPath() + "/verify?email=" + email);
        }
    }
}
