package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.*;

@Entity
@Table(name = "viewed_products")
@NamedQuery(name = "ViewedProduct.findAll", query = "SELECT v FROM ViewedProduct v")
public class ViewedProduct implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;

	@ManyToOne
	@JoinColumn(name = "product_id")
	private Product product;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "viewed_at")
	private Date viewedAt;

	public ViewedProduct() {}
	
	

	public ViewedProduct(Long id, User user, Product product, Date viewedAt) {
		super();
		this.id = id;
		this.user = user;
		this.product = product;
		this.viewedAt = viewedAt;
	}



	// getter & setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getUser() { return user; }
	public void setUser(User user) { this.user = user; }

	public Product getProduct() { return product; }
	public void setProduct(Product product) { this.product = product; }

	public Date getViewedAt() { return viewedAt; }
	public void setViewedAt(Date viewedAt) { this.viewedAt = viewedAt; }
}
