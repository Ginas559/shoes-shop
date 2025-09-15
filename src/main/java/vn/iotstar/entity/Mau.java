package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "MAU")
@NamedQuery(name = "Mau.findAll", query = "SELECT m FROM Mau m")
public class Mau implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAMAU", length = 50)
    private String maMau;

    @Column(name = "TENMAU", columnDefinition = "nvarchar(100)")
    private String tenMau;

    @OneToMany(mappedBy = "maMau", cascade = CascadeType.ALL)
    private List<SanPham> sanPhams = new ArrayList<>();

    public Mau() {}

    public String getMaMau() { return maMau; }
    public void setMaMau(String maMau) { this.maMau = maMau; }
    public String getTenMau() { return tenMau; }
    public void setTenMau(String tenMau) { this.tenMau = tenMau; }

    public List<SanPham> getSanPhams() { return sanPhams; }
    public void setSanPhams(List<SanPham> sanPhams) { this.sanPhams = sanPhams; }
}
