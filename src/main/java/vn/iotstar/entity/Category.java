package vn.iotstar.entity;

import java.io.Serializable;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "categories")
@NamedQuery(name = "Category.findAll", query = "SELECT c FROM Category c")
public class Category implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	// self reference: parent -> children
	@ManyToOne
	@JoinColumn(name = "parent_id")
	private Category parent;

	@OneToMany(mappedBy = "parent")
	private List<Category> children;

	@Column(name = "name", columnDefinition = "nvarchar(255) not null")
	private String name;

	@Column(name = "slug", columnDefinition = "nvarchar(255)", unique = true)
	private String slug;

	// 1 - N: products
	@OneToMany(mappedBy = "category")
	private List<Product> products;

	public Category() {}
	
	

	public Category(Long id, Category parent, List<Category> children, String name, String slug,
			List<Product> products) {
		super();
		this.id = id;
		this.parent = parent;
		this.children = children;
		this.name = name;
		this.slug = slug;
		this.products = products;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Category getParent() { return parent; }
	public void setParent(Category parent) { this.parent = parent; }

	public List<Category> getChildren() { return children; }
	public void setChildren(List<Category> children) { this.children = children; }

	public String getName() { return name; }
	public void setName(String name) { this.name = name; }

	public String getSlug() { return slug; }
	public void setSlug(String slug) { this.slug = slug; }

	public List<Product> getProducts() { return products; }
	public void setProducts(List<Product> products) { this.products = products; }
}
