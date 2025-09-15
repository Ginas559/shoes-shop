package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.*;

@Entity
@Table(name = "payments")
@NamedQuery(name = "Payment.findAll", query = "SELECT p FROM Payment p")
public class Payment implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "order_id")
	private Order order;

	@Column(name = "gateway", columnDefinition = "nvarchar(255)")
	private String gateway;

	@Column(name = "amount")
	private Double amount;

	@Column(name = "txn_ref", columnDefinition = "nvarchar(255)")
	private String txnRef;

	@Column(name = "txn_status", columnDefinition = "nvarchar(255)")
	private String txnStatus;

	@Column(name = "payload_json", columnDefinition = "nvarchar(255)")
	private String payloadJson;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created_at")
	private Date createdAt;

	public Payment() {}
	
	

	public Payment(Long id, Order order, String gateway, Double amount, String txnRef, String txnStatus,
			String payloadJson, Date createdAt) {
		super();
		this.id = id;
		this.order = order;
		this.gateway = gateway;
		this.amount = amount;
		this.txnRef = txnRef;
		this.txnStatus = txnStatus;
		this.payloadJson = payloadJson;
		this.createdAt = createdAt;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public Order getOrder() { return order; }
	public void setOrder(Order order) { this.order = order; }

	public String getGateway() { return gateway; }
	public void setGateway(String gateway) { this.gateway = gateway; }

	public Double getAmount() { return amount; }
	public void setAmount(Double amount) { this.amount = amount; }

	public String getTxnRef() { return txnRef; }
	public void setTxnRef(String txnRef) { this.txnRef = txnRef; }

	public String getTxnStatus() { return txnStatus; }
	public void setTxnStatus(String txnStatus) { this.txnStatus = txnStatus; }

	public String getPayloadJson() { return payloadJson; }
	public void setPayloadJson(String payloadJson) { this.payloadJson = payloadJson; }

	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
