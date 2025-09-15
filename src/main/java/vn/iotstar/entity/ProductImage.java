package vn.iotstar.entity;

import java.io.Serializable;

import jakarta.persistence.*;

@Entity
@Table(name = "product_images")
@NamedQuery(name = "ProductImage.findAll", query = "SELECT pi FROM ProductImage pi")
public class ProductImage implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "product_id")
	private Product product;

	@Column(name = "url", columnDefinition = "nvarchar(255)")
	private String url;

	@Column(name = "is_cover")
	private Boolean isCover;

	public ProductImage() {}
	
	

	public ProductImage(Long id, Product product, String url, Boolean isCover) {
		super();
		this.id = id;
		this.product = product;
		this.url = url;
		this.isCover = isCover;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Product getProduct() { return product; }
	public void setProduct(Product product) { this.product = product; }

	public String getUrl() { return url; }
	public void setUrl(String url) { this.url = url; }

	public Boolean getIsCover() { return isCover; }
	public void setIsCover(Boolean isCover) { this.isCover = isCover; }
}
