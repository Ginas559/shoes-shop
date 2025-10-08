package vn.iotstar.Entities;


import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "Order_Item")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_item_id")
    private Long orderItemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "order_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "FK_OrderItem_Order")
    )
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "product_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "FK_OrderItem_Product")
    )
    private Product product;

    @Column(name = "price", nullable = false, precision = 18, scale = 2)
    private BigDecimal price;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "discount", precision = 5, scale = 2)
    private BigDecimal discount = BigDecimal.ZERO; // phần trăm giảm giá

    @Transient
    private BigDecimal subtotal; // không lưu trong DB, nhưng có thể tính lại trong code

    // Tính subtotal trong code (đồng bộ với SQL computed column)
    public BigDecimal getSubtotal() {
        if (price == null || quantity == null) return BigDecimal.ZERO;
        BigDecimal discountMultiplier = BigDecimal.ONE.subtract(
            discount.divide(BigDecimal.valueOf(100))
        );
        return price.multiply(BigDecimal.valueOf(quantity)).multiply(discountMultiplier);
    }
}

