// tung - filepath: src/main/java/vn/iotstar/controllers/auth/VerifyOtpServlet.java
package vn.iotstar.controllers.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import vn.iotstar.services.OtpService;
import vn.iotstar.services.AuthService;

@WebServlet(urlPatterns = {"/verify-otp"})
public class VerifyOtpServlet extends HttpServlet {

    private OtpService otpService;
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.otpService = new OtpService();
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String purpose = req.getParameter("purpose"); // ACTIVATE | RESET
        String code    = req.getParameter("code");
        HttpSession session = req.getSession(false);

        if (purpose == null || code == null || code.isBlank()) {
            req.setAttribute("error", "Thiếu OTP hoặc purpose.");
            req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
            return;
        }

        try {
            if ("ACTIVATE".equalsIgnoreCase(purpose)) {
                Long userId = (Long) (session != null ? session.getAttribute("PENDING_ACTIVATE_USER_ID") : null);
                if (userId == null) {
                    req.setAttribute("error", "Phiên hết hạn. Vui lòng đăng ký lại hoặc gửi lại OTP.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
                    return;
                }
                boolean ok = otpService.verifyOtp(userId, "ACTIVATE", code);
                if (!ok) {
                    req.setAttribute("error", "OTP không hợp lệ hoặc đã hết hạn.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
                    return;
                }
                authService.activateEmail(userId);
                session.removeAttribute("PENDING_ACTIVATE_USER_ID");
                req.setAttribute("message", "Kích hoạt thành công! Vui lòng đăng nhập.");
                req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
                return;
            } else if ("RESET".equalsIgnoreCase(purpose)) {
                // Trường hợp quên mật khẩu: bạn có thể lưu tạm userId cần reset vào session trước đó
                Long resetUserId = (Long) (session != null ? session.getAttribute("PENDING_RESET_USER_ID") : null);
                if (resetUserId == null) {
                    req.setAttribute("error", "Phiên hết hạn. Vui lòng thực hiện lại bước quên mật khẩu.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
                    return;
                }
                boolean ok = otpService.verifyOtp(resetUserId, "RESET", code);
                if (!ok) {
                    req.setAttribute("error", "OTP không hợp lệ hoặc đã hết hạn.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
                    return;
                }
                // cho phép chuyển sang trang đặt mật khẩu mới
                resp.sendRedirect(req.getContextPath() + "/reset-password");
                return;
            } else {
                req.setAttribute("error", "Purpose không hợp lệ.");
                req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi máy chủ. Vui lòng thử lại.");
            req.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(req, resp);
        }
    }
}
