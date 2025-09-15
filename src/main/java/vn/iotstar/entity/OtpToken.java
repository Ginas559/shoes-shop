package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.*;

@Entity
@Table(name = "otp_tokens")
@NamedQuery(name = "OtpToken.findAll", query = "SELECT o FROM OtpToken o")
public class OtpToken implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;

	@Column(name = "code", columnDefinition = "nvarchar(255)")
	private String code;

	@Column(name = "purpose", columnDefinition = "nvarchar(255)")
	private String purpose;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "expired_at")
	private Date expiredAt;

	@Column(name = "used")
	private Boolean used;

	public OtpToken() {}
	
	

	public OtpToken(Long id, User user, String code, String purpose, Date expiredAt, Boolean used) {
		super();
		this.id = id;
		this.user = user;
		this.code = code;
		this.purpose = purpose;
		this.expiredAt = expiredAt;
		this.used = used;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getUser() { return user; }
	public void setUser(User user) { this.user = user; }

	public String getCode() { return code; }
	public void setCode(String code) { this.code = code; }

	public String getPurpose() { return purpose; }
	public void setPurpose(String purpose) { this.purpose = purpose; }

	public Date getExpiredAt() { return expiredAt; }
	public void setExpiredAt(Date expiredAt) { this.expiredAt = expiredAt; }

	public Boolean getUsed() { return used; }
	public void setUsed(Boolean used) { this.used = used; }
}
