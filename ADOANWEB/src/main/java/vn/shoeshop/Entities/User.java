package vn.shoeshop.Entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder

@Entity
@Table(name = "[User]")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Email
    @NotBlank
    @Column(name = "email", nullable = false, unique = true, length = 255)
    private String email;

    @NotBlank
    @Size(min = 8, max = 255)
    @Column(name = "password", nullable = false, length = 255)
    private String password; // mật khẩu mã hóa bằng bcrypt

    @NotBlank
    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(name = "phone", length = 20)
    private String phone;
    
    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "role", length = 20)
    private Role role = Role.USER;
    
    @Builder.Default
    @Column(name = "is_active")
    private Boolean isActive = true;

    @Builder.Default
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    public enum Role {
        ADMIN,
        USER,
        VENDOR,
        SHIPPER
    }
}
