// filepath: src/main/java/vn/iotstar/services/OtpService.java
package vn.iotstar.services;

import vn.iotstar.entities.User;
import vn.iotstar.entities.UserOtp;
import vn.iotstar.repositories.UserRepository;
import vn.iotstar.repositories.UserOtpRepository;

import java.time.LocalDateTime;
import java.util.Random;

public class OtpService {

    private final UserRepository userRepo   = new UserRepository();
    private final UserOtpRepository otpRepo = new UserOtpRepository();
    private final MailService mailService   = new MailService();

    private String random6() {
        return String.format("%06d", new Random().nextInt(1_000_000));
    }

    /** Gửi OTP kích hoạt (REGISTER) cho email đã đăng ký */
    public boolean sendRegisterOtp(String email) {
        User u = userRepo.findByEmail(email);
        if (u == null) return false;

        // Xoá OTP REGISTER cũ để tránh trùng
        otpRepo.deleteByUserAndPurpose(u, UserOtp.Purpose.REGISTER);

        // Tạo OTP mới
        UserOtp otp = new UserOtp();
        otp.setUser(u);
        otp.setPurpose(UserOtp.Purpose.REGISTER);
        otp.setCode(random6());
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(10));
        otpRepo.save(otp);

        // Gửi email bằng MailService hiện tại của bạn
        mailService.sendOtpEmail(u.getEmail(), otp.getCode(), "Kích hoạt tài khoản UTESHOP");
        return true;
    }

    /** Gửi lại OTP REGISTER */
    public boolean resendRegisterOtp(String email) {
        return sendRegisterOtp(email);
    }

    /** Xác minh OTP đăng ký; nếu đúng → kích hoạt email cho user */
    public boolean verifyActivateOtp(String email, String code) {
        User u = userRepo.findByEmail(email);
        if (u == null) return false;

        // LƯU Ý: repo của bạn nhận thứ tự tham số: (user, purpose, code, now)
        UserOtp found = otpRepo.findValid(u, UserOtp.Purpose.REGISTER, code, LocalDateTime.now());
        if (found == null) return false;

        // Kích hoạt tài khoản
        u.setIsEmailActive(true);
        userRepo.update(u);

        // Dọn OTP REGISTER
        otpRepo.deleteByUserAndPurpose(u, UserOtp.Purpose.REGISTER);
        return true;
    }
}
