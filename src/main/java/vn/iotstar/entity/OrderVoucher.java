package vn.iotstar.entity;

import java.io.Serializable;

import jakarta.persistence.*;

@Entity
@Table(name = "order_vouchers")
@NamedQuery(name = "OrderVoucher.findAll", query = "SELECT ov FROM OrderVoucher ov")
public class OrderVoucher implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "order_id")
	private Order order;

	@ManyToOne
	@JoinColumn(name = "voucher_id")
	private Voucher voucher;

	@Column(name = "discount_amount")
	private Double discountAmount;

	public OrderVoucher() {}
	
	

	public OrderVoucher(Long id, Order order, Voucher voucher, Double discountAmount) {
		super();
		this.id = id;
		this.order = order;
		this.voucher = voucher;
		this.discountAmount = discountAmount;
	}



	// getter & setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Order getOrder() { return order; }
	public void setOrder(Order order) { this.order = order; }

	public Voucher getVoucher() { return voucher; }
	public void setVoucher(Voucher voucher) { this.voucher = voucher; }

	public Double getDiscountAmount() { return discountAmount; }
	public void setDiscountAmount(Double discountAmount) { this.discountAmount = discountAmount; }
}
