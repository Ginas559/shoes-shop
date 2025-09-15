package vn.iotstar.entity;

import java.io.Serializable;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "product_variants")
@NamedQuery(name = "ProductVariant.findAll", query = "SELECT v FROM ProductVariant v")
public class ProductVariant implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "product_id")
	private Product product;

	@Column(name = "size", columnDefinition = "nvarchar(255)")
	private String size;

	@Column(name = "color", columnDefinition = "nvarchar(255)")
	private String color;

	@Column(name = "stock_qty")
	private Integer stockQty;

	@Column(name = "sku", columnDefinition = "nvarchar(255)")
	private String sku;

	// 1 - N: cart_items
	@OneToMany(mappedBy = "variant")
	private List<CartItem> cartItems;

	// 1 - N: order_items
	@OneToMany(mappedBy = "variant")
	private List<OrderItem> orderItems;

	public ProductVariant() {}
	
	

	public ProductVariant(Long id, Product product, String size, String color, Integer stockQty, String sku,
			List<CartItem> cartItems, List<OrderItem> orderItems) {
		super();
		this.id = id;
		this.product = product;
		this.size = size;
		this.color = color;
		this.stockQty = stockQty;
		this.sku = sku;
		this.cartItems = cartItems;
		this.orderItems = orderItems;
	}



	// Getter & Setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Product getProduct() { return product; }
	public void setProduct(Product product) { this.product = product; }

	public String getSize() { return size; }
	public void setSize(String size) { this.size = size; }

	public String getColor() { return color; }
	public void setColor(String color) { this.color = color; }

	public Integer getStockQty() { return stockQty; }
	public void setStockQty(Integer stockQty) { this.stockQty = stockQty; }

	public String getSku() { return sku; }
	public void setSku(String sku) { this.sku = sku; }

	public List<CartItem> getCartItems() { return cartItems; }
	public void setCartItems(List<CartItem> cartItems) { this.cartItems = cartItems; }

	public List<OrderItem> getOrderItems() { return orderItems; }
	public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }
}
