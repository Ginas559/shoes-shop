// tung - filepath: src/main/java/vn/iotstar/services/AuthService.java
package vn.iotstar.services;

import vn.iotstar.entities.User;
import vn.iotstar.repositories.UserRepository;
import vn.iotstar.utils.PasswordUtil;

public class AuthService {

    private final UserRepository userRepo = new UserRepository();

    public User registerNewUser(String firstname, String lastname, String email, String phone, String rawPassword) {
        if (userRepo.existsByEmail(email)) {
            throw new IllegalStateException("Email đã tồn tại.");
        }
        if (userRepo.existsByPhone(phone)) {
            throw new IllegalStateException("Số điện thoại đã tồn tại.");
        }

        String salt = PasswordUtil.generateSalt();
        String hash = PasswordUtil.hashWithBCrypt(salt + rawPassword);

        User user = User.builder()
                .firstname(firstname.trim())
                .lastname(lastname.trim())
                .email(email.trim().toLowerCase())
                .phone(phone.trim())
                .salt(salt)
                .hashedPassword(hash)
                .build();

        // isEmailActive default = false (theo entity)
        userRepo.save(user);
        return user;
    }

    public void activateEmail(Long userId) {
        User u = userRepo.findById(userId);
        if (u == null) throw new IllegalStateException("Không tìm thấy user.");
        u.setIsEmailActive(true);
        userRepo.update(u);
    }
    
    //Login + register
    // ✅ Đăng nhập bằng email + mật khẩu
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
