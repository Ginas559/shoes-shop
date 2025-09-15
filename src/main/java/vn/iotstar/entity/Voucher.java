package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "vouchers")
@NamedQuery(name = "Voucher.findAll", query = "SELECT v FROM Voucher v")
public class Voucher implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@Column(name = "code", columnDefinition = "nvarchar(255)", unique = true)
	private String code;

	@Column(name = "type", columnDefinition = "nvarchar(255)")
	private String type; // percent/amount/freeship

	@Column(name = "value")
	private Double value;

	@Column(name = "min_order")
	private Double minOrder;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "start_at")
	private Date startAt;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "end_at")
	private Date endAt;

	@Column(name = "usage_limit")
	private Integer usageLimit;

	@Column(name = "used_count")
	private Integer usedCount;

	@Column(name = "status", columnDefinition = "nvarchar(255)")
	private String status;

	@ManyToOne
	@JoinColumn(name = "shop_id")
	private Shop shop; // null nếu voucher toàn sàn

	@OneToMany(mappedBy = "voucher")
	private List<OrderVoucher> orderVouchers;

	public Voucher() {}
	
	

	public Voucher(Long id, String code, String type, Double value, Double minOrder, Date startAt, Date endAt,
			Integer usageLimit, Integer usedCount, String status, Shop shop, List<OrderVoucher> orderVouchers) {
		super();
		this.id = id;
		this.code = code;
		this.type = type;
		this.value = value;
		this.minOrder = minOrder;
		this.startAt = startAt;
		this.endAt = endAt;
		this.usageLimit = usageLimit;
		this.usedCount = usedCount;
		this.status = status;
		this.shop = shop;
		this.orderVouchers = orderVouchers;
	}



	// getter & setter
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public String getCode() { return code; }
	public void setCode(String code) { this.code = code; }

	public String getType() { return type; }
	public void setType(String type) { this.type = type; }

	public Double getValue() { return value; }
	public void setValue(Double value) { this.value = value; }

	public Double getMinOrder() { return minOrder; }
	public void setMinOrder(Double minOrder) { this.minOrder = minOrder; }

	public Date getStartAt() { return startAt; }
	public void setStartAt(Date startAt) { this.startAt = startAt; }

	public Date getEndAt() { return endAt; }
	public void setEndAt(Date endAt) { this.endAt = endAt; }

	public Integer getUsageLimit() { return usageLimit; }
	public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }

	public Integer getUsedCount() { return usedCount; }
	public void setUsedCount(Integer usedCount) { this.usedCount = usedCount; }

	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }

	public Shop getShop() { return shop; }
	public void setShop(Shop shop) { this.shop = shop; }

	public List<OrderVoucher> getOrderVouchers() { return orderVouchers; }
	public void setOrderVouchers(List<OrderVoucher> orderVouchers) { this.orderVouchers = orderVouchers; }
}
