package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.*;

@Entity
@Table(name = "cart_items")
@NamedQuery(name = "CartItem.findAll", query = "SELECT ci FROM CartItem ci")
public class CartItem implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "cart_id")
	private Cart cart;

	@ManyToOne
	@JoinColumn(name = "product_variant_id")
	private ProductVariant variant;

	@Column(name = "qty")
	private Integer qty;

	@Column(name = "price_snapshot")
	private Double priceSnapshot;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created_at")
	private Date createdAt;

	public CartItem() {}
	
	

	public CartItem(Long id, Cart cart, ProductVariant variant, Integer qty, Double priceSnapshot, Date createdAt) {
		super();
		this.id = id;
		this.cart = cart;
		this.variant = variant;
		this.qty = qty;
		this.priceSnapshot = priceSnapshot;
		this.createdAt = createdAt;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Cart getCart() { return cart; }
	public void setCart(Cart cart) { this.cart = cart; }

	public ProductVariant getVariant() { return variant; }
	public void setVariant(ProductVariant variant) { this.variant = variant; }

	public Integer getQty() { return qty; }
	public void setQty(Integer qty) { this.qty = qty; }

	public Double getPriceSnapshot() { return priceSnapshot; }
	public void setPriceSnapshot(Double priceSnapshot) { this.priceSnapshot = priceSnapshot; }

	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
