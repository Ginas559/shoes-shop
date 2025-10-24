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
    public void init() {
        this.otpService = new OtpService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        req.setAttribute("email", email);
        req.setAttribute("pageTitle", "Xác minh OTP");
        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash.toString());
            req.getSession().removeAttribute("flash");
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/verify.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String servletPath = req.getServletPath();
        if ("/otp/resend".equals(servletPath)) {
            String email = req.getParameter("email");
            OtpService.OtpResult r = otpService.resendActivateOtp(email);
            req.getSession().setAttribute("flash", r.mailSent
                    ? "Đã gửi lại OTP."
                    : "Không gửi được email. Vui lòng thử lại sau.");
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
