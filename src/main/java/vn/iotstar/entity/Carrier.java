package vn.iotstar.entity;

import java.io.Serializable;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "carriers")
@NamedQuery(name = "Carrier.findAll", query = "SELECT c FROM Carrier c")
public class Carrier implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@Column(name = "name", columnDefinition = "nvarchar(255) not null")
	private String name;

	@Column(name = "base_fee")
	private Double baseFee;

	@Column(name = "fee_per_km")
	private Double feePerKm;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	@OneToMany(mappedBy = "carrier")
	private List<Order> orders;

	public Carrier() {}
	
	

	public Carrier(Long id, String name, Double baseFee, Double feePerKm, String status, List<Order> orders) {
		super();
		this.id = id;
		this.name = name;
		this.baseFee = baseFee;
		this.feePerKm = feePerKm;
		this.status = status;
		this.orders = orders;
	}



	// getter & setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public String getName() { return name; }
	public void setName(String name) { this.name = name; }

	public Double getBaseFee() { return baseFee; }
	public void setBaseFee(Double baseFee) { this.baseFee = baseFee; }

	public Double getFeePerKm() { return feePerKm; }
	public void setFeePerKm(Double feePerKm) { this.feePerKm = feePerKm; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }

	public List<Order> getOrders() { return orders; }
	public void setOrders(List<Order> orders) { this.orders = orders; }
}
