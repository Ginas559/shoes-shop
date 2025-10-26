package vn.iotstar.entities;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
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

    // Quan hệ ngược để tránh N+1 và hỗ trợ hiển thị shopName từ Product
    @OneToMany(mappedBy = "shop", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Product> products = new ArrayList<>();

    public enum ShopStatus {
        ACTIVE,
        BANNED,
        PENDING
    }
}
