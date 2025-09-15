package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.*;

@Entity
@Table(name = "shipper_assignments")
@NamedQuery(name = "ShipperAssignment.findAll", query = "SELECT s FROM ShipperAssignment s")
public class ShipperAssignment implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "shipper_user_id")
	private User shipper;

	@ManyToOne
	@JoinColumn(name = "order_id")
	private Order order;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "assigned_at")
	private Date assignedAt;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "delivered_at")
	private Date deliveredAt;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	public ShipperAssignment() {}
	
	

	public ShipperAssignment(Long id, User shipper, Order order, Date assignedAt, Date deliveredAt, String status) {
		super();
		this.id = id;
		this.shipper = shipper;
		this.order = order;
		this.assignedAt = assignedAt;
		this.deliveredAt = deliveredAt;
		this.status = status;
	}



	// getter & setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getShipper() { return shipper; }
	public void setShipper(User shipper) { this.shipper = shipper; }

	public Order getOrder() { return order; }
	public void setOrder(Order order) { this.order = order; }

	public Date getAssignedAt() { return assignedAt; }
	public void setAssignedAt(Date assignedAt) { this.assignedAt = assignedAt; }

	public Date getDeliveredAt() { return deliveredAt; }
	public void setDeliveredAt(Date deliveredAt) { this.deliveredAt = deliveredAt; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }
}
