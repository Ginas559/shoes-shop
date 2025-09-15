package vn.iotstar.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "products")
@NamedQuery(name = "Product.findAll", query = "SELECT p FROM Product p")
public class Product implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "shop_id")
	private Shop shop;

	@ManyToOne
	@JoinColumn(name = "category_id")
	private Category category;

	@Column(name = "name", columnDefinition = "nvarchar(255) not null")
	private String name;

	@Column(name = "slug", columnDefinition = "nvarchar(255)", unique = true)
	private String slug;

	@Column(name = "brand", columnDefinition = "nvarchar(255)")
	private String brand;

	@Column(name = "price")
	private BigDecimal price;

	@Column(name = "discount_price")
	private BigDecimal discountPrice;

	@Column(name = "description", columnDefinition = "nvarchar(255)")
	private String description;

	@Column(name = "rating_avg")
	private Double ratingAvg;

	@Column(name = "sold_count")
	private Integer soldCount;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created_at")
	private Date createdAt;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	// 1 - N: product_images
	@OneToMany(mappedBy = "product")
	private List<ProductImage> images;

	// 1 - N: product_variants
	@OneToMany(mappedBy = "product")
	private List<ProductVariant> variants;

	// 1 - N: favorites
	@OneToMany(mappedBy = "product")
	private List<Favorite> favorites;

	// 1 - N: viewed_products
	@OneToMany(mappedBy = "product")
	private List<ViewedProduct> viewedProducts;

	// 1 - N: reviews
	@OneToMany(mappedBy = "product")
	private List<Review> reviews;

	public Product() {}
	
	

	public Product(Long id, Shop shop, Category category, String name, String slug, String brand, BigDecimal price,
			BigDecimal discountPrice, String description, Double ratingAvg, Integer soldCount, Date createdAt,
			String status, List<ProductImage> images, List<ProductVariant> variants, List<Favorite> favorites,
			List<ViewedProduct> viewedProducts, List<Review> reviews) {
		super();
		this.id = id;
		this.shop = shop;
		this.category = category;
		this.name = name;
		this.slug = slug;
		this.brand = brand;
		this.price = price;
		this.discountPrice = discountPrice;
		this.description = description;
		this.ratingAvg = ratingAvg;
		this.soldCount = soldCount;
		this.createdAt = createdAt;
		this.status = status;
		this.images = images;
		this.variants = variants;
		this.favorites = favorites;
		this.viewedProducts = viewedProducts;
		this.reviews = reviews;
	}



	// Getter & Setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Shop getShop() { return shop; }
	public void setShop(Shop shop) { this.shop = shop; }

	public Category getCategory() { return category; }
	public void setCategory(Category category) { this.category = category; }

	public String getName() { return name; }
	public void setName(String name) { this.name = name; }

	public String getSlug() { return slug; }
	public void setSlug(String slug) { this.slug = slug; }

	public String getBrand() { return brand; }
	public void setBrand(String brand) { this.brand = brand; }

	public BigDecimal getPrice() { return price; }
	public void setPrice(BigDecimal price) { this.price = price; }

	public BigDecimal getDiscountPrice() { return discountPrice; }
	public void setDiscountPrice(BigDecimal discountPrice) { this.discountPrice = discountPrice; }

	public String getDescription() { return description; }
	public void setDescription(String description) { this.description = description; }

	public Double getRatingAvg() { return ratingAvg; }
	public void setRatingAvg(Double ratingAvg) { this.ratingAvg = ratingAvg; }

	public Integer getSoldCount() { return soldCount; }
	public void setSoldCount(Integer soldCount) { this.soldCount = soldCount; }

	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }

	public List<ProductImage> getImages() { return images; }
	public void setImages(List<ProductImage> images) { this.images = images; }

	public List<ProductVariant> getVariants() { return variants; }
	public void setVariants(List<ProductVariant> variants) { this.variants = variants; }

	public List<Favorite> getFavorites() { return favorites; }
	public void setFavorites(List<Favorite> favorites) { this.favorites = favorites; }

	public List<ViewedProduct> getViewedProducts() { return viewedProducts; }
	public void setViewedProducts(List<ViewedProduct> viewedProducts) { this.viewedProducts = viewedProducts; }

	public List<Review> getReviews() { return reviews; }
	public void setReviews(List<Review> reviews) { this.reviews = reviews; }
}
