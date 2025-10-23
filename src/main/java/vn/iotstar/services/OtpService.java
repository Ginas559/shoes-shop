// tung - filepath: src/main/java/vn/iotstar/services/OtpService.java
package vn.iotstar.services;

import vn.iotstar.entities.UserOtp;
import vn.iotstar.repositories.UserOtpRepository;

import java.time.LocalDateTime;
import java.util.Random;

public class OtpService {

    private final UserOtpRepository otpRepo = new UserOtpRepository();
    private final MailService mailService = new MailService();
    private static final int EXPIRE_MINUTES = 10;

    public void createAndSendActivateOtp(Long userId, String email) {
        String code = generateCode(6);
        UserOtp otp = UserOtp.builder()
                .userId(userId)
                .purpose(UserOtp.Purpose.ACTIVATE)
                .code(code)
                .expiresAt(LocalDateTime.now().plusMinutes(EXPIRE_MINUTES))
                .build();
        otpRepo.save(otp);
        mailService.sendOtpEmail(email, code, "KÍCH HOẠT TÀI KHOẢN");
    }

    public void createAndSendResetOtp(Long userId, String email) {
        String code = generateCode(6);
        UserOtp otp = UserOtp.builder()
                .userId(userId)
                .purpose(UserOtp.Purpose.RESET)
                .code(code)
                .expiresAt(LocalDateTime.now().plusMinutes(EXPIRE_MINUTES))
                .build();
        otpRepo.save(otp);
        mailService.sendOtpEmail(email, code, "ĐẶT LẠI MẬT KHẨU");
    }

    public boolean verifyOtp(Long userId, String purpose, String code) {
        UserOtp latest = otpRepo.findLatestActive(userId, UserOtp.Purpose.valueOf(purpose.toUpperCase()));
        if (latest == null) return false;
        if (latest.getUsedAt() != null) return false;
        if (latest.getExpiresAt().isBefore(LocalDateTime.now())) return false;
        if (!latest.getCode().equals(code)) return false;

        otpRepo.markUsed(latest.getId());
        return true;
    }

    private static String generateCode(int len) {
        Random r = new Random();
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(r.nextInt(10));
        return sb.toString();
    }
}
