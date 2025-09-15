package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.*;

@Entity
@Table(name = "reviews")
@NamedQuery(name = "Review.findAll", query = "SELECT r FROM Review r")
public class Review implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "order_item_id")
	private OrderItem orderItem;

	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;

	@ManyToOne
	@JoinColumn(name = "product_id")
	private Product product;

	@Column(name = "rating")
	private Integer rating;

	@Column(name = "content", columnDefinition = "nvarchar(255)")
	private String content;

	@Column(name = "media_url", columnDefinition = "nvarchar(255)")
	private String mediaUrl;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created_at")
	private Date createdAt;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	public Review() {}
	
	

	public Review(Long id, OrderItem orderItem, User user, Product product, Integer rating, String content,
			String mediaUrl, Date createdAt, String status) {
		super();
		this.id = id;
		this.orderItem = orderItem;
		this.user = user;
		this.product = product;
		this.rating = rating;
		this.content = content;
		this.mediaUrl = mediaUrl;
		this.createdAt = createdAt;
		this.status = status;
	}



	// getter & setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public OrderItem getOrderItem() { return orderItem; }
	public void setOrderItem(OrderItem orderItem) { this.orderItem = orderItem; }

	public User getUser() { return user; }
	public void setUser(User user) { this.user = user; }

	public Product getProduct() { return product; }
	public void setProduct(Product product) { this.product = product; }

	public Integer getRating() { return rating; }
	public void setRating(Integer rating) { this.rating = rating; }

	public String getContent() { return content; }
	public void setContent(String content) { this.content = content; }

	public String getMediaUrl() { return mediaUrl; }
	public void setMediaUrl(String mediaUrl) { this.mediaUrl = mediaUrl; }

	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }
}
