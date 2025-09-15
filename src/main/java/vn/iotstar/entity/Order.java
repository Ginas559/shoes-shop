package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "orders")
@NamedQuery(name = "Order.findAll", query = "SELECT o FROM Order o")
public class Order implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;

	@ManyToOne
	@JoinColumn(name = "shop_id")
	private Shop shop;

	@ManyToOne
	@JoinColumn(name = "carrier_id")
	private Carrier carrier;

	@Column(name = "address_snapshot_json", columnDefinition = "nvarchar(255)")
	private String addressSnapshotJson;

	@Column(name = "payment_method", columnDefinition = "nvarchar(255)")
	private String paymentMethod;

	@Column(name = "payment_status", columnDefinition = "nvarchar(255)")
	private String paymentStatus;

	@Column(name = "order_status", columnDefinition = "nvarchar(255)")
	private String orderStatus;

	@Column(name = "subtotal")
	private Double subtotal;

	@Column(name = "shipping_fee")
	private Double shippingFee;

	@Column(name = "discount")
	private Double discount;

	@Column(name = "total")
	private Double total;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created_at")
	private Date createdAt;

	@OneToMany(mappedBy = "order")
	private List<OrderItem> orderItems;

	@OneToMany(mappedBy = "order")
	private List<Payment> payments;

	@OneToMany(mappedBy = "order")
	private List<OrderVoucher> orderVouchers;

	@OneToMany(mappedBy = "order")
	private List<ShipperAssignment> shipperAssignments;

//	@OneToMany(mappedBy = "order")
//	private List<Review> reviews;

	public Order() {}
	
	

	public Order(Long id, User user, Shop shop, Carrier carrier, String addressSnapshotJson, String paymentMethod,
			String paymentStatus, String orderStatus, Double subtotal, Double shippingFee, Double discount,
			Double total, Date createdAt, List<OrderItem> orderItems, List<Payment> payments,
			List<OrderVoucher> orderVouchers, List<ShipperAssignment> shipperAssignments, List<Review> reviews) {
		super();
		this.id = id;
		this.user = user;
		this.shop = shop;
		this.carrier = carrier;
		this.addressSnapshotJson = addressSnapshotJson;
		this.paymentMethod = paymentMethod;
		this.paymentStatus = paymentStatus;
		this.orderStatus = orderStatus;
		this.subtotal = subtotal;
		this.shippingFee = shippingFee;
		this.discount = discount;
		this.total = total;
		this.createdAt = createdAt;
		this.orderItems = orderItems;
		this.payments = payments;
		this.orderVouchers = orderVouchers;
		this.shipperAssignments = shipperAssignments;
//		this.reviews = reviews;
	}



	// Getter & Setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getUser() { return user; }
	public void setUser(User user) { this.user = user; }

	public Shop getShop() { return shop; }
	public void setShop(Shop shop) { this.shop = shop; }

	public Carrier getCarrier() { return carrier; }
	public void setCarrier(Carrier carrier) { this.carrier = carrier; }

	public String getAddressSnapshotJson() { return addressSnapshotJson; }
	public void setAddressSnapshotJson(String addressSnapshotJson) { this.addressSnapshotJson = addressSnapshotJson; }

	public String getPaymentMethod() { return paymentMethod; }
	public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

	public String getPaymentStatus() { return paymentStatus; }
	public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

	public String getOrderStatus() { return orderStatus; }
	public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

	public Double getSubtotal() { return subtotal; }
	public void setSubtotal(Double subtotal) { this.subtotal = subtotal; }

	public Double getShippingFee() { return shippingFee; }
	public void setShippingFee(Double shippingFee) { this.shippingFee = shippingFee; }

	public Double getDiscount() { return discount; }
	public void setDiscount(Double discount) { this.discount = discount; }

	public Double getTotal() { return total; }
	public void setTotal(Double total) { this.total = total; }

	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

	public List<OrderItem> getOrderItems() { return orderItems; }
	public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }

	public List<Payment> getPayments() { return payments; }
	public void setPayments(List<Payment> payments) { this.payments = payments; }

	public List<OrderVoucher> getOrderVouchers() { return orderVouchers; }
	public void setOrderVouchers(List<OrderVoucher> orderVouchers) { this.orderVouchers = orderVouchers; }

	public List<ShipperAssignment> getShipperAssignments() { return shipperAssignments; }
	public void setShipperAssignments(List<ShipperAssignment> shipperAssignments) { this.shipperAssignments = shipperAssignments; }

//	public List<Review> getReviews() { return reviews; }
//	public void setReviews(List<Review> reviews) { this.reviews = reviews; }
}
