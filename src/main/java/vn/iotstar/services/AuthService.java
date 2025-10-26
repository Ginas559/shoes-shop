// filepath: src/main/java/vn/iotstar/services/AuthService.java
package vn.iotstar.services;

import vn.iotstar.entities.User;
import vn.iotstar.repositories.UserRepository;
import vn.iotstar.utils.PasswordUtil;

public class AuthService {

    private final UserRepository userRepo = new UserRepository();

    /** Đăng ký mặc định (giữ nguyên method cũ để không phá code nơi khác) */
    public User registerNewUser(String firstname, String lastname, String email, String phone, String rawPassword) {
        return registerNewUserWithRole(firstname, lastname, email, phone, rawPassword, User.Role.USER);
    }

    /** Đăng ký theo role (mới thêm) + set INACTIVE + băm mật khẩu (salt + BCrypt) */
    public User registerNewUserWithRole(String firstname, String lastname, String email, String phone,
                                        String rawPassword, User.Role role) {
        if (userRepo.existsByEmail(email)) {
            throw new IllegalStateException("Email đã tồn tại.");
        }
        if (rawPassword == null || rawPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu phải có tối thiểu 6 ký tự.");
        }

        // Tạo salt + hash
        String salt = PasswordUtil.generateSalt();
        String hashed = PasswordUtil.hashWithBCrypt(salt + rawPassword);

        User u = new User();
        u.setFirstname(firstname);
        u.setLastname(lastname);
        u.setEmail(email);
        u.setPhone(phone);
        u.setSalt(salt);
        u.setHashedPassword(hashed);

        // set trạng thái & vai trò
        u.setIsEmailActive(false);
        u.setRole(role);

        // các field khác (nếu entity có mặc định thì giữ nguyên)

        userRepo.save(u);
        return u;
    }

    /** Đăng nhập bằng email + mật khẩu (giữ nguyên logic hiện tại) */
    public User login(String email, String rawPassword) {
        User u = userRepo.findByEmail(email);
        if (u == null) throw new IllegalStateException("Email không tồn tại.");
        if (u.getIsEmailActive() == null || !u.getIsEmailActive()) {
            throw new IllegalStateException("Tài khoản chưa kích hoạt email.");
        }
        boolean ok = PasswordUtil.matches(u.getSalt() + rawPassword, u.getHashedPassword());
        if (!ok) throw new IllegalStateException("Mật khẩu không đúng.");
        return u;
    }
}
