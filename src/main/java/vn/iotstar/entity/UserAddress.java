package vn.iotstar.entity;

import java.io.Serializable;

import jakarta.persistence.*;

@Entity
@Table(name = "user_addresses")
@NamedQuery(name = "UserAddress.findAll", query = "SELECT a FROM UserAddress a")
public class UserAddress implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;

	@Column(name = "receiver_name", columnDefinition = "nvarchar(255)")
	private String receiverName;

	@Column(name = "phone", columnDefinition = "nvarchar(255)")
	private String phone;

	@Column(name = "address_line", columnDefinition = "nvarchar(255)")
	private String addressLine;

	@Column(name = "ward", columnDefinition = "nvarchar(255)")
	private String ward;

	@Column(name = "district", columnDefinition = "nvarchar(255)")
	private String district;

	@Column(name = "province", columnDefinition = "nvarchar(255)")
	private String province;

	@Column(name = "is_default")
	private Boolean isDefault;

	public UserAddress() {}
	
	

	public UserAddress(Long id, User user, String receiverName, String phone, String addressLine, String ward,
			String district, String province, Boolean isDefault) {
		super();
		this.id = id;
		this.user = user;
		this.receiverName = receiverName;
		this.phone = phone;
		this.addressLine = addressLine;
		this.ward = ward;
		this.district = district;
		this.province = province;
		this.isDefault = isDefault;
	}



	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public User getUser() { return user; }
	public void setUser(User user) { this.user = user; }

	public String getReceiverName() { return receiverName; }
	public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

	public String getPhone() { return phone; }
	public void setPhone(String phone) { this.phone = phone; }

	public String getAddressLine() { return addressLine; }
	public void setAddressLine(String addressLine) { this.addressLine = addressLine; }

	public String getWard() { return ward; }
	public void setWard(String ward) { this.ward = ward; }

	public String getDistrict() { return district; }
	public void setDistrict(String district) { this.district = district; }

	public String getProvince() { return province; }
	public void setProvince(String province) { this.province = province; }

	public Boolean getIsDefault() { return isDefault; }
	public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }
}
