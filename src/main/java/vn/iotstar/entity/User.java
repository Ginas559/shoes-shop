package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
@NamedQuery(name = "User.findAll", query = "SELECT u FROM User u")
public class User implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@Column(name = "email", columnDefinition = "nvarchar(255) not null", unique = true)
	private String email;

	@Column(name = "password_hash", columnDefinition = "nvarchar(255) not null")
	private String passwordHash;

	@Column(name = "full_name", columnDefinition = "nvarchar(255)")
	private String fullName;

	@Column(name = "phone", columnDefinition = "nvarchar(255)")
	private String phone;

	@Column(name = "role", columnDefinition = "nvarchar(255) not null")
	private String role;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created_at")
	private Date createdAt;

	// 1 - N: user_addresses
	@OneToMany(mappedBy = "user")
	private List<UserAddress> userAddresses;

	// 1 - N: shops (owner)
	@OneToMany(mappedBy = "owner")
	private List<Shop> shops;

	// TODO (nhóm 2):
	@OneToMany(mappedBy = "user")
	private List<Cart> carts;

	@OneToMany(mappedBy = "user")
	private List<Order> orders;

	@OneToMany(mappedBy = "user")
	private List<Favorite> favorites;

	@OneToMany(mappedBy = "user")
	private List<ViewedProduct> viewedProducts;

	@OneToMany(mappedBy = "user")
	private List<Review> reviews;

	@OneToMany(mappedBy = "shipper")
	private List<ShipperAssignment> shipperAssignments;

	public User() {}

	public User(Long id, String email, String passwordHash, String fullName, String phone, String role, String status,
			Date createdAt, List<UserAddress> userAddresses, List<Shop> shops, List<Cart> carts, List<Order> orders,
			List<Favorite> favorites, List<ViewedProduct> viewedProducts, List<Review> reviews,
			List<ShipperAssignment> shipperAssignments) {
		super();
		this.id = id;
		this.email = email;
		this.passwordHash = passwordHash;
		this.fullName = fullName;
		this.phone = phone;
		this.role = role;
		this.status = status;
		this.createdAt = createdAt;
		this.userAddresses = userAddresses;
		this.shops = shops;
		this.carts = carts;
		this.orders = orders;
		this.favorites = favorites;
		this.viewedProducts = viewedProducts;
		this.reviews = reviews;
		this.shipperAssignments = shipperAssignments;
	}

	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }

	public String getPasswordHash() { return passwordHash; }
	public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

	public String getFullName() { return fullName; }
	public void setFullName(String fullName) { this.fullName = fullName; }

	public String getPhone() { return phone; }
	public void setPhone(String phone) { this.phone = phone; }

	public String getRole() { return role; }
	public void setRole(String role) { this.role = role; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }

	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

	public List<UserAddress> getUserAddresses() { return userAddresses; }
	public void setUserAddresses(List<UserAddress> userAddresses) { this.userAddresses = userAddresses; }

	public List<Shop> getShops() { return shops; }
	public void setShops(List<Shop> shops) { this.shops = shops; }
}
