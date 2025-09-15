package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "carts")
@NamedQuery(name = "Cart.findAll", query = "SELECT c FROM Cart c")
public class Cart implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "updated_at")
	private Date updatedAt;

	@OneToMany(mappedBy = "cart")
	private List<CartItem> cartItems;

	public Cart() {}
	
	

	public Cart(Long id, User user, Date updatedAt, List<CartItem> cartItems) {
		super();
		this.id = id;
		this.user = user;
		this.updatedAt = updatedAt;
		this.cartItems = cartItems;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getUser() { return user; }
	public void setUser(User user) { this.user = user; }

	public Date getUpdatedAt() { return updatedAt; }
	public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

	public List<CartItem> getCartItems() { return cartItems; }
	public void setCartItems(List<CartItem> cartItems) { this.cartItems = cartItems; }
}
