// tung - filepath: src/main/java/vn/iotstar/entities/UserOtp.java
package vn.iotstar.entities;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_otp", indexes = {
        @Index(name = "idx_userotp_user_purpose", columnList = "user_id,purpose")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class UserOtp {

    public enum Purpose { ACTIVATE, RESET }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Purpose purpose;

    @Column(nullable = false, length = 8)
    private String code;

    @Column(name="expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name="used_at")
    private LocalDateTime usedAt;

    @Column(name="send_count", columnDefinition = "int default 0")
    private Integer sendCount;

    @Column(name="last_sent_at")
    private LocalDateTime lastSentAt;
}
