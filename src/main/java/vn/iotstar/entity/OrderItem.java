package vn.iotstar.entity;

import java.io.Serializable;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "order_items")
@NamedQuery(name = "OrderItem.findAll", query = "SELECT oi FROM OrderItem oi")
public class OrderItem implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "order_id")
	private Order order;

	@ManyToOne
	@JoinColumn(name = "product_variant_id")
	private ProductVariant variant;

	@Column(name = "qty")
	private Integer qty;

	@Column(name = "unit_price")
	private Double unitPrice;

	@Column(name = "total_price")
	private Double totalPrice;

	// 1 - N: reviews (mỗi OrderItem có thể có nhiều review kèm media, text...)
	@OneToMany(mappedBy = "orderItem")
	private List<Review> reviews;

	public OrderItem() {}
	
	

	public OrderItem(Long id, Order order, ProductVariant variant, Integer qty, Double unitPrice, Double totalPrice,
			List<Review> reviews) {
		super();
		this.id = id;
		this.order = order;
		this.variant = variant;
		this.qty = qty;
		this.unitPrice = unitPrice;
		this.totalPrice = totalPrice;
		this.reviews = reviews;
	}



	// Getter & Setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Order getOrder() { return order; }
	public void setOrder(Order order) { this.order = order; }

	public ProductVariant getVariant() { return variant; }
	public void setVariant(ProductVariant variant) { this.variant = variant; }

	public Integer getQty() { return qty; }
	public void setQty(Integer qty) { this.qty = qty; }

	public Double getUnitPrice() { return unitPrice; }
	public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }

	public Double getTotalPrice() { return totalPrice; }
	public void setTotalPrice(Double totalPrice) { this.totalPrice = totalPrice; }

	public List<Review> getReviews() { return reviews; }
	public void setReviews(List<Review> reviews) { this.reviews = reviews; }
}
