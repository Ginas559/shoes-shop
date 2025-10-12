package vn.iotstar.entities;


import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "[Shop]")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Shop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "shop_id")
    private Long shopId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "vendor_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "FK_Shop_User")
    )
    private User vendor;

    @Column(name = "shop_name", nullable = false, length = 150)
    private String shopName;

    @Column(name = "description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20)
    @Builder.Default
    private ShopStatus status = ShopStatus.PENDING;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum ShopStatus {
        ACTIVE,
        BANNED,
        PENDING
    }
}

