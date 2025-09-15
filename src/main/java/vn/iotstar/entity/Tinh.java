package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "TINH")
@NamedQuery(name = "Tinh.findAll", query = "SELECT t FROM Tinh t")
public class Tinh implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MATINH", length = 50)
    private String maTinh;

    @Column(name = "TENTINH", columnDefinition = "nvarchar(200)")
    private String tenTinh;

    @OneToMany(mappedBy = "tinh", cascade = CascadeType.ALL)
    private List<Quan> quans = new ArrayList<>();

    public Tinh() {}

    public String getMaTinh() { return maTinh; }
    public void setMaTinh(String maTinh) { this.maTinh = maTinh; }
    public String getTenTinh() { return tenTinh; }
    public void setTenTinh(String tenTinh) { this.tenTinh = tenTinh; }

    public List<Quan> getQuans() { return quans; }
    public void setQuans(List<Quan> quans) { this.quans = quans; }
}
