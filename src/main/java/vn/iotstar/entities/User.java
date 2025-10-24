// filepath: src/main/java/vn/iotstar/entities/User.java
package vn.iotstar.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * User entity (18 fields) cho AUTH + SHOP:
 * - Lưu JSON addresses (string) để tương thích SQLServer.
 * - Tự gen slug + timestamps bằng @PrePersist/@PreUpdate.
 * - LƯU Ý: dùng @Builder => các giá trị mặc định phải kèm @Builder.Default.
 */
@Entity
@Table(
    name = "users",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_users_slug",   columnNames = "slug"),
        @UniqueConstraint(name = "uk_users_email",  columnNames = "email"),
        @UniqueConstraint(name = "uk_users_phone",  columnNames = "phone"),
        @UniqueConstraint(name = "uk_users_idcard", columnNames = "id_card")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    // 1) Id (PK, auto-generated)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 2) Firstname
    @NotBlank @Size(max = 32)
    @Column(nullable = false, length = 32)
    private String firstname;

    // 3) Lastname
    @NotBlank @Size(max = 32)
    @Column(nullable = false, length = 32)
    private String lastname;

    // 4) Slug (auto-gen from firstname + lastname)
    @NotBlank
    @Size(max = 70)
    @Column(nullable = false, length = 70)
    private String slug;

    // 5) ID card (nullable + unique)
    @Size(max = 20)
    @Column(name = "id_card", length = 20, unique = true)
    private String idCard;

    // 6) Email (unique)
    @Email @NotBlank @Size(max = 120)
    @Column(nullable = false, length = 120)
    private String email;

    // 7) Phone (unique)
    @NotBlank @Size(max = 15)
    @Column(nullable = false, length = 15)
    private String phone;

    // 8) Email verified?
    @Builder.Default
    @Column(nullable = false, columnDefinition = "bit default 0")
    private Boolean isEmailActive = false;

    // 9) Phone verified?
    @Builder.Default
    @Column(nullable = false, columnDefinition = "bit default 0")
    private Boolean isPhoneActive = false;

    // 10) Salt (for hashing)
    @NotBlank
    @Column(nullable = false)
    private String salt;

    // 11) Hashed password (BCrypt)
    @NotBlank
    @Column(name = "hashed_password", nullable = false)
    private String hashedPassword;

    // 12) Role: user/admin (default user)
    public enum Role { USER, ADMIN, VENDOR, ShIPPER }
    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10, columnDefinition = "varchar(10) default 'USER'")
    private Role role = Role.USER;

    // 13) Addresses (JSON string, max ~2000 chars, limit 6 addresses do ở tầng service)
    @Builder.Default
    @Size(max = 2000)
    @Column(length = 2000)
    private String addresses = "[]";

    // 14) Avatar path
    @Size(max = 255)
    @Column(length = 255)
    private String avatar;

    // 15) Cover path
    @Size(max = 255)
    @Column(length = 255)
    private String cover;

    // 16) Point (for user level)
    @Builder.Default
    @Column(nullable = false, columnDefinition = "int default 0")
    private Integer point = 0;

    // 17) E-wallet balance
    @Builder.Default
    @Column(name = "e_wallet", precision = 18, scale = 2, nullable = false,
            columnDefinition = "decimal(18,2) default 0")
    private BigDecimal eWallet = BigDecimal.ZERO;

    // 18) Audit timestamps
    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    /*--- Lifecycle hooks ---*/
    @PrePersist
    private void prePersist() {
        if (slug == null || slug.isBlank()) {
            this.slug = toSlug(firstname + " " + lastname);
        }
        this.createdAt = LocalDateTime.now();
        this.updatedAt = this.createdAt;

        // Chuẩn hóa & default an toàn khi dùng @Builder
        if (email != null) this.email = email.trim().toLowerCase(Locale.ROOT);
        if (phone != null) this.phone = phone.trim();
        if (addresses == null) this.addresses = "[]";
        if (isEmailActive == null) this.isEmailActive = false;
        if (isPhoneActive == null) this.isPhoneActive = false;
        if (point == null) this.point = 0;
        if (eWallet == null) this.eWallet = BigDecimal.ZERO;
        if (role == null) this.role = Role.USER;
    }

    @PreUpdate
    private void preUpdate() {
        if (slug == null || slug.isBlank()) {
            this.slug = toSlug(firstname + " " + lastname);
        }
        this.updatedAt = LocalDateTime.now();

        if (email != null) this.email = email.trim().toLowerCase(Locale.ROOT);
        if (phone != null) this.phone = phone.trim();
        if (addresses == null) this.addresses = "[]";
        if (isEmailActive == null) this.isEmailActive = false;
        if (isPhoneActive == null) this.isPhoneActive = false;
        if (point == null) this.point = 0;
        if (eWallet == null) this.eWallet = BigDecimal.ZERO;
        if (role == null) this.role = Role.USER;
    }

    /*--- Helper: make slug from name (remove accents, spaces -> '-') ---*/
    private static final Pattern NONLATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]+");

    private static String toSlug(String input) {
        if (input == null) return "";
        String noWhite = WHITESPACE.matcher(input.trim()).replaceAll("-");
        String normalized = Normalizer.normalize(noWhite, Normalizer.Form.NFD);
        String slug = NONLATIN.matcher(normalized.replaceAll("\\p{M}", "")).replaceAll("");
        slug = slug.replaceAll("[-]{2,}", "-");
        return slug.toLowerCase(Locale.ROOT);
    }
}
