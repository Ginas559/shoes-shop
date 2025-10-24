// filepath: src/main/java/vn/iotstar/services/OtpService.java
package vn.iotstar.services;

import vn.iotstar.entities.User;
import vn.iotstar.entities.UserOtp;
import vn.iotstar.repositories.UserOtpRepository;
import vn.iotstar.repositories.UserRepository;
import vn.iotstar.utils.MailUtil;

import java.time.LocalDateTime;
import java.util.Random;

public class OtpService {

    private final UserOtpRepository otpRepo = new UserOtpRepository();
    private final UserRepository userRepo   = new UserRepository();
    private static final Random RAND = new Random();

    public static class OtpResult {
        public final boolean otpSaved;
        public final boolean mailSent;
        public OtpResult(boolean s, boolean m){ this.otpSaved=s; this.mailSent=m; }
    }

    private String randomCode6() {
        int n = RAND.nextInt(1_000_000);
        return String.format("%06d", n);
    }

    /** Tạo OTP kích hoạt và cố gắng gửi mail. Không ném lỗi ra ngoài. */
    public OtpResult createAndSendActivateOtp(User user) {
        String code = randomCode6();
        UserOtp otp = UserOtp.builder()
                .user(user)
                .purpose(UserOtp.Purpose.REGISTER)
                .code(code)
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .build();
        try {
            // Xoá OTP cũ để gọn DB
            otpRepo.deleteByUserAndPurpose(user, UserOtp.Purpose.REGISTER);
            otpRepo.save(otp);
        } catch (RuntimeException e) {
            e.printStackTrace();
            return new OtpResult(false, false);
        }

        boolean mailed = MailUtil.send(
                user.getEmail(),
                "[BMTT Shop] Ma OTP kich hoat tai khoan",
                "Ma OTP cua ban la: " + code + " (hieu luc 10 phut).");
        return new OtpResult(true, mailed);
    }

    public OtpResult resendActivateOtp(String email) {
        User u = userRepo.findByEmail(email);
        if (u == null) return new OtpResult(false, false);
        return createAndSendActivateOtp(u);
    }

    /** Xác minh OTP; nếu đúng -> kích hoạt email cho user. */
    public boolean verifyActivateOtp(String email, String code) {
        User u = userRepo.findByEmail(email);
        if (u == null) return false;
        UserOtp found = otpRepo.findValid(u, UserOtp.Purpose.REGISTER, code, LocalDateTime.now());
        if (found == null) return false;

        // Đúng mã và còn hạn -> active + dọn OTP
        u.setIsEmailActive(true);
        userRepo.update(u);
        otpRepo.deleteByUserAndPurpose(u, UserOtp.Purpose.REGISTER);
        return true;
    }
}
