package vn.iotstar.entity;

import java.io.Serializable;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "shops")
@NamedQuery(name = "Shop.findAll", query = "SELECT s FROM Shop s")
public class Shop implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "owner_user_id")
	private User owner;

	@Column(name = "name", columnDefinition = "nvarchar(255) not null")
	private String name;

	@Column(name = "slug", columnDefinition = "nvarchar(255)", unique = true)
	private String slug;

	@Column(name = "logo", columnDefinition = "nvarchar(255)")
	private String logo;

	@Column(name = "description", columnDefinition = "nvarchar(255)")
	private String description;

	@Column(name = "commission_rate")
	private Double commissionRate;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	// 1 - N: products
	@OneToMany(mappedBy = "shop")
	private List<Product> products;

	// 1 - N: orders
	@OneToMany(mappedBy = "shop")
	private List<Order> orders;

	// 1 - N: vouchers
	@OneToMany(mappedBy = "shop")
	private List<Voucher> vouchers;

	public Shop() {}
	
	

	public Shop(Long id, User owner, String name, String slug, String logo, String description, Double commissionRate,
			String status, List<Product> products, List<Order> orders, List<Voucher> vouchers) {
		super();
		this.id = id;
		this.owner = owner;
		this.name = name;
		this.slug = slug;
		this.logo = logo;
		this.description = description;
		this.commissionRate = commissionRate;
		this.status = status;
		this.products = products;
		this.orders = orders;
		this.vouchers = vouchers;
	}



	// Getter & Setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getOwner() { return owner; }
	public void setOwner(User owner) { this.owner = owner; }

	public String getName() { return name; }
	public void setName(String name) { this.name = name; }

	public String getSlug() { return slug; }
	public void setSlug(String slug) { this.slug = slug; }

	public String getLogo() { return logo; }
	public void setLogo(String logo) { this.logo = logo; }

	public String getDescription() { return description; }
	public void setDescription(String description) { this.description = description; }

	public Double getCommissionRate() { return commissionRate; }
	public void setCommissionRate(Double commissionRate) { this.commissionRate = commissionRate; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }

	public List<Product> getProducts() { return products; }
	public void setProducts(List<Product> products) { this.products = products; }

	public List<Order> getOrders() { return orders; }
	public void setOrders(List<Order> orders) { this.orders = orders; }

	public List<Voucher> getVouchers() { return vouchers; }
	public void setVouchers(List<Voucher> vouchers) { this.vouchers = vouchers; }
}
